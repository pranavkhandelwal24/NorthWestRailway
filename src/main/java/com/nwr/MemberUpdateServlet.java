package com.nwr;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/MemberUpdateServlet")
public class MemberUpdateServlet extends HttpServlet {
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
        String department = request.getParameter("department");

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/register2", "root", "root")) {
            // Check for duplicate username/email
            String checkSql = "SELECT id FROM members WHERE (username = ? OR email = ?) AND id != ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, username);
                checkStmt.setString(2, email);
                checkStmt.setInt(3, Integer.parseInt(id));
                ResultSet rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    response.sendRedirect("edit-member.jsp?id=" + id + "&error=Username or email already exists");
                    return;
                }
            }
            
            // Update member
            String updateSql = "UPDATE members SET name = ?, username = ?, email = ?, department = ? WHERE id = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setString(1, name);
                updateStmt.setString(2, username);
                updateStmt.setString(3, email);
                updateStmt.setString(4, department);
                updateStmt.setInt(5, Integer.parseInt(id));
                int rowsUpdated = updateStmt.executeUpdate();
                
                if (rowsUpdated > 0) {
                    response.sendRedirect("superadmin.jsp?success=Member updated successfully");
                } else {
                    response.sendRedirect("edit-member.jsp?id=" + id + "&error=No member found with ID: " + id);
                }
            }
            
        } catch (SQLException e) {
            response.sendRedirect("edit-member.jsp?id=" + id + "&error=Database error: " + e.getMessage());
        } catch (NumberFormatException e) {
            response.sendRedirect("edit-member.jsp?id=" + id + "&error=Invalid member ID format");
        }
    }
}