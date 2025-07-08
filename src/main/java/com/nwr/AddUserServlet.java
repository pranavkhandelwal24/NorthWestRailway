package com.nwr;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@WebServlet("/add-user")
public class AddUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String SALT = "nwr-railway-system";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        Connection conn = null;
        try {
            request.setCharacterEncoding("UTF-8");
            HttpSession session = request.getSession(false);
            
            // Validate session
            if (session == null || session.getAttribute("username") == null || session.getAttribute("role") == null) {
                out.print("{\"status\":\"error\",\"message\":\"Session expired. Please login again.\"}");
                return;
            }

            String currentUserRole = (String) session.getAttribute("role");
            String currentUserDepartment = (String) session.getAttribute("department");
            
            // Get form parameters
            String name = request.getParameter("name");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String email = request.getParameter("email");
            String role = request.getParameter("role");
            String department = request.getParameter("department");

            // Validate required fields
            if (name == null || name.trim().isEmpty() ||
                username == null || username.trim().isEmpty() ||
                password == null || password.isEmpty() ||
                email == null || email.trim().isEmpty()) {
                
                out.print("{\"status\":\"error\",\"message\":\"All fields are required\"}");
                return;
            }

            // Role-specific validations
            if ("superadmin".equals(currentUserRole)) {
                // Superadmin can specify any role and department
                if (role == null || role.trim().isEmpty()) {
                    out.print("{\"status\":\"error\",\"message\":\"Role is required\"}");
                    return;
                }
                if (!"superadmin".equals(role) && (department == null || department.trim().isEmpty())) {
                    out.print("{\"status\":\"error\",\"message\":\"Department is required for this role\"}");
                    return;
                }
            } else if ("admin".equals(currentUserRole)) {
                // Admin can only add members in their own department
                role = "member"; // Force role to member
                department = currentUserDepartment; // Use admin's department
            } else {
                out.print("{\"status\":\"error\",\"message\":\"Unauthorized access\"}");
                return;
            }

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/register2", "root", "root");

            // Check if username exists
            if (isValueExists(conn, "username", username)) {
                out.print("{\"status\":\"error\",\"message\":\"Username already exists\"}");
                return;
            }

            // Check if email exists
            if (isValueExists(conn, "email", email)) {
                out.print("{\"status\":\"error\",\"message\":\"Email already exists\"}");
                return;
            }

            // Hash password
            String hashedPassword = hashPassword(password);

            // Insert user based on role
            String sql = "";
            switch(role) {
                case "superadmin":
                    sql = "INSERT INTO superadmins (name, username, password, email, status) VALUES (?, ?, ?, ?, 'active')";
                    break;
                case "admin":
                    sql = "INSERT INTO admins (name, username, password, email, department, status) VALUES (?, ?, ?, ?, ?, 'active')";
                    break;
                case "member":
                    sql = "INSERT INTO members (name, username, password, email, department, status) VALUES (?, ?, ?, ?, ?, 'active')";
                    break;
                default:
                    out.print("{\"status\":\"error\",\"message\":\"Invalid user role\"}");
                    return;
            }

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, name);
                stmt.setString(2, username);
                stmt.setString(3, hashedPassword);
                stmt.setString(4, email);

                if (!"superadmin".equals(role)) {
                    stmt.setString(5, department);
                }

                if (stmt.executeUpdate() > 0) {
                    if ("admin".equals(role)) {
                        updateDepartmentHead(conn, department, name);
                    }
                    out.print("{\"status\":\"success\",\"message\":\"User added successfully\"}");
                } else {
                    out.print("{\"status\":\"error\",\"message\":\"Failed to add user\"}");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\",\"message\":\"Server error: " + e.getMessage().replace("\"", "'") + "\"}");
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            out.flush();
        }
    }

    private boolean isValueExists(Connection con, String column, String value) throws SQLException {
        String[] tables = {"superadmins", "admins", "members"};
        for (String table : tables) {
            String query = "SELECT COUNT(*) AS count FROM " + table + " WHERE " + column + " = ?";
            try (PreparedStatement stmt = con.prepareStatement(query)) {
                stmt.setString(1, value);
                ResultSet rs = stmt.executeQuery();
                if (rs.next() && rs.getInt("count") > 0) {
                    return true;
                }
            }
        }
        return false;
    }

    private void updateDepartmentHead(Connection con, String department, String adminName) throws SQLException {
        String updateSql = "UPDATE departments SET department_head = ? WHERE name = ?";
        try (PreparedStatement stmt = con.prepareStatement(updateSql)) {
            stmt.setString(1, adminName);
            stmt.setString(2, department);
            stmt.executeUpdate();
        }
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