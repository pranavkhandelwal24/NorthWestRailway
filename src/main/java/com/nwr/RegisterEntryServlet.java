package com.nwr;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.math.BigDecimal;


@WebServlet("/register-entry")
public class RegisterEntryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String system = request.getParameter("system");
    	String ifileNoStr = request.getParameter("ifile_no");
        String efileNoStr = request.getParameter("efile_no");
        String details = request.getParameter("details");
        String functionYear = request.getParameter("function_year");
        String subject = request.getParameter("subject");
        String proposedCostStr = request.getParameter("proposed_cost");
        String vettedCostStr = request.getParameter("vetted_cost");
        String receivedDate = request.getParameter("received_date");
        String putupDate = request.getParameter("putup_date");
        String dispatchDate = request.getParameter("dispatch_date");
        String status = request.getParameter("status");

        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : null;

        if (username == null) {
            response.sendRedirect("login.jsp?error=Session expired. Please login again.");
            return;
        }

        if (ifileNoStr == null || ifileNoStr.isEmpty() || efileNoStr == null || efileNoStr.isEmpty()) {
            response.sendRedirect("member.jsp?error=Both I File No and E File No are required.");
            return;
        }

        try {
            int ifileNo = Integer.parseInt(ifileNoStr);
            int efileNo = Integer.parseInt(efileNoStr);

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");

            // ✅ Check for duplicate file numbers
            String checkSql = "SELECT COUNT(*) FROM register_entries WHERE ifile_no = ? OR efile_no = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, ifileNo);
            checkPs.setInt(2, efileNo);
            ResultSet rs = checkPs.executeQuery();
            rs.next();
            int count = rs.getInt(1);

            if (count > 0) {
                conn.close();
                response.sendRedirect("member.jsp?error=File number already exists.");
                return;
            }

            // ✅ 🔑 Get department from members table
            String department = null;
            String deptSql = "SELECT department FROM members WHERE username = ?";
            PreparedStatement deptPs = conn.prepareStatement(deptSql);
            deptPs.setString(1, username);
            ResultSet deptRs = deptPs.executeQuery();
            if (deptRs.next()) {
                department = deptRs.getString("department");
            } else {
                conn.close();
                response.sendRedirect("member.jsp?error=Department not found for user.");
                return;
            }

            // ✅ Parse cost fields
            BigDecimal proposedCost = (proposedCostStr == null || proposedCostStr.trim().isEmpty()) ? null : new BigDecimal(proposedCostStr.trim());
            BigDecimal vettedCost = (vettedCostStr == null || vettedCostStr.trim().isEmpty()) ? null : new BigDecimal(vettedCostStr.trim());

            BigDecimal savings = null;
            if (proposedCost != null && vettedCost != null) {
                savings = proposedCost.subtract(vettedCost);
            }

            // ✅ Insert new record including department
            String sql = "INSERT INTO register_entries " +
                    "(username, department, `system`, ifile_no, efile_no, details, function_year, subject, proposed_cost, vetted_cost, savings, received_date, putup_date, dispatch_date, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, username);
            ps.setString(2, department);
            ps.setString(3, system);
            ps.setInt(4, ifileNo);
            ps.setInt(5, efileNo);
            ps.setString(6, details);
            ps.setString(7, functionYear);
            ps.setString(8, subject);

            if (proposedCost != null) {
                ps.setBigDecimal(9, proposedCost);
            } else {
                ps.setNull(9, Types.DECIMAL);
            }

            if (vettedCost != null) {
                ps.setBigDecimal(10, vettedCost);
            } else {
                ps.setNull(10, Types.DECIMAL);
            }

            if (savings != null) {
                ps.setBigDecimal(11, savings);
            } else {
                ps.setNull(11, Types.DECIMAL);
            }

            ps.setString(12, receivedDate);
            ps.setString(13, (putupDate == null || putupDate.isEmpty()) ? null : putupDate);
            ps.setString(14, (dispatchDate == null || dispatchDate.isEmpty()) ? null : dispatchDate);
            ps.setString(15, (status == null || status.isEmpty()) ? null : status);

            ps.executeUpdate();
            conn.close();

            response.sendRedirect("member.jsp?success=File added successfully");

        } catch (NumberFormatException e) {
            response.sendRedirect("member.jsp?error=Invalid file number format.");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("member.jsp?error=Database error: " + e.getMessage());
        }
    }
}
