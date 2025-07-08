package com.nwr;

import java.io.*;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/admin-delete")
public class AdminDeleteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String id = request.getParameter("id");
        if (id == null || id.isEmpty()) {
            out.print("{\"status\":\"error\",\"message\":\"Admin ID is required\"}");
            return;
        }

        Connection conn = null;
        PreparedStatement getNameStmt = null;
        PreparedStatement deactivateStmt = null;
        PreparedStatement updateDeptStmt = null;
        ResultSet rs = null;

        try {
        	conn = DAOConnection.getConnection();

            conn.setAutoCommit(false); // ✅ Start transaction

            // 1️⃣ Get the admin's name
            String getNameSql = "SELECT name FROM admins WHERE id = ?";
            getNameStmt = conn.prepareStatement(getNameSql);
            getNameStmt.setInt(1, Integer.parseInt(id));
            rs = getNameStmt.executeQuery();

            String adminName = null;
            if (rs.next()) {
                adminName = rs.getString("name");
            } else {
                out.print("{\"status\":\"error\",\"message\":\"Admin not found\"}");
                return;
            }

            // 2️⃣ Deactivate the admin
            String deactivateSql = "UPDATE admins SET status = 'inactive' WHERE id = ?";
            deactivateStmt = conn.prepareStatement(deactivateSql);
            deactivateStmt.setInt(1, Integer.parseInt(id));
            deactivateStmt.executeUpdate();

            // 3️⃣ Update departments where this admin is head
            String updateDeptSql = "UPDATE departments SET department_head = NULL WHERE department_head = ?";
            updateDeptStmt = conn.prepareStatement(updateDeptSql);
            updateDeptStmt.setString(1, adminName);
            updateDeptStmt.executeUpdate();

            conn.commit(); // ✅ Commit both updates

            out.print("{\"status\":\"success\",\"message\":\"Admin deleted successfully\"}");

        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\",\"message\":\"Invalid admin ID format\"}");
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                // ignore rollback error
            }
            out.print("{\"status\":\"error\",\"message\":\"Database error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore) {}
            try { if (getNameStmt != null) getNameStmt.close(); } catch (Exception ignore) {}
            try { if (deactivateStmt != null) deactivateStmt.close(); } catch (Exception ignore) {}
            try { if (updateDeptStmt != null) updateDeptStmt.close(); } catch (Exception ignore) {}
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignore) {}
        }
    }
}
