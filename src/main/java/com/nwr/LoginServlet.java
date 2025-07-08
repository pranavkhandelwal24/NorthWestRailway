package com.nwr;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String SALT = "nwr-railway-system";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Validate inputs
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            sendError(response, "Username and password are required");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/register2", "root", "root");

            // Check user in all tables
            Object[] userData = authenticateUser(con, username);
            if (userData == null) {
                sendError(response, "Username not found", "username");
                return;
            }

            String role = (String) userData[0];
            String name = (String) userData[1];
            String storedPassword = (String) userData[2];
            String status = (String) userData[3];

            // Verify password
            if (!storedPassword.equals(hashPassword(password))) {
                sendError(response, "Incorrect password", "password");
                return;
            }
            
            if ("inactive".equalsIgnoreCase(status)) {
                sendError(response, "User is Deleted!!", "username");
                return;
            }

            // Create session
            HttpSession session = request.getSession();
            session.setAttribute("username", username);
            session.setAttribute("fullName", name);
            session.setAttribute("role", role);
            
            // Set session timeout (30 minutes)
            session.setMaxInactiveInterval(30 * 60);

            // Remember Me Cookie
            if ("on".equals(request.getParameter("remember"))) {
                Cookie rememberCookie = new Cookie("remembered_username", username);
                rememberCookie.setMaxAge(30 * 24 * 60 * 60); // 30 days
                rememberCookie.setHttpOnly(true);
                rememberCookie.setSecure(true);
                response.addCookie(rememberCookie);
            }

            // Log login attempt
            logLogin(con, username, request.getRemoteAddr());

            // Send success response
            sendSuccess(response, getRedirectUrl(role));
            
        } catch (ClassNotFoundException e) {
            sendError(response, "Database driver not found");
        } catch (SQLException e) {
            sendError(response, "Database error: " + e.getMessage());
        } catch (NoSuchAlgorithmException e) {
            sendError(response, "System error: Password encryption failed");
        } catch (Exception e) {
            sendError(response, "Unexpected error: " + e.getMessage());
        } finally {
            closeResources(rs, pst, con);
        }
    }

    private Object[] authenticateUser(Connection con, String username) throws SQLException {
        String[] tables = {"superadmins", "admins", "members"};
        String[] roles = {"superadmin", "admin", "member"};
        
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        for (int i = 0; i < tables.length; i++) {
            try {
                pst = con.prepareStatement(
                    "SELECT name, password, status FROM " + tables[i] + " WHERE username = ?");
                pst.setString(1, username);
                rs = pst.executeQuery();
                
                if (rs.next()) {
                    return new Object[] {
                        roles[i], 
                        rs.getString("name"), 
                        rs.getString("password"),
                        rs.getString("status")
                    };
                }
            } finally {
                closeResources(rs, pst);
            }
        }
        return null;
    }

    private void logLogin(Connection con, String username, String ipAddress) throws SQLException {
        PreparedStatement pst = null;
        try {
            pst = con.prepareStatement(
                "INSERT INTO login_logs (username, ip_address) VALUES (?, ?)");
            pst.setString(1, username);
            pst.setString(2, ipAddress);
            pst.executeUpdate();
        } finally {
            if (pst != null) pst.close();
        }
    }

    private String getRedirectUrl(String role) {
        switch (role) {
            case "superadmin": return "superadmin.jsp";
            case "admin": return "admin.jsp";
            case "member": return "member.jsp";
            default: return "login.jsp";
        }
    }

    private void sendSuccess(HttpServletResponse response, String redirectUrl) throws IOException {
        response.getWriter().print(
            "{\"success\": true, \"redirectUrl\": \"" + redirectUrl + "\"}");
    }

    private void sendError(HttpServletResponse response, String message) throws IOException {
        sendError(response, message, null);
    }

    private void sendError(HttpServletResponse response, String message, String errorField) throws IOException {
        PrintWriter out = response.getWriter();
        out.print("{\"success\": false, \"message\": \"" + 
                 message.replace("\"", "'") + "\"" +
                 (errorField != null ? ", \"errorField\": \"" + errorField + "\"" : "") +
                 "}");
    }

    private void closeResources(ResultSet rs, Statement stmt, Connection con) {
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (stmt != null) stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
    }

    private void closeResources(ResultSet rs, Statement stmt) {
        closeResources(rs, stmt, null);
    }

    private String hashPassword(String password) throws NoSuchAlgorithmException {
        String saltedPassword = SALT + password;
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(saltedPassword.getBytes());
        byte[] digest = md.digest();
        StringBuilder sb = new StringBuilder();
        for (byte b : digest) {
            sb.append(String.format("%02x", b & 0xff));
        }
        return sb.toString();
    }
}