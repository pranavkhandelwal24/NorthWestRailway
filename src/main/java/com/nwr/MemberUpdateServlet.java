package com.nwr;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/MemberUpdateServlet")
public class MemberUpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get user role from session
        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("role");
        
        // Determine redirect URL based on role
        String redirectUrl = "superadmin.jsp"; // default
        if ("admin".equals(userRole)) {
            redirectUrl = "admin.jsp";
        }

        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String department = request.getParameter("department");

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv")) {
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
            
            // For admin users, verify they're not trying to change department
            if ("admin".equals(userRole)) {
                String currentDeptSql = "SELECT department FROM members WHERE id = ?";
                try (PreparedStatement deptStmt = conn.prepareStatement(currentDeptSql)) {
                    deptStmt.setInt(1, Integer.parseInt(id));
                    ResultSet rs = deptStmt.executeQuery();
                    if (rs.next()) {
                        String currentDept = rs.getString("department");
                        if (!currentDept.equals(department)) {
                            response.sendRedirect("edit-member.jsp?id=" + id + "&error=Unauthorized department change");
                            return;
                        }
                    }
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
                    response.sendRedirect(redirectUrl + "?success=Member updated successfully");
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