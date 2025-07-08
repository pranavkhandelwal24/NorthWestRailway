package com.nwr;

import java.io.IOException;
import java.sql.*;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/generate-report")
public class GenerateReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Session Validation
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?sessionExpired=true");
            return;
        }

        String username = (String) session.getAttribute("username");
        String department = (String) session.getAttribute("department");
        
        if (username == null || department == null) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp?unauthorized=true");
            return;
        }

        // 2. Parameter Validation
        String refDateStr = request.getParameter("refDate");
        String daysStr = request.getParameter("days");
        
        if (refDateStr == null || refDateStr.trim().isEmpty() || 
            daysStr == null || daysStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, 
                "Both refDate and days parameters are required");
            return;
        }

        int days;
        try {
            days = Integer.parseInt(daysStr);
            if (days <= 0) {
                throw new NumberFormatException("Days must be positive");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, 
                "Invalid days parameter: must be a positive integer");
            return;
        }

        Connection conn = null;
        try {
            // 3. Calculate Date Range
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date utilRefDate = sdf.parse(refDateStr);
            java.sql.Date refDate = new java.sql.Date(utilRefDate.getTime());

            Calendar cal = Calendar.getInstance();
            cal.setTime(refDate);
            cal.add(Calendar.DATE, -days);
            String startDate = sdf.format(cal.getTime());
            String endDate = refDateStr;

            // 4. Database Connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/register2", "root", "root");

            // 5. Get Users in Department
            Map<String, Map<String, Integer>> userStats = new LinkedHashMap<>();
            List<String> users = new ArrayList<>();
            
            try (PreparedStatement userPs = conn.prepareStatement(
                    "SELECT DISTINCT username FROM register_entries WHERE department = ? ORDER BY username")) {
                userPs.setString(1, department);
                try (ResultSet userRs = userPs.executeQuery()) {
                    while (userRs.next()) {
                        String user = userRs.getString("username");
                        users.add(user);
                        userStats.put(user, new LinkedHashMap<>());
                    }
                }
            }

            // 6. Calculate Statistics for Each User
            for (String user : users) {
                Map<String, Integer> stats = userStats.get(user);
                
                // Opening Balance
                stats.putAll(getSystemCounts(conn, user, 
                    "SELECT COUNT(*) AS count FROM register_entries WHERE username = ? AND dispatch_date IS NULL AND received_date BETWEEN ? AND ? AND `system` = ?",
                    startDate, endDate, "opening"));
                
                // Received
                stats.putAll(getSystemCounts(conn, user, 
                    "SELECT COUNT(*) AS count FROM register_entries WHERE username = ? AND received_date BETWEEN ? AND ? AND `system` = ?",
                    startDate, endDate, "received"));
                
                // Vetted
                stats.putAll(getSystemCounts(conn, user, 
                    "SELECT COUNT(*) AS count FROM register_entries WHERE username = ? AND vetted_cost IS NOT NULL AND received_date BETWEEN ? AND ? AND `system` = ?",
                    startDate, endDate, "vetted"));
                
                // Returned
                stats.putAll(getSystemCounts(conn, user, 
                    "SELECT COUNT(*) AS count FROM register_entries WHERE username = ? AND status = 'R' AND received_date BETWEEN ? AND ? AND `system` = ?",
                    startDate, endDate, "returned"));
                
                // Closing Balance
                stats.putAll(getSystemCounts(conn, user, 
                    "SELECT COUNT(*) AS count FROM register_entries WHERE username = ? AND dispatch_date IS NOT NULL AND received_date BETWEEN ? AND ? AND `system` = ?",
                    startDate, endDate, "closing"));
                
                // Put Up Files
                stats.putAll(getSystemCounts(conn, user, 
                    "SELECT COUNT(*) AS count FROM register_entries WHERE username = ? AND putup_date IS NOT NULL AND received_date BETWEEN ? AND ? AND `system` = ?",
                    startDate, endDate, "putup"));
                
                // Files Pending
                stats.putAll(getSystemCounts(conn, user, 
                    "SELECT COUNT(*) AS count FROM register_entries WHERE username = ? AND dispatch_date IS NULL AND received_date BETWEEN ? AND ? AND `system` = ?",
                    startDate, endDate, "pending"));
            }

            // Calculate totals
            Map<String, Integer> totals = new HashMap<>();
            String[] metrics = {"opening", "received", "vetted", "returned", "closing", "putup", "pending"};
            String[] systems = {"eoffice", "irpsm"};

            for (String metric : metrics) {
                for (String system : systems) {
                    String key = metric + "_" + system;
                    int sum = 0;
                    for (String user : users) {
                        sum += userStats.get(user).getOrDefault(key, 0);
                    }
                    totals.put(key, sum);
                }
            }

            // Format dates for display
            SimpleDateFormat displayFormat = new SimpleDateFormat("dd.MM.yyyy");
            String displayStartDate = displayFormat.format(sdf.parse(startDate));
            String displayEndDate = displayFormat.format(sdf.parse(endDate));

            // Set attributes for JSP
            request.setAttribute("users", users);
            request.setAttribute("userStats", userStats);
            request.setAttribute("startDate", displayStartDate);
            request.setAttribute("endDate", displayEndDate);
            request.setAttribute("reportPeriod", days + " Days Report");
            request.setAttribute("totals", totals);
            request.setAttribute("currentDate", displayFormat.format(new Date(days)));
            
            // Forward to JSP
            request.getRequestDispatcher("/report.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Error generating report: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { /* Ignored */ }
            }
        }
    }

    private Map<String, Integer> getSystemCounts(Connection conn, String username, String query, 
            String... params) throws SQLException {
        Map<String, Integer> counts = new LinkedHashMap<>();
        
        // Check for E-Office
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, username);
            for (int i = 0; i < params.length - 1; i++) {
                ps.setString(i + 2, params[i]);
            }
            ps.setString(params.length + 1, "E-Office");
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    counts.put(params[params.length - 1] + "_eoffice", rs.getInt("count"));
                }
            }
        }
        
        // Check for IRPSM
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, username);
            for (int i = 0; i < params.length - 1; i++) {
                ps.setString(i + 2, params[i]);
            }
            ps.setString(params.length + 1, "IRPSM");
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    counts.put(params[params.length - 1] + "_irpsm", rs.getInt("count"));
                }
            }
        }
        
        return counts;
    }
}