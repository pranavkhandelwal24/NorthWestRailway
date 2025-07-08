package com.nwr;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/edit-entry")
public class EditEntryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        // Check if user is logged in
        if (session.getAttribute("username") == null || session.getAttribute("role") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role = session.getAttribute("role").toString();
        String ifile_no = request.getParameter("ifile_no");
        String vetted_cost = request.getParameter("vetted_cost");
        String savings = request.getParameter("savings");
        String putup_date = request.getParameter("putup_date");
        String dispatch_date = request.getParameter("dispatch_date");
        String status = request.getParameter("status");

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/register2", "root", "root")) {
            // Update the entry
            String sql = "UPDATE register_entries SET vetted_cost = ?, savings = ?, putup_date = ?, dispatch_date = ?, status = ? WHERE ifile_no = ?";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                // Set parameters - handle null values
                stmt.setString(1, vetted_cost.isEmpty() ? null : vetted_cost);
                stmt.setString(2, savings.isEmpty() ? null : savings);
                stmt.setString(3, putup_date.isEmpty() ? null : putup_date);
                stmt.setString(4, dispatch_date.isEmpty() ? null : dispatch_date);
                stmt.setString(5, status.isEmpty() ? null : status);
                stmt.setString(6, ifile_no);
                
                int rows = stmt.executeUpdate();
                if (rows > 0) {
                    response.sendRedirect(role + ".jsp?success=" + URLEncoder.encode("File entry updated successfully", "UTF-8"));
                } else {
                    response.sendRedirect("edit-entry.jsp?ifile_no=" + ifile_no + "&error=" + 
                            URLEncoder.encode("Failed to update file entry", "UTF-8"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("edit-entry.jsp?ifile_no=" + ifile_no + "&error=" + 
                    URLEncoder.encode("Server error: " + e.getMessage(), "UTF-8"));
        }
    }
}