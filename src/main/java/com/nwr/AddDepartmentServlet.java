package com.nwr;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/add-department")
public class AddDepartmentServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        String departmentName = request.getParameter("departmentName");

        if (departmentName == null || departmentName.trim().isEmpty()) {
            response.sendRedirect("superadmin.jsp?error=emptyDepartment");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/defaultdb?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");

            // Check if department already exists
            PreparedStatement check = conn.prepareStatement("SELECT * FROM departments WHERE name = ?");
            check.setString(1, departmentName);
            ResultSet rs = check.executeQuery();

            if (rs.next()) {
                // Department already exists
                response.sendRedirect("superadmin.jsp?error=exists");
            } else {
                // Insert new department
                String sql = "INSERT INTO departments (name) VALUES (?)";
                PreparedStatement pst = conn.prepareStatement(sql);
                pst.setString(1, departmentName);

                int row = pst.executeUpdate();

                if (row > 0) {
                	response.sendRedirect("superadmin.jsp?success=Department Added Successfully");

                } else {
                    response.sendRedirect("superadmin.jsp?error=failed");
                }

                pst.close();
            }

            rs.close();
            check.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("superadmin.jsp?error=exception");
        }
    }
}
