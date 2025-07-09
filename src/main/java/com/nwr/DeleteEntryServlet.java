package com.nwr;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/delete-entry")
public class DeleteEntryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String ifile_no = request.getParameter("ifile_no");
        HttpSession session = request.getSession(false);
        
        if (session == null) {
            out.print("{\"status\":\"error\",\"message\":\"User not logged in.\"}");
            return;
        }

        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        String department = (String) session.getAttribute("department");

        if (username == null || role == null) {
            out.print("{\"status\":\"error\",\"message\":\"Session information incomplete.\"}");
            return;
        }

        if (ifile_no == null || ifile_no.isEmpty()) {
            out.print("{\"status\":\"error\",\"message\":\"File number is required.\"}");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            int ifileNo = Integer.parseInt(ifile_no);

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");


            // For superadmin - can delete any entry
            if ("superadmin".equals(role)) {
                String sql = "DELETE FROM register_entries WHERE ifile_no = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, ifileNo);
            } 
            // For admin - can delete only entries from their department
            else if ("admin".equals(role)) {
                // First check if the entry belongs to their department
                String checkSql = "SELECT department FROM register_entries WHERE ifile_no = ?";
                pstmt = conn.prepareStatement(checkSql);
                pstmt.setInt(1, ifileNo);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    String entryDepartment = rs.getString("department");
                    if (entryDepartment != null && entryDepartment.equals(department)) {
                        // Close the previous statement and result set
                        pstmt.close();
                        rs.close();
                        
                        // Proceed with deletion
                        String deleteSql = "DELETE FROM register_entries WHERE ifile_no = ?";
                        pstmt = conn.prepareStatement(deleteSql);
                        pstmt.setInt(1, ifileNo);
                    } else {
                        out.print("{\"status\":\"error\",\"message\":\"You can only delete entries from your department.\"}");
                        return;
                    }
                } else {
                    out.print("{\"status\":\"error\",\"message\":\"Entry not found.\"}");
                    return;
                }
            } 
            // For regular members - can delete only their own entries
            else {
                String sql = "DELETE FROM register_entries WHERE ifile_no = ? AND username = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, ifileNo);
                pstmt.setString(2, username);
            }

            int rowsAffected = pstmt.executeUpdate();

            if (rowsAffected > 0) {
                out.print("{\"status\":\"success\",\"message\":\"Entry deleted successfully.\"}");
            } else {
                out.print("{\"status\":\"error\",\"message\":\"Entry not found or you don't have permission to delete it.\"}");
            }

        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\",\"message\":\"Invalid file number.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\",\"message\":\"Error deleting entry: " +
                    e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }
}