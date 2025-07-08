<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("username") == null || session.getAttribute("role") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userrole = session.getAttribute("role").toString();
    String username = session.getAttribute("username").toString();

    String name = "";
    String email = "";
    String currentUsername = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/register2", "root", "root");
        String sql = "";
        if ("superadmin".equals(userrole)) {
            sql = "SELECT * FROM superadmins WHERE username = ?";
        } else if ("admin".equals(userrole)) {
            sql = "SELECT * FROM admins WHERE username = ?";
        } else if ("member".equals(userrole)) {
            sql = "SELECT * FROM members WHERE username = ?";
        }
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, username);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            name = rs.getString("name");
            email = rs.getString("email");
            currentUsername = rs.getString("username");
        }
        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Profile</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/edit-profile.css">
</head>
<body>
    <!-- Floating elements -->
    <div class="floating-element circle-1"></div>
    <div class="floating-element circle-2"></div>
    <div class="floating-element circle-3"></div>

    <%@ include file="/WEB-INF/navbar.jsp" %>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="hero-bg"></div>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <div class="hero-card">
                <h1 class="hero-title">Edit Profile</h1>
            </div>
        </div>
    </div>

    <div class="main-content">
        <h2 class="section-title">Edit Profile</h2>

        <div class="edit-form-container">
            <div class="form-header">
                <h3 class="form-title">Edit Your Profile</h3>
                <button class="back-button" onclick="window.location.href='<%= userrole %>.jsp'">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </button>
            </div>

            <form id="editProfileForm" action="EditProfileServlet" method="post">
                <input type="hidden" name="role" value="<%= userrole %>">

                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Full Name</label>
                        <input type="text" name="name" value="<%= name %>" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Username</label>
                        <input type="text" name="username" value="<%= currentUsername %>" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" value="<%= email %>" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Current Password</label>
                        <input type="password" name="currentPassword" class="form-control" placeholder="Enter current password">
                    </div>

                    <div class="form-group">
                        <label class="form-label">New Password</label>
                        <input type="password" name="newPassword" class="form-control" placeholder="Enter new password">
                    </div>
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Update Profile
                </button>
            </form>
        </div>
    </div>

    <!-- Footer -->
    <div class="footer">
        <p>© 2023 North Western Railway. All rights reserved.</p>
        <p>Railway Management System | <%= userrole %> Dashboard</p>
        <p>Designed with <i class="fas fa-heart" style="color: #e63946;"></i> for efficient railway administration</p>
    </div>

    <!-- Notifications -->
    <div id="notificationContainer" style="position: fixed; top: 20px; right: 20px; z-index: 9999; max-width: 350px;"></div>

    <%@ include file="WEB-INF/notif.jsp" %>
</body>
</html>
