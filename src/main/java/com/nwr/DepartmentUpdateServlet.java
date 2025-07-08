package com.nwr;

import java.io.IOException;
import java.sql.*;
import java.net.URLEncoder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DepartmentUpdateServlet")
public class DepartmentUpdateServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String oldName = request.getParameter("old_name");
        String newName = request.getParameter("new_name");

        if (oldName == null || newName == null || oldName.trim().isEmpty() || newName.trim().isEmpty()) {
            response.sendRedirect("edit-department.jsp?error=Missing+department+name!&name=" +
                    URLEncoder.encode(oldName != null ? oldName : "", "UTF-8"));
            return;
        }

        oldName = oldName.trim();
        newName = newName.trim();

        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement updateDeptStmt = null;
        PreparedStatement updateAdminsStmt = null;
        PreparedStatement updateMembersStmt = null;
        PreparedStatement getIdStmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");

            // 1. First get the department_id for the old name
            String getIdSql = "SELECT department_id FROM departments WHERE name = ?";
            getIdStmt = conn.prepareStatement(getIdSql);
            getIdStmt.setString(1, oldName);
            ResultSet idRs = getIdStmt.executeQuery();

            if (!idRs.next()) {
                response.sendRedirect("edit-department.jsp?error=Department+not+found!&name=" +
                        URLEncoder.encode(oldName, "UTF-8"));
                return;
            }
            int departmentId = idRs.getInt("department_id");
            idRs.close();

            // 2. Check if new name already exists
            String checkSql = "SELECT department_id FROM departments WHERE name = ? AND department_id != ?";
            checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, newName);
            checkStmt.setInt(2, departmentId);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                rs.close();
                response.sendRedirect("edit-department.jsp?error=Department+name+already+exists!&name=" +
                        URLEncoder.encode(oldName, "UTF-8"));
                return;
            }
            rs.close();

            // 3. Update department name
            String updateDeptSql = "UPDATE departments SET name = ? WHERE department_id = ?";
            updateDeptStmt = conn.prepareStatement(updateDeptSql);
            updateDeptStmt.setString(1, newName);
            updateDeptStmt.setInt(2, departmentId);

            int deptUpdated = updateDeptStmt.executeUpdate();
            if (deptUpdated == 0) {
                response.sendRedirect("edit-department.jsp?error=Failed+to+update+department!&name=" +
                        URLEncoder.encode(oldName, "UTF-8"));
                return;
            }

            // 4. Update related tables
            String updateAdminsSql = "UPDATE admins SET department = ? WHERE department = ?";
            updateAdminsStmt = conn.prepareStatement(updateAdminsSql);
            updateAdminsStmt.setString(1, newName);
            updateAdminsStmt.setString(2, oldName);
            updateAdminsStmt.executeUpdate();

            String updateMembersSql = "UPDATE members SET department = ? WHERE department = ?";
            updateMembersStmt = conn.prepareStatement(updateMembersSql);
            updateMembersStmt.setString(1, newName);
            updateMembersStmt.setString(2, oldName);
            updateMembersStmt.executeUpdate();

            // Success redirect
            response.sendRedirect("superadmin.jsp?success=Department+updated+successfully!&name=" +
                    URLEncoder.encode(newName, "UTF-8"));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("edit-department.jsp?error=Database+error:+"
                    + URLEncoder.encode(e.getMessage(), "UTF-8") + "&name=" +
                    URLEncoder.encode(oldName, "UTF-8"));
        } finally {
            try { if (checkStmt != null) checkStmt.close(); } catch (Exception ignored) {}
            try { if (updateDeptStmt != null) updateDeptStmt.close(); } catch (Exception ignored) {}
            try { if (updateAdminsStmt != null) updateAdminsStmt.close(); } catch (Exception ignored) {}
            try { if (updateMembersStmt != null) updateMembersStmt.close(); } catch (Exception ignored) {}
            try { if (getIdStmt != null) getIdStmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}