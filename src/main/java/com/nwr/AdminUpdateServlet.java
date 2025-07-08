package com.nwr;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AdminUpdateServlet")
public class AdminUpdateServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String newDepartment = request.getParameter("department");

        Connection conn = null;
        try {
            conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");
            // Start transaction
            conn.setAutoCommit(false);
            
            // Get current admin details
            String oldSql = "SELECT name, department FROM admins WHERE id = ?";
            String oldName = "";
            String oldDepartment = "";
            
            try (PreparedStatement oldStmt = conn.prepareStatement(oldSql)) {
                oldStmt.setInt(1, Integer.parseInt(id));
                ResultSet rs = oldStmt.executeQuery();
                if (rs.next()) {
                    oldName = rs.getString("name");
                    oldDepartment = rs.getString("department");
                }
            }
            
            // Check for duplicate username/email
            String checkSql = "SELECT id FROM admins WHERE (username = ? OR email = ?) AND id != ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, username);
                checkStmt.setString(2, email);
                checkStmt.setInt(3, Integer.parseInt(id));
                ResultSet rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    conn.rollback();
                    response.sendRedirect("edit-admin.jsp?id=" + id + "&error=Username or email already exists");
                    return;
                }
            }
            
            // Update admin
            String updateSql = "UPDATE admins SET name = ?, username = ?, email = ?, department = ? WHERE id = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setString(1, name);
                updateStmt.setString(2, username);
                updateStmt.setString(3, email);
                updateStmt.setString(4, newDepartment);
                updateStmt.setInt(5, Integer.parseInt(id));
                int rowsUpdated = updateStmt.executeUpdate();
                
                if (rowsUpdated == 0) {
                    conn.rollback();
                    response.sendRedirect("edit-admin.jsp?id=" + id + "&error=No admin found with ID: " + id);
                    return;
                }
            }
            
            // Handle department head updates
            if (!oldDepartment.equals(newDepartment)) {
                // Remove from old department head
                String removeHeadSql = "UPDATE departments SET department_head = NULL WHERE name = ? AND department_head = ?";
                try (PreparedStatement removeStmt = conn.prepareStatement(removeHeadSql)) {
                    removeStmt.setString(1, oldDepartment);
                    removeStmt.setString(2, oldName);
                    removeStmt.executeUpdate();
                }
                
                // Add to new department head
                String setHeadSql = "UPDATE departments SET department_head = ? WHERE name = ?";
                try (PreparedStatement setHeadStmt = conn.prepareStatement(setHeadSql)) {
                    setHeadStmt.setString(1, name);
                    setHeadStmt.setString(2, newDepartment);
                    setHeadStmt.executeUpdate();
                }
            } else if (!oldName.equals(name)) {
                // Update name in current department head
                String updateHeadSql = "UPDATE departments SET department_head = ? WHERE name = ? AND department_head = ?";
                try (PreparedStatement updateHeadStmt = conn.prepareStatement(updateHeadSql)) {
                    updateHeadStmt.setString(1, name);
                    updateHeadStmt.setString(2, oldDepartment);
                    updateHeadStmt.setString(3, oldName);
                    updateHeadStmt.executeUpdate();
                }
            }
            
            // Commit transaction
            conn.commit();
            response.sendRedirect("superadmin.jsp?success=Admin updated successfully");
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            response.sendRedirect("edit-admin.jsp?id=" + id + "&error=Database error: " + e.getMessage());
        } catch (NumberFormatException e) {
            response.sendRedirect("edit-admin.jsp?id=" + id + "&error=Invalid admin ID format");
        } finally {
            // Close connection in finally block
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}