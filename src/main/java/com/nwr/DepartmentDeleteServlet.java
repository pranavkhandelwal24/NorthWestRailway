package com.nwr;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/department-delete")
public class DepartmentDeleteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String departmentName = request.getParameter("departmentName");

        if (departmentName == null || departmentName.isEmpty()) {
            out.print("{\"status\":\"error\",\"message\":\"Department Name is required\"}");
            return;
        }

        Connection conn = null;
        PreparedStatement deleteDeptStmt = null;
        PreparedStatement updateMembersStmt = null;
        PreparedStatement updateAdminsStmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");

            // === Start transaction ===
            conn.setAutoCommit(false);

            // 1️⃣ Update all members using this department → set to 'Not Assigned'
            String updateMembersSQL = "UPDATE members SET department = 'Not Assigned' WHERE department = ?";
            updateMembersStmt = conn.prepareStatement(updateMembersSQL);
            updateMembersStmt.setString(1, departmentName);
            updateMembersStmt.executeUpdate();

            // 2️⃣ Update all admins using this department → set to 'Not Assigned'
            String updateAdminsSQL = "UPDATE admins SET department = 'Not Assigned' WHERE department = ?";
            updateAdminsStmt = conn.prepareStatement(updateAdminsSQL);
            updateAdminsStmt.setString(1, departmentName);
            updateAdminsStmt.executeUpdate();

            // 3️⃣ Now delete the department from departments table
            String deleteDeptSQL = "DELETE FROM departments WHERE name = ?";
            deleteDeptStmt = conn.prepareStatement(deleteDeptSQL);
            deleteDeptStmt.setString(1, departmentName);
            int rowsAffected = deleteDeptStmt.executeUpdate();

            if (rowsAffected > 0) {
                // ✅ Commit transaction
                conn.commit();
                out.print("{\"status\":\"success\",\"message\":\"Department deleted successfully\"}");
            } else {
                conn.rollback();
                out.print("{\"status\":\"error\",\"message\":\"Department not found\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (Exception rollbackEx) {
                rollbackEx.printStackTrace();
            }
            out.print("{\"status\":\"error\",\"message\":\"Error deleting department: " +
                    e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            try { if (updateMembersStmt != null) updateMembersStmt.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (updateAdminsStmt != null) updateAdminsStmt.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (deleteDeptStmt != null) deleteDeptStmt.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }
}
