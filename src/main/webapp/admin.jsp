<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<%
    // Check authentication first
    if (session.getAttribute("username") == null || session.getAttribute("role") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Check if user is admin
    if (!"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String adminName = (String) session.getAttribute("name");
    String adminUsername = (String) session.getAttribute("username");
%>

<%
    // First, get the admin's department from the admins table
    String adminDepartment = null;
    Connection adminConn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        adminConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/register2", "root", "root");
        
        PreparedStatement adminStmt = adminConn.prepareStatement("SELECT department FROM admins WHERE username = ?");
        adminStmt.setString(1, adminUsername);
        ResultSet adminRs = adminStmt.executeQuery();
        
        if (adminRs.next()) {
            adminDepartment = adminRs.getString("department");
            session.setAttribute("department", adminDepartment); // Store in session for future use
        }
        
        adminRs.close();
        adminStmt.close();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (adminConn != null) {
            try { adminConn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    if (adminDepartment == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%
    // Load file entries
    String searchFile = request.getParameter("searchFile");
    List<String[]> allEntries = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/register2", "root", "root");

        String query = "SELECT * FROM register_entries";
        if (searchFile != null && !searchFile.trim().isEmpty()) {
            query += " AND ifile_no = ?";
        }

        PreparedStatement ps = conn.prepareStatement(query);
        
        if (searchFile != null && !searchFile.trim().isEmpty()) {
            try {
                ps.setInt(2, Integer.parseInt(searchFile.trim()));
            } catch (NumberFormatException e) {
                // Handle error
            }
        }

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            allEntries.add(new String[]{
                String.valueOf(rs.getInt("ifile_no")),
                String.valueOf(rs.getInt("efile_no")),
                rs.getString("username"),
                rs.getString("department"),
                rs.getString("system"),
                rs.getString("details"),
                rs.getString("function_year"),
                rs.getString("subject"),
                rs.getString("proposed_cost"),
                rs.getString("vetted_cost"),
                rs.getString("savings"),
                rs.getString("received_date"),
                rs.getString("putup_date"),
                rs.getString("dispatch_date"),
                rs.getString("status")
            });
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<%
    // Load department members
    List<String[]> departmentMembers = new ArrayList<>();
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/register2", "root", "root");

        PreparedStatement memberStmt = conn.prepareStatement("SELECT * FROM members WHERE department = ? AND status='active'");
        memberStmt.setString(1, adminDepartment);
        
        ResultSet memberRs = memberStmt.executeQuery();
        
        while (memberRs.next()) {
            String[] member = {
                memberRs.getString("id"),
                memberRs.getString("name"),
                memberRs.getString("username"),
                memberRs.getString("email"),
                memberRs.getString("department")
            };
            departmentMembers.add(member);
        }
        
        memberRs.close();
        memberStmt.close();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head> 
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NWR Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/superadmin.css">
    <style>
        /* Report Buttons Section */
        #dateInputSection {
            margin-bottom: 30px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
        }

        .report-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 20px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
        }

        .report-buttons h4 {
            width: 100%;
            color: var(--primary-dark);
            margin-bottom: 15px;
            font-size: 1.2rem;
            font-weight: 600;
        }

        .btn-report {
            padding: 12px 25px;
            background: linear-gradient(135deg, var(--primary), var(--primary-light));
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 4px 10px rgba(0, 86, 179, 0.2);
            min-width: 120px;
            text-align: center;
        }

        .btn-report:hover {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 86, 179, 0.3);
        }

        .btn-report i {
            font-size: 1.1rem;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .report-buttons {
                flex-direction: column;
            }
            
            .btn-report {
                width: 100%;
            }
        }
    </style>
</head>
<body>
   
   <!-- Floating elements -->
    <div class="floating-element circle-1"></div>
    <div class="floating-element circle-2"></div>
    <div class="floating-element circle-3"></div>
    
    <!-- Custom confirmation dialog -->
    <div class="confirmation-dialog" id="confirmationDialog">
        <div class="confirmation-box">
            <h3 class="confirmation-title">
                <i class="fas fa-exclamation-triangle"></i>
                Confirm Deletion
            </h3>
            <p class="confirmation-message" id="confirmationMessage">
                Are you sure you want to delete this user?
            </p>
            <div class="confirmation-actions">
                <button class="btn-cancel" id="cancelDelete">Cancel</button>
                <button class="btn-confirm" id="confirmDelete">Delete</button>
            </div>
        </div>
    </div>
    
    <!-- Top Navigation -->
    <%@ include file="/WEB-INF/navbar.jsp" %>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="hero-bg"></div>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <div class="hero-card">
                <h1 class="hero-title">Admin Dashboard</h1>
                <p class="hero-description">
                    Manage your department operations efficiently with our comprehensive admin tools. 
                    Monitor members and manage reports.
                </p>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <h2 class="section-title">Management Dashboard</h2>
        
        <!-- Feature Cards -->
        <div class="features">
            <div class="feature-card" id="memberManagementCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3 class="feature-title">Member Management</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        Manage all members in your department. Add new members, 
                        edit existing profiles.
                    </p>
                </div>
            </div>
            
            <div class="feature-card" id="entriesManagementCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-file-alt"></i>
                    </div>
                    <h3 class="feature-title">Manage Entries &amp; Generate Reports</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        View and manage all file entries across departments. Generate comprehensive reports 
                        for analysis and record-keeping.
                    </p>
                </div>
            </div>
        </div>
        
        <!-- Member Management Section -->
        <div class="management-section" id="memberManagementSection">
            <div class="section-header">
                <h3 class="section-subtitle">Member Management</h3>
                <button class="close-section" onclick="closeSection('memberManagementSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="user-type-tabs">
                <div class="user-type-tab active" data-target="manageMembers">Manage Members</div>
                <div class="user-type-tab" data-target="addMember">Add Member</div>
            </div>
            
            <!-- Manage Members -->
            <div class="user-form-section active" id="manageMembers">
                <h4>Active Members in <%= adminDepartment %></h4>
                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Username</th>
                                <th>Email</th>
                                <th>Department</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(departmentMembers.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 40px;">
                                        <i class="fas fa-user-slash" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                        <h4 style="color: var(--primary);">No Active Members Found</h4>
                                        <p style="color: var(--gray);">All members are inactive or not created yet</p>
                                    </td>
                                </tr>
                            <% } else { %>
                                <% for(String[] member : departmentMembers) { %>
                                    <tr>
                                        <td><%= member[0] %></td>
                                        <td><%= member[1] %></td>
                                        <td><%= member[2] %></td>
                                        <td><%= member[3] %></td>
                                        <td><%= member[4] %></td>
                                        <td class="actions">
                                            <a href="edit-member.jsp?id=<%=member[0]%>&type=member" 
                                            class="btn-edit" 
                                                    data-id="<%= member[0] %>"
                                                    data-type="member"
                                                    style="text-decoration: none;">
                                                <i class="fas fa-edit"></i> Edit
                                            </a>
                                            <button type="button"
                                               class="btn-delete"
                                               data-id="<%= member[0] %>"
                                               data-type="member">
                                               <i class="fas fa-trash"></i> 
                                            </button>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Add Member -->
            <div class="user-form-section" id="addMember">
                <h4>Add New Member to <%= adminDepartment %></h4>
                <form id="addMemberForm">
                    <input type="hidden" name="department" value="<%= adminDepartment %>">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Full Name</label>
                            <input type="text" id="name" name="name" class="form-control" placeholder="Enter full name" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Username</label>
                            <input type="text" id="username" name="username" class="form-control" placeholder="Enter username" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <input type="email" id="email" name="email" class="form-control" placeholder="Enter email" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Password</label>
                            <div class="password-wrapper">
                                <input type="password" id="passwordField" name="password" class="form-control" placeholder="Create password" required>
                                <span class="toggle-password" id="togglePassword">
                                    <i class="fas fa-eye"></i>
                                </span>
                            </div>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary" id="submitBtn">
                        <i class="fas fa-plus"></i> Add Member
                    </button>
                </form>
            </div>
        </div>
    
        <!-- Entries Management Section -->
        <div class="management-section" id="entriesManagementSection">
            <div class="section-header">
                <h3 class="section-subtitle">Entries</h3>
                <button class="close-section" onclick="closeSection('entriesManagementSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <!-- Search Files -->
            <div class="form-group">
                <form method="get" action="admin.jsp">
                    <label class="form-label">Search by Internal File Number</label>
                    <div style="display: flex; gap: 10px;">
                        <input type="text" name="searchFile" class="form-control" 
                               placeholder="Enter internal file number" 
                               value="<%= (searchFile != null) ? searchFile : "" %>">
                        <button type="submit" class="btn btn-primary" style="width: auto;">
                            <i class="fas fa-search"></i> Search
                        </button>
                        <% if (searchFile != null && !searchFile.isEmpty()) { %>
                            <a href="admin.jsp" class="btn btn-primary" style="width: auto;">
                                <i class="fas fa-times"></i> Clear
                            </a>
                        <% } %>
                    </div>
                </form>
            </div>
            
            <!-- Files Table -->
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Sr No.</th>
                            <th>Username</th>
                            <th>Department</th>
                            <th>System</th>
                            <th>Internal File No</th>
                            <th>External File No</th>
                            <th>Details</th>
                            <th>Function Year</th>
                            <th>Subject</th>
                            <th>Proposed Cost</th>
                            <th>Vetted Cost</th>
                            <th>Savings</th>
                            <th>Received Date</th>
                            <th>Putup Date</th>
                            <th>Dispatch Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (allEntries.isEmpty()) { %>
                            <tr>
                                <td colspan="17" style="text-align: center; padding: 40px;">
                                    <i class="fas fa-file-alt" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                    <h4 style="color: var(--primary);">No Files Found</h4>
                                    <p style="color: var(--gray);">No file entries exist in the system yet</p>
                                </td>
                            </tr>
                        <% } else { 
                            int srNo = 1;
                            for (String[] entry : allEntries) { 
                        %>
                        <tr>
                            <td><%= srNo++ %></td>
                            <td><%= entry[2] != null ? entry[2] : '-' %></td>
                            <td><%= entry[3] != null ? entry[3] : '-' %></td>
                            <td><%= entry[4] != null ? entry[4] : '-' %></td>
                            <td><%= entry[0] != null ? entry[0] : '-' %></td>
                            <td><%= entry[1] != null ? entry[1] : '-' %></td>
                            <td><%= entry[5] != null ? entry[5] : '-' %></td>
                            <td><%= entry[6] != null ? entry[6] : '-' %></td>
                            <td class="subject-cell" title="<%= entry[7] != null ? entry[7] : '-' %>">
                                <%= entry[7] != null ? entry[7] : '-' %>
                            </td>
                            <td><%= entry[8] != null ? entry[8] : '-' %></td>
                            <td><%= entry[9] != null ? entry[9] : '-' %></td>
                            <td><%= entry[10] != null ? entry[10] : '-' %></td>
                            <td><%= entry[11] != null ? entry[11] : '-' %></td>
                            <td><%= entry[12] != null ? entry[12] : '-' %></td>
                            <td><%= entry[13] != null ? entry[13] : '-' %></td>
                            <td>
                                <span class="badge" style="background: <%= "V".equals(entry[14]) ? "rgba(40, 167, 69, 0.15)" : "rgba(220, 53, 69, 0.15)" %>; 
                                    color: <%= "V".equals(entry[14]) ? "#28a745" : "#dc3545" %>;">
                                    <%= entry[14] != null ? entry[14] : '-' %>
                                </span>
                            </td>
                            <td class="actions">
                                <button class="btn-edit" onclick="location.href='edit-entry.jsp?ifile_no=<%= entry[0] %>'">
                                    <i class="fas fa-edit"></i> Edit
                                </button>
                                <button type="button"
                                       class="btn-delete"
                                       data-id="<%= entry[0] %>"
                                       data-type="entry">
                                       <i class="fas fa-trash"></i> 
                                </button>
                            </td>
                        </tr>
                        <% } 
                        } %>
                    </tbody>
                </table>
            </div>
            
            <div style="margin-top: 50px;"></div>
            <div class="section-header">
              <h3 class="section-subtitle">Generate Reports</h3>
            </div>
    
            <!-- Date Input Section -->
            <div class="form-group" id="dateInputSection">
                <label class="form-label">Select Reference Date</label>
                <div style="display: flex; gap: 10px;">
                    <input type="date" id="reportReferenceDate" class="form-control" required>
                    <button type="button" class="btn btn-primary" onclick="setReportDate()" style="width: auto;">
                        <i class="fas fa-calendar-check"></i> Set Date
                    </button>
                </div>
            </div>
            
            <!-- Report Buttons (initially hidden) -->
            <div class="report-buttons" id="reportButtons" style="display: none; margin-top: 20px;">
                <h4>Generate Report for Last:</h4>
                <div style="display: flex; gap: 10px; margin-top: 10px;">
                    <button onclick="generateReportFromDate(7)" class="btn-report">
                        <i class="fas fa-file-clipboard"></i> 7 Days
                    </button>
                    <button onclick="generateReportFromDate(10)" class="btn-report">
                        <i class="fas fa-file-pdf"></i> 10 Days
                    </button>
                    <button onclick="generateReportFromDate(30)" class="btn-report">
                        <i class="fas fa-file-excel"></i> 30 Days
                    </button>
                </div>
            </div>
        </div>
    
        <%@ include file="/WEB-INF/importantlinks.jsp" %>
    </div>
    
    <!-- Footer -->
    <div class="footer">
        <p>© 2025 North Western Railway. All rights reserved.</p>
        <p>Railway Management System | Admin Dashboard</p>
        <p>Designed with <i class="fas fa-heart" style="color: var(--secondary);"></i> for efficient railway administration</p>
    </div>
    
    <!-- Notification container -->
    <div id="notificationContainer" style="position: fixed; top: 20px; right: 20px; max-width: 450px; z-index: 10000; display: flex; flex-direction: column; gap: 15px;"></div>
    
    <script>
    const contextPath = '<%= request.getContextPath() %>';

    // Global variables for deletion
    let currentDeleteId = null;
    let currentDeleteType = null;
    let currentDeleteUrl = null;

    document.addEventListener('click', function(e) {
      const deleteBtn = e.target.closest('.btn-delete');
      if (deleteBtn) {
        e.preventDefault();
        currentDeleteId = deleteBtn.getAttribute('data-id');
        currentDeleteType = deleteBtn.getAttribute('data-type');

        // Update confirmation message
        const message = `Are you sure you want to delete this ${currentDeleteType}?`;
        document.getElementById('confirmationMessage').textContent = message;

        // Show dialog
        document.getElementById('confirmationDialog').classList.add('active');
      }
    });
 
    // Delete functionality
    document.getElementById('confirmDelete').addEventListener('click', function() {
      if (currentDeleteId && currentDeleteType) {
        let servletPath = '';

        switch (currentDeleteType) {
          case 'member':
            servletPath = 'member-delete';
            break;
          case 'entry':
            servletPath = 'entry-delete';
            break;
          default:
            showNotification('error', 'Invalid delete type');
            return;
        }

        const url = contextPath + '/' + servletPath;

        let bodyData = 'id=' + encodeURIComponent(currentDeleteId);

        fetch(url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: bodyData
        })
        .then(res => res.json())
        .then(data => {
          if (data.status === 'success') {
            window.location.href = 'admin.jsp?success=' + encodeURIComponent(data.message);
          } else {
            showNotification('error', data.message);
          }
        })
        .catch(err => {
          showNotification('error', 'Fetch failed: ' + err);
        });
      }
    });

    // Handle cancel button click
    document.getElementById('cancelDelete').addEventListener('click', function() {
        document.getElementById('confirmationDialog').classList.remove('active');
        currentDeleteId = null;
        currentDeleteType = null;
        currentDeleteUrl = null;
    });

    // Check for success message in URL and session
    document.addEventListener('DOMContentLoaded', function() {
        const urlParams = new URLSearchParams(window.location.search);
        const successMsg = urlParams.get('success');
        const errorMsg = urlParams.get('error');
        
        if (successMsg) {
            showNotification('success', successMsg);
            urlParams.delete('success');
            const newUrl = window.location.pathname + (urlParams.toString() ? '?' + urlParams.toString() : '');
            history.replaceState(null, '', newUrl);
        }
        
        if (errorMsg) {
            showNotification('error', errorMsg);
        }
    });
        
    // Feature cards functionality
    const memberManagementCard = document.getElementById('memberManagementCard');
    const entriesManagementCard = document.getElementById('entriesManagementCard');
    const memberManagementSection = document.getElementById('memberManagementSection');
    const entriesManagementSection = document.getElementById('entriesManagementSection');
    
    memberManagementCard.addEventListener('click', function() {
        entriesManagementSection.classList.remove('active');
        entriesManagementCard.classList.remove('active');
        
        memberManagementSection.classList.add('active');
        memberManagementCard.classList.add('active');
        
        memberManagementSection.scrollIntoView({behavior: 'smooth', block: 'start'});
    });
    
    entriesManagementCard.addEventListener('click', function() {
        memberManagementSection.classList.remove('active');
        memberManagementCard.classList.remove('active');
        
        entriesManagementSection.classList.add('active');
        entriesManagementCard.classList.add('active');
        
        entriesManagementSection.scrollIntoView({behavior: 'smooth', block: 'start'});
    });
    
    // Close section
    function closeSection(sectionId) {
        const section = document.getElementById(sectionId);
        section.classList.remove('active');
        
        if (sectionId === 'memberManagementSection') {
            memberManagementCard.classList.remove('active');
        } else if (sectionId === 'entriesManagementSection') {
            entriesManagementCard.classList.remove('active');
        }
    }
    
    // Member tabs
    const memberTabs = document.querySelectorAll('.user-type-tab');
    memberTabs.forEach(tab => {
        tab.addEventListener('click', function() {
            memberTabs.forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            
            document.querySelectorAll('.user-form-section').forEach(section => {
                section.classList.remove('active');
            });
            
            const target = this.getAttribute('data-target');
            document.getElementById(target).classList.add('active');
        });
    });
    
    // Password toggle
    const passwordField = document.getElementById('passwordField');
    const togglePassword = document.getElementById('togglePassword');
    
    togglePassword.addEventListener('click', function() {
        const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordField.setAttribute('type', type);
        
        if (type === 'password') {
            this.innerHTML = '<i class="fas fa-eye"></i>';
        } else {
            this.innerHTML = '<i class="fas fa-eye-slash"></i>';
        }
    });
    
    function showNotification(type, message) {
        const container = document.getElementById('notificationContainer');
        const notification = document.createElement('div');
        
        let iconClass, title;
        if (type === 'success') {
            iconClass = 'fa-check-circle';
            title = 'Success!';
            notification.className = 'notification notification-success';
        } else if (type === 'error') {
            iconClass = 'fa-exclamation-circle';
            title = 'Error!';
            notification.className = 'notification notification-error';
        } else {
            iconClass = 'fa-info-circle';
            title = 'Notice!';
            notification.className = 'notification notification-info';
        }
        
        const notificationIcon = document.createElement('div');
        notificationIcon.className = 'notification-icon';
        notificationIcon.innerHTML = `<i class="fas ${iconClass}"></i>`;
        
        const notificationContent = document.createElement('div');
        notificationContent.className = 'notification-content';
        
        const notificationTitle = document.createElement('div');
        notificationTitle.className = 'notification-title';
        notificationTitle.textContent = title;
        
        const notificationMessage = document.createElement('div');
        notificationMessage.className = 'notification-message';
        notificationMessage.textContent = message;
        
        notificationContent.appendChild(notificationTitle);
        notificationContent.appendChild(notificationMessage);
        
        const closeButton = document.createElement('button');
        closeButton.className = 'notification-close';
        closeButton.innerHTML = '<i class="fas fa-times"></i>';
        
        notification.appendChild(notificationIcon);
        notification.appendChild(notificationContent);
        notification.appendChild(closeButton);
        
        if (type === 'success') {
            const refreshButton = document.createElement('button');
            refreshButton.className = 'notification-refresh';
            refreshButton.innerHTML = '<i class="fas fa-sync-alt"></i> Refresh';
            notification.appendChild(refreshButton);
        }
        
        container.insertBefore(notification, container.firstChild);
        
        setTimeout(() => {
            notification.classList.add('show');
        }, 10);
        
        const removeTimeout = setTimeout(() => {
            notification.classList.remove('show');
            notification.classList.add('hide');
            setTimeout(() => notification.remove(), 500);
        }, type === 'success' ? 8000 : 5000);
        
        closeButton.addEventListener('click', () => {
            clearTimeout(removeTimeout);
            notification.classList.remove('show');
            notification.classList.add('hide');
            setTimeout(() => notification.remove(), 500);
        });
        
        if (type === 'success') {
            const refreshButton = notification.querySelector('.notification-refresh');
            refreshButton.addEventListener('click', () => {
                location.reload();
            });
        }
    }
    
    // Add member form submission
    document.getElementById('addMemberForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        const submitBtn = document.querySelector('#addMemberForm button[type="submit"]');
        const originalBtnText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';
        submitBtn.disabled = true;
        
        fetch('<%= request.getContextPath() %>/add-user', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
            },
            body: new URLSearchParams(new FormData(this)).toString()
        })
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                window.location.href = 'admin.jsp?success=' + encodeURIComponent(data.message);
                document.getElementById('name').value = '';
                document.getElementById('username').value = '';
                document.getElementById('email').value = '';
                document.getElementById('passwordField').value = '';
            } else {
                showNotification('error', data.message);
                if (data.message.includes("Username")) {
                    document.getElementById('username').classList.add('error-field');
                } else if (data.message.includes("Email")) {
                    document.getElementById('email').classList.add('error-field');
                }
            }
        })
        .catch(error => {
            showNotification('error', 'An error occurred: ' + error.message);
        })
        .finally(() => {
            submitBtn.innerHTML = originalBtnText;
            submitBtn.disabled = false;
        });
    });
    
    // Edit button functionality
    document.addEventListener('click', function(e) {
        const editBtn = e.target.closest('.btn-edit');
        if (editBtn) {
            const userId = editBtn.getAttribute('data-id');
            const userType = editBtn.getAttribute('data-type');
            window.location.href = contextPath + '/edit-' + userType + '.jsp?id=' + userId;
        }
    });
    
    // Initialize UI
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.feature-card').forEach((card, index) => {
            setTimeout(() => {
                card.style.animation = 'fadeInUp 0.6s ease-out forwards';
            }, index * 150);
        });
    });
 
    // Report generation functions
    let selectedReportDate = null;

    function setReportDate() {
        const dateInput = document.getElementById('reportReferenceDate');
        if (!dateInput.value) {
            showNotification('error', 'Please select a reference date');
            return;
        }
        
        selectedReportDate = dateInput.value;
        document.getElementById('reportButtons').style.display = 'block';
        const formattedDate = new Date(selectedReportDate).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
        showNotification('success', `Reports will be generated relative to reference date ${formattedDate}`);
    }

    function generateReportFromDate(days) {
        if (!selectedReportDate) {
            showNotification('error', 'Please select a reference date first');
            return;
        }
        const daysParam = days.toString();
        window.location.href = 'generate-report-common?refDate=' + selectedReportDate + '&days=' + daysParam + '&department=<%= adminDepartment %>';
    }
</script>
</body>
</html>