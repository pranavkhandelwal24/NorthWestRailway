package com.nwr;

import java.io.*;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/member-delete")
public class MemberDeleteServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
	  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		String id = request.getParameter("id");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        
        if (id == null || id.isEmpty()) {
            out.print("{\"status\":\"error\",\"message\":\"Member ID is required\"}");
            return;
        }
        
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv")) {
            String sql = "UPDATE members SET status = 'inactive' WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, Integer.parseInt(id));
                int rowsAffected = stmt.executeUpdate();
                
                if (rowsAffected > 0) {
                    out.print("{\"status\":\"success\",\"message\":\"Member deleted successfully\"}");
                } else {
                    out.print("{\"status\":\"error\",\"message\":\"Member not found\"}");
                }
            }
        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\",\"message\":\"Invalid member ID format\"}");
        } catch (SQLException e) {
            out.print("{\"status\":\"error\",\"message\":\"Database error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
	@Override
	  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
	    doPost(request, response);
	  }
}