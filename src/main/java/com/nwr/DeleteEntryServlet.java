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
  // ⚠️ You are sending `username=ID` in fetch!
        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : null;

        if (username == null) {
            out.print("{\"status\":\"error\",\"message\":\"User not logged in.\"}");
            return;
        }

        if (ifile_no == null || ifile_no.isEmpty()) {
            out.print("{\"status\":\"error\",\"message\":\"File number is required.\"}");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            int ifileNo = Integer.parseInt(ifile_no);

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");

            String sql = "DELETE FROM register_entries WHERE ifile_no = ? AND username = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, ifileNo);
            pstmt.setString(2, username);

            int rowsAffected = pstmt.executeUpdate();

            if (rowsAffected > 0) {
                out.print("{\"status\":\"success\",\"message\":\"Entry deleted successfully.\"}");
            } else {
                out.print("{\"status\":\"error\",\"message\":\"File not found or not owned by user.\"}");
            }

        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\",\"message\":\"Invalid file number.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\",\"message\":\"Error deleting entry: " +
                    e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }
}
