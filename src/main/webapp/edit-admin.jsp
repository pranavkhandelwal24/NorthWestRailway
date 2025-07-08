<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String id = request.getParameter("id");
    String name = "";
    String username = "";
    String email = "";
    String department = "";
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/defaultdb?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");
        String sql = "SELECT * FROM admins WHERE id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, id);
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            name = rs.getString("name");
            username = rs.getString("username");
            email = rs.getString("email");
            department = rs.getString("department");
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Admin - NWR Super Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Inherit all styles from superadmin.jsp */
        :root {
            --primary: #0056b3;
            --primary-light: #3a7fc5;
            --primary-dark: #003d7a;
            --primary-darker: #002a5a;
            --secondary: #e63946;
            --success: #28a745;
            --warning: #ff9800;
            --light: #f8f9fa;
            --dark: #212529;
            --gray: #6c757d;
            --gray-light: #e9ecef;
            --border: #dee2e6;
            --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
            --transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
            --glass-bg: rgba(255, 255, 255, 0.85);
            --glass-border: rgba(255, 255, 255, 0.3);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, var(--primary-darker), var(--primary-dark));
            color: var(--dark);
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            overflow-x: hidden;
            position: relative;
        }

        body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: url('https://akm-img-a-in.tosshub.com/indiatoday/images/story/202408/vande-bharat-214258491-16x9_0.jpeg?VersionId=i9dEnrtGDe_RiH7z5EqjNJbNPfM4CGLH') center/cover no-repeat;
            opacity: 0.08;
            z-index: -1;
        }

        /* Floating elements */
        .floating-element {
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.05);
            z-index: -1;
            animation: float 15s infinite ease-in-out;
        }
        
        .circle-1 { width: 300px; height: 300px; top: 10%; left: 5%; animation-duration: 20s; }
        .circle-2 { width: 200px; height: 200px; bottom: 15%; right: 10%; animation-duration: 25s; }
        .circle-3 { width: 150px; height: 150px; top: 40%; left: 80%; animation-duration: 18s; }

        @keyframes float {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            25% { transform: translate(20px, -20px) rotate(5deg); }
            50% { transform: translate(-20px, 15px) rotate(-5deg); }
            75% { transform: translate(15px, 20px) rotate(3deg); }
        }

        /* Top Navigation */
        .top-nav {
            background: rgba(0, 42, 90, 0.8); /* primary-darker with transparency */
            backdrop-filter: blur(10px);
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.2);
            z-index: 100;
            position: sticky;
            top: 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .nav-left {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .logo img {
            height: 50px;
            transition: transform 0.3s ease;
        }

        .logo:hover img {
            transform: scale(1.05);
        }

        .nav-title {
            font-size: 1.8rem;
            font-weight: 700;
            letter-spacing: 0.5px;
            background: linear-gradient(to right, #fff, #c1d8ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .nav-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .user-menu {
            position: relative;
            cursor: pointer;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 8px 15px;
            border-radius: 50px;
            background: rgba(255, 255, 255, 0.1);
            transition: var(--transition);
        }

        .user-info:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary-light), var(--primary));
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 1.2rem;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
        }

        .user-details h4 {
            font-size: 1rem;
            margin-bottom: 2px;
            font-weight: 600;
        }

        .user-details p {
            font-size: 0.8rem;
            opacity: 0.9;
        }

        .dropdown-menu {
            position: absolute;
            top: 110%;
            right: 0;
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            box-shadow: var(--card-shadow);
            width: 220px;
            overflow: hidden;
            z-index: 1000;
            display: none;
            border: 1px solid var(--glass-border);
            animation: fadeIn 0.4s ease forwards;
            opacity: 0;
            transform: translateY(10px);
        }

        .dropdown-menu.show {
            display: block;
            opacity: 1;
            transform: translateY(0);
        }

        .dropdown-item {
            padding: 14px 20px;
            color: var(--primary-dark);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 12px;
            transition: var(--transition);
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            font-weight: 500;
        }

        .dropdown-item:last-child {
            border-bottom: none;
        }

        .dropdown-item:hover {
            background: rgba(0, 86, 179, 0.1);
            color: var(--primary);
        }

        .dropdown-item i {
            width: 24px;
            text-align: center;
            color: var(--primary);
        }

        /* Hero Section */
        .hero-section {
            position: relative;
            height: 250px;
            margin-bottom: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .hero-bg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: url('https://www.railway-technology.com/wp-content/uploads/sites/13/2018/06/indianrailways.jpg') center/cover no-repeat;
            filter: brightness(0.5) blur(2px);
            z-index: -2;
        }

        .hero-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(45deg, rgba(0, 42, 90, 0.9), rgba(0, 55, 122, 0.7));
            z-index: -1;
        }

        .hero-content {
            position: relative;
            width: 90%;
            max-width: 1200px;
            text-align: center;
            padding: 40px;
            z-index: 2;
        }

        .hero-card {
            background: var(--glass-bg);
            backdrop-filter: blur(15px);
            border-radius: 25px;
            padding: 30px;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--glass-border);
            animation: floatCard 8s infinite ease-in-out;
        }

        @keyframes floatCard {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            25% { transform: translateY(-10px) rotate(1deg); }
            50% { transform: translateY(0) rotate(0deg); }
            75% { transform: translateY(-10px) rotate(-1deg); }
        }

        .hero-title {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 15px;
            color: var(--primary-dark);
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            background: linear-gradient(to right, var(--primary-dark), var(--primary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        /* Main Content */
        .main-content {
            padding: 0 30px 60px;
            flex: 1;
            max-width: 1000px;
            margin: 0 auto;
            width: 100%;
        }

        .section-title {
            font-size: 2.2rem;
            font-weight: 700;
            color: white;
            margin-bottom: 30px;
            position: relative;
            padding-left: 20px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .section-title::before {
            content: '';
            position: absolute;
            left: 0;
            top: 5px;
            height: 80%;
            width: 8px;
            background: linear-gradient(to bottom, var(--primary-light), var(--primary));
            border-radius: 4px;
        }
        
        .edit-form-container {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 25px;
            padding: 35px;
            margin-bottom: 40px;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--glass-border);
        }
        
        .form-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .form-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--primary-dark);
            position: relative;
            padding-left: 15px;
        }
        
        .form-title::before {
            content: '';
            position: absolute;
            left: 0;
            top: 5px;
            height: 80%;
            width: 5px;
            background: var(--primary);
            border-radius: 3px;
        }
        
        .back-button {
            background: var(--primary-light);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.15);
        }
        
        .back-button:hover {
            background: var(--primary);
            transform: translateY(-3px);
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }

        .form-group {
            margin-bottom: 25px;
            position: relative;
        }

        .form-label {
            display: block;
            margin-bottom: 10px;
            font-weight: 600;
            color: var(--primary-dark);
            font-size: 1.1rem;
        }

        .form-control {
            width: 100%;
            padding: 16px 20px;
            border: 1px solid var(--border);
            border-radius: 12px;
            font-size: 1.05rem;
            transition: var(--transition);
            background: rgba(255, 255, 255, 0.9);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
        }

        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(0, 86, 179, 0.2);
            outline: none;
        }
        
        .btn {
            padding: 16px 30px;
            border: none;
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.15);
            position: relative;
            overflow: hidden;
        }

        .btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: 0.5s;
        }

        .btn:hover::before {
            left: 100%;
        }

        .btn-primary {
            background: linear-gradient(90deg, var(--primary), var(--primary-light));
            color: white;
        }

        .btn-primary:hover {
            background: linear-gradient(90deg, var(--primary-dark), var(--primary));
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0, 86, 179, 0.4);
        }
        
        /* Footer */
        .footer {
            background: rgba(0, 42, 90, 0.9);
            color: white;
            padding: 30px;
            text-align: center;
            margin-top: auto;
            backdrop-filter: blur(10px);
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .footer p {
            font-size: 1rem;
            opacity: 0.8;
            margin: 5px 0;
        }
        
        /* Notification styles */
        .notification {
            padding: 15px 20px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            display: flex;
            align-items: center;
            animation: slideIn 0.3s forwards, fadeOut 0.5s 4.7s forwards;
            position: relative;
            overflow: hidden;
            z-index: 10000;
        }

        .notification::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            width: 6px;
            height: 100%;
        }

        .notification-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .notification-success::before {
            background-color: #28a745;
        }

        .notification-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .notification-error::before {
            background-color: #dc3545;
        }

        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }

        @keyframes fadeOut {
            from { opacity: 1; }
            to { opacity: 0; }
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .hero-title { font-size: 2rem; }
            .section-title { font-size: 1.8rem; }
            .form-title { font-size: 1.5rem; }
            .top-nav { flex-direction: column; gap: 15px; padding: 15px; }
            .nav-left, .nav-right { width: 100%; justify-content: center; }
            .form-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <!-- Floating elements -->
    <div class="floating-element circle-1"></div>
    <div class="floating-element circle-2"></div>
    <div class="floating-element circle-3"></div>
    
    <!-- Top Navigation -->
    <%@ include file="/WEB-INF/navbar.jsp" %>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="hero-bg"></div>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <div class="hero-card">
                <h1 class="hero-title">Edit Admin Details</h1>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <h2 class="section-title">Admin Management</h2>
        
        <!-- Edit Form Container -->
        <div class="edit-form-container">
            <div class="form-header">
                <h3 class="form-title">Edit Admin Information</h3>
                <button class="back-button" onclick="window.location.href='superadmin.jsp'">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </button>
            </div>
            
            <form id="editAdminForm" action="AdminUpdateServlet" method="post">
                <input type="hidden" name="id" value="<%= id %>">
                
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Full Name</label>
                        <input type="text" name="name" value="<%= name %>" class="form-control" placeholder="Enter full name" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Username</label>
                        <input type="text" name="username" value="<%= username %>" class="form-control" placeholder="Enter username" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" value="<%= email %>" class="form-control" placeholder="Enter email" required>
                    </div>
                    
                    <div class="form-group">
    <label class="form-label">Department</label>
    <select name="department" class="form-control" required>
        <option value="">Select Department</option>
        <% 
            try {
                Connection conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/defaultdb?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");
                
                // First, get all departments with null department_head
                String availableDeptsSql = "SELECT name FROM departments WHERE department_head IS NULL";
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(availableDeptsSql);
                
                // Store available departments
                while (rs.next()) {
                    String dept = rs.getString("name");
                    // Only show if it's not the current department (we'll show current department separately)
                    if (!dept.equals(department)) {
                        out.println("<option value='" + dept + "'>" + dept + "</option>");
                    }
                }
                
                // Then add the current department (even if it's not null)
                if (department != null && !department.isEmpty()) {
                    String currentDeptSql = "SELECT name FROM departments WHERE name = ?";
                    PreparedStatement currentStmt = conn.prepareStatement(currentDeptSql);
                    currentStmt.setString(1, department);
                    ResultSet currentRs = currentStmt.executeQuery();
                    
                    if (currentRs.next()) {
                        String currentDept = currentRs.getString("name");
                        out.println("<option value='" + currentDept + "' selected>" + currentDept + " (Current)</option>");
                    }
                    currentRs.close();
                    currentStmt.close();
                }
                
                rs.close();
                stmt.close();
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        %>
    </select>
</div>
                </div>
                
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Update Admin
                </button>
            </form>
        </div>
    </div>

    <!-- Footer -->
    <div class="footer">
        <p>© 2023 North Western Railway. All rights reserved.</p>
        <p>Railway Management System | Super Admin Dashboard</p>
        <p>Designed with <i class="fas fa-heart" style="color: var(--secondary);"></i> for efficient railway administration</p>
    </div>
    
    <!-- Notification container -->
    <div id="notificationContainer" style="position: fixed; top: 20px; right: 20px; max-width: 400px; z-index: 10000; display: flex; flex-direction: column; gap: 10px;"></div>
    
    <script>
        // Notification function
        function showNotification(type, message) {
            const container = document.getElementById('notificationContainer');
            const notification = document.createElement('div');
            
            // Determine icon and title based on type
            let iconClass, title;
            if (type === 'success') {
                iconClass = 'fa-check-circle';
                title = 'Success!';
            } else if (type === 'error') {
                iconClass = 'fa-exclamation-circle';
                title = 'Error!';
            } else {
                iconClass = 'fa-info-circle';
                title = 'Notice!';
            }
            
            // Build notification HTML
            notification.className = 'notification notification-' + type;
            
            // Add refresh button for success notifications
            const refreshButton = type === 'success' ? 
                '<button class="btn-refresh" style="' +
                    'background: rgba(0, 86, 179, 0.1);' +
                    'border: none;' +
                    'margin-left: 15px;' +
                    'padding: 8px 15px;' +
                    'border-radius: 6px;' +
                    'cursor: pointer;' +
                    'color: var(--primary-dark);' +
                    'font-weight: 600;' +
                '">' +
                    '<i class="fas fa-sync-alt"></i> Refresh' +
                '</button>' : '';
            
            notification.innerHTML = 
                '<i class="fas ' + iconClass + '" style="font-size: 1.5rem; margin-right: 15px;"></i>' +
                '<div style="flex-grow: 1;">' +
                    '<strong>' + title + '</strong> ' + 
                    escapeHtml(message) +
                '</div>' +
                refreshButton +
                '<button class="notification-close" style="' +
                    'background: none;' +
                    'border: none;' +
                    'margin-left: 15px;' +
                    'cursor: pointer;' +
                    'color: inherit;' +
                '">' +
                    '<i class="fas fa-times"></i>' +
                '</button>';
            
            // Prepend to show newest on top
            container.insertBefore(notification, container.firstChild);
            
            // Auto-remove after 8 seconds (longer for success messages)
            const removeTimeout = setTimeout(() => {
                notification.style.animation = 'fadeOut 0.5s forwards';
                setTimeout(() => notification.remove(), 500);
            }, type === 'success' ? 8000 : 5000);
            
            // Manual close
            notification.querySelector('.notification-close').addEventListener('click', () => {
                clearTimeout(removeTimeout);
                notification.style.animation = 'fadeOut 0.3s forwards';
                setTimeout(() => notification.remove(), 300);
            });
            
            // Add refresh functionality for success notifications
            if (type === 'success') {
                notification.querySelector('.btn-refresh').addEventListener('click', () => {
                    location.reload();
                });
            }
        }
        
        // Helper function to escape HTML special characters
        function escapeHtml(unsafe) {
            return unsafe
                 .replace(/&/g, "&amp;")
                 .replace(/</g, "&lt;")
                 .replace(/>/g, "&gt;")
                 .replace(/"/g, "&quot;")
                 .replace(/'/g, "&#039;");
        }
        
        
        
        // Check for URL parameters to show notifications
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const success = urlParams.get('success');
            const error = urlParams.get('error');
            
            if (success) {
                showNotification('success', success);
            }
            
            if (error) {
                showNotification('error', error);
            }
        });
    </script>
</body>
</html>