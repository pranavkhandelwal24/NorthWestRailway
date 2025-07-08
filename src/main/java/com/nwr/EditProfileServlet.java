package com.nwr;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/EditProfileServlet")
public class EditProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String SALT = "nwr-railway-system";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        String role = request.getParameter("role"); // e.g., admin, member, superadmin
        String oldUsername = (String) session.getAttribute("username");

        String name = request.getParameter("name");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv")) {

            // ✅ Check duplicate username/email across ALL roles
            String[] tables = {"members", "admins", "superadmins"};
            for (String table : tables) {
                String sql = "SELECT * FROM " + table + " WHERE (username = ? OR email = ?) AND username != ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, username);
                    stmt.setString(2, email);
                    stmt.setString(3, oldUsername);
                    ResultSet rs = stmt.executeQuery();
                    if (rs.next()) {
                        String errorMessage = "Username or email already exists";
                        errorMessage = URLEncoder.encode(errorMessage, "UTF-8");
                        response.sendRedirect("edit-profile.jsp?error=" + errorMessage);
                        return;
                    }
                }
            }

            // ✅ If changing password, verify old password (hashed)
            if (newPassword != null && !newPassword.trim().isEmpty()) {
                String sql = "SELECT * FROM " + role + "s WHERE username = ? AND password = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, oldUsername);
                    stmt.setString(2, hashPassword(currentPassword)); // ✅ hash old password
                    ResultSet rs = stmt.executeQuery();
                    if (!rs.next()) {
                        String errorMessage = "Current password is incorrect";
                        errorMessage = URLEncoder.encode(errorMessage, "UTF-8");
                        response.sendRedirect("edit-profile.jsp?error=" + errorMessage);
                        return;
                    }
                }
            }

            // ✅ Update profile (hash new password if provided)
            String sql = "UPDATE " + role + "s SET name = ?, username = ?, email = ?" +
                         (newPassword != null && !newPassword.trim().isEmpty() ? ", password = ?" : "") +
                         " WHERE username = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, name);
                stmt.setString(2, username);
                stmt.setString(3, email);
                if (newPassword != null && !newPassword.trim().isEmpty()) {
                    stmt.setString(4, hashPassword(newPassword)); // ✅ hash new password
                    stmt.setString(5, oldUsername);
                } else {
                    stmt.setString(4, oldUsername);
                }
                int rows = stmt.executeUpdate();
                if (rows > 0) {
                    // ✅ Update session so navbar shows new username/name
                	session.setAttribute("username", username);
                	session.setAttribute("fullName", name); // ✅ Important: fullName not name!
                	response.sendRedirect(role + ".jsp?success=" + URLEncoder.encode("Profile updated successfully", "UTF-8"));


                } else {
                    response.sendRedirect("edit-profile.jsp?error=" + URLEncoder.encode("Profile update failed", "UTF-8"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("edit-profile.jsp?error=" + URLEncoder.encode("Server error: " + e.getMessage(), "UTF-8"));
        }
    }

    private String hashPassword(String password) throws Exception {
        String saltedPassword = SALT + password;
        java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
        md.update(saltedPassword.getBytes());
        byte[] digest = md.digest();
        StringBuilder sb = new StringBuilder();
        for (byte b : digest) {
            sb.append(String.format("%02x", b & 0xff));
        }
        return sb.toString();
    }
}
