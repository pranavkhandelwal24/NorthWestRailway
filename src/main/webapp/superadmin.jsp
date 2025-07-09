<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
    response.setDateHeader("Expires", 0); // Proxies.
%>
<%
    // Add this with other declarations at the top
    String searchFile = request.getParameter("searchFile");
    List<String[]> allEntries = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");


        String query = "SELECT * FROM register_entries";

        if (searchFile != null && !searchFile.trim().isEmpty()) {
            query += " WHERE ifile_no = ?";
        }

        PreparedStatement ps = conn.prepareStatement(query);

        if (searchFile != null && !searchFile.trim().isEmpty()) {
            try {
                ps.setInt(1, Integer.parseInt(searchFile.trim()));
            } catch (NumberFormatException e) {
                // fallback: skip or handle gracefully
            }
        }

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            allEntries.add(new String[]{
                String.valueOf(rs.getInt("ifile_no")),    //0
                String.valueOf(rs.getInt("efile_no")), //1
                rs.getString("username"), //2
                rs.getString("department"), //3
                rs.getString("system"), //4 
                rs.getString("details"), //5 
                rs.getString("function_year"), //6
                rs.getString("subject"), //7
                rs.getString("proposed_cost"), //8
                rs.getString("vetted_cost"), //9
                rs.getString("savings"), //10
                rs.getString("received_date"), //11
                rs.getString("putup_date"), //12
                rs.getString("dispatch_date"), //13
                rs.getString("status") //14
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
    
if (session.getAttribute("username") == null || session.getAttribute("role") == null) {
    response.sendRedirect("login.jsp");
    return;}

    // Declare variables only once at the top
    String superadminName = (String) session.getAttribute("superadminName");
    String superadminUsername = (String) session.getAttribute("username");
    List<String> departments = new ArrayList<>();
    List<String> departmentsWithNoHead = new ArrayList<>();
    Map<String, String> departmentHeads = new HashMap<>();
    List<String[]> activeAdmins = new ArrayList<>();
    List<String[]> activeMembers = new ArrayList<>();
    Map<String, Integer> departmentMemberCounts = new HashMap<>();
    Connection conn = null;
    
    // Get superadmin name from session or database
    if (superadminName == null && superadminUsername != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");

            PreparedStatement stmt = conn.prepareStatement("SELECT name FROM superadmins WHERE username = ?");
            stmt.setString(1, superadminUsername);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                superadminName = rs.getString("name");
                session.setAttribute("superadminName", superadminName);
                session.setAttribute("role", "superadmin");
            } else {
                superadminName = "Super Admin";
            }
            
            rs.close();
            stmt.close();
        } catch (Exception e) {
            e.printStackTrace();
            superadminName = "Super Admin";
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    } else if (superadminName == null) {
        superadminName = "Super Admin";
    }
    
    // Get just the first name
    String firstName = "Admin";
    if (superadminName != null && !superadminName.isEmpty()) {
        firstName = superadminName.split(" ")[0];
    }
    
    // Load all other data in a single database connection
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/nwrregister?useSSL=true&requireSSL=true&serverTimezone=UTC?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");

        // Load departments and department heads
        Statement deptStmt = conn.createStatement();
        ResultSet deptRs = deptStmt.executeQuery("SELECT name, department_head FROM departments");
        while (deptRs.next()) {
            String deptName = deptRs.getString("name");
            departments.add(deptName);
            departmentHeads.put(deptName, deptRs.getString("department_head"));
            
            if (deptRs.getString("department_head") == null) {
                departmentsWithNoHead.add(deptName);
            }
        }
        deptRs.close();
        deptStmt.close();
        
        // Load active admins
        Statement adminStmt = conn.createStatement();
        ResultSet adminRs = adminStmt.executeQuery("SELECT * FROM admins WHERE status='active'");
        while (adminRs.next()) {
            String[] admin = {
                adminRs.getString("id"),
                adminRs.getString("name"),
                adminRs.getString("username"),
                adminRs.getString("email"),
                adminRs.getString("department")
            };
            activeAdmins.add(admin);
        }
        adminRs.close();
        adminStmt.close();
        
        // Load active members
        Statement memberStmt = conn.createStatement();
        ResultSet memberRs = memberStmt.executeQuery("SELECT * FROM members WHERE status='active'");
        while (memberRs.next()) {
            String[] member = {
                memberRs.getString("id"),
                memberRs.getString("name"),
                memberRs.getString("username"),
                memberRs.getString("email"),
                memberRs.getString("department")
            };
            activeMembers.add(member);
            
            // Count members per department
            String dept = memberRs.getString("department");
            departmentMemberCounts.put(dept, departmentMemberCounts.getOrDefault(dept, 0) + 1);
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
    <title>NWR Super Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/superadmin.css">
    <style>		/* Report Buttons Section */
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
                <h1 class="hero-title">Super Admin Dashboard</h1>
                <p class="hero-description">
                    Manage railway operations efficiently with our comprehensive admin tools. 
                    Monitor departments, users, and reports.
                </p>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <h2 class="section-title">Management Dashboard</h2>
        
        <!-- Feature Cards -->
        <div class="features">
            <div class="feature-card" id="userManagementCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3 class="feature-title">User Management</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        Manage all users including administrators and members. Add new users, 
                        edit existing profiles, and assign roles and departments.
                    </p>
                </div>
            </div>
            
            <div class="feature-card" id="departmentManagementCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-building"></i>
                    </div>
                    <h3 class="feature-title">Department Management</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        Create, modify, and manage departments. Assign users to departments 
                        and monitor department-specific activities.
                    </p>
                </div>
            </div>
            
             <!-- Add this new card -->
    <div class="feature-card" id="entriesManagementCard">
        <div class="feature-header">
            <div class="feature-icon">
                <i class="fas fa-file-alt"></i>
            </div>
            <h3 class="feature-title">Manage Entries &amp; Generate Reports</h3>
        </div>
        <div class="feature-body">
            <p class="feature-description">
                View and manage all file entries across all departments. Generate comprehensive reports 
                for analysis and record-keeping.
            </p>
        </div>
    </div>
            
            
        </div>
        
        <!-- User Management Section -->
        <div class="management-section" id="userManagementSection">
            <div class="section-header">
                <h3 class="section-subtitle">User Management</h3>
                <button class="close-section" onclick="closeSection('userManagementSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="user-type-tabs">
                <div class="user-type-tab " data-target="manageMembers">Manage Members</div>
                <div class="user-type-tab" data-target="manageAdmins">Manage Admins</div>
                <div class="user-type-tab" data-target="addUser">Add User</div>
            </div>
            
            <!-- Manage Members -->
            <div class="user-form-section" id="manageMembers">
                <h4>Active Members</h4>
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
                            <% if(activeMembers.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 40px;">
                                        <i class="fas fa-user-slash" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                        <h4 style="color: var(--primary);">No Active Members Found</h4>
                                        <p style="color: var(--gray);">All members are inactive or not created yet</p>
                                    </td>
                                </tr>
                            <% } else { %>
                                <% for(String[] member : activeMembers) { %>
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
            
            <!-- Manage Admins -->
            <div class="user-form-section" id="manageAdmins">
                <h4>Active Administrators</h4>
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
                            <% if(activeAdmins.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 40px;">
                                        <i class="fas fa-user-shield" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                        <h4 style="color: var(--primary);">No Active Administrators Found</h4>
                                        <p style="color: var(--gray);">All administrators are inactive or not created yet</p>
                                    </td>
                                </tr>
                            <% } else { %>
                                <% for(String[] admin : activeAdmins) { %>
                                    <tr>
                                        <td><%= admin[0] %></td>
                                        <td><%= admin[1] %></td>
                                        <td><%= admin[2] %></td>
                                        <td><%= admin[3] %></td>
                                        <td><%= admin[4] %></td>
                                        <td class="actions">
                                            <a href="edit-admin.jsp?id=<%= admin[0] %>&type=admin" class="btn-edit" 
                                                    data-id="<%= admin[0] %>"
                                                    data-type="admin"
                                                    style="text-decoration: none;">
                                                <i class="fas fa-edit"></i> Edit
                                            </a>
                                            <a href="deleteuser.jsp?id=<%= admin[0] %>&type=admin" 
                                               class="btn-delete"
                                               data-id="<%= admin[0] %>"
                                               data-type="admin"
                                               style="text-decoration: none;">
                                                <i class="fas fa-trash"></i> 
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Add User -->
            <div class="user-form-section" id="addUser">
                <h4>Add New User</h4>
                <form id="addUserForm">
                    <div class="form-group">
                        <label class="form-label">User Type</label>
                        <select id="userType" class="form-control" name="role" required>
                            <option value="">Select User Type</option>
                            <option value="superadmin">Super Admin</option>
                            <option value="admin">Admin</option>
                            <option value="member">Member</option>
                        </select>
                    </div>
                    
                    <div id="userFormFields">
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
                            
                            <div class="form-group" id="departmentField">
    <label class="form-label">Department</label>
    <select id="department" name="department" class="form-control">
        <option value="">Select Department</option>
        <% for(String dept : departments) { %>
            <option value="<%= dept %>" 
                <% if (!departmentsWithNoHead.contains(dept) && !"superadmin".equals(request.getParameter("role"))) { %>
                    disabled
                <% } %>
            >
                <%= dept %>
                <% if (!departmentsWithNoHead.contains(dept)) { %>
                    (Head assigned)
                <% } %>
            </option>
        <% } %>
    </select>
</div>                </div>
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            <i class="fas fa-plus"></i> Add User
                        </button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Department Management Section -->
        <div class="management-section" id="departmentManagementSection">
            <div class="section-header">
                <h3 class="section-subtitle">Department Management</h3>
                <button class="close-section" onclick="closeSection('departmentManagementSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <!-- Department description above tabs -->
            <div class="department-description">
                <h4>Department Overview</h4>
                <p>
                    Create and manage departments to organize your users efficiently. 
                </p>
                <ul>
                    <li>Assign users to specific departments</li>
                    <li>Track department-specific activities</li>
                    <li>Manage permissions by department</li>
                    <li>Generate department reports</li>
                </ul>
            </div>
            
            <div class="department-tabs">
                <div class="department-tab " data-target="manageDepartments">Manage Departments</div>
                <div class="department-tab" data-target="addDepartment">Add Department</div>
            </div>
            
            <!-- Manage Departments -->
            <div class="department-section " id="manageDepartments">
                <h4>All Departments</h4>
                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Department Name</th>
                                <th>Department Head</th>
                                <th>Active Members</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(departments.isEmpty()) { %>
                                <tr>
                                    <td colspan="4" style="text-align: center; padding: 40px;">
                                        <i class="fas fa-building" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                        <h4 style="color: var(--primary);">No Departments Found</h4>
                                        <p style="color: var(--gray);">Add departments to organize your users</p>
                                    </td>
                                </tr>
                            <% } else { 
                                for(String dept : departments) { 
                                    int memberCount = departmentMemberCounts.getOrDefault(dept, 0);
                            %>
                            <tr>
                                <td><strong><%= dept %></strong></td>
                                <td><%= departmentHeads.get(dept) != null ? departmentHeads.get(dept) : "Not assigned" %></td>
                                <td><span class="badge"><%= memberCount %> members</span></td>
                                <td class="actions">
                                    <a href="edit-department.jsp?name=<%= java.net.URLEncoder.encode(dept, "UTF-8") %>&type=department" class="btn-edit"
                                            style="text-decoration: none;">
                                        <i class="fas fa-edit"></i> Edit
                                    </a>
                                    <button type="button"
                                    		class="btn-delete"
                                    		data-id="<%= dept %>"
                                    		data-type="department">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                            <% } 
                            } %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Add Department -->
            <div class="department-section" id="addDepartment">
                <h4>Create New Department</h4>
                <form id="addDepartmentForm" action="add-department" method="post">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Department Name</label>
                            <input type="text" name="departmentName" class="form-control" placeholder="Enter department name" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Add Department
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
        <form method="get" action="superadmin.jsp">
            <label class="form-label">Search by Internal File Number</label>
            <div style="display: flex; gap: 10px;">
                <input type="text" name="searchFile" class="form-control" 
                       placeholder="Enter internal file number" 
                       value="<%= (searchFile != null) ? searchFile : "" %>">
                <button type="submit" class="btn btn-primary" style="width: auto;">
                    <i class="fas fa-search"></i> Search
                </button>
                <% if (searchFile != null && !searchFile.isEmpty()) { %>
                    <a href="superadmin.jsp" class="btn btn-primary" style="width: auto;">
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
                        <button class="btn-edit" 
						        data-id="<%= entry[0] %>" 
						        data-type="entry">
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
        <p>Railway Management System | Super Admin Dashboard</p>
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

 // ✅ NEW version — no href, uses fetch POST
    document.addEventListener('click', function(e) {
      const deleteBtn = e.target.closest('.btn-delete');
      if (deleteBtn) {
        e.preventDefault(); // Safe for <a>, not needed for <button>
        currentDeleteId = deleteBtn.getAttribute('data-id');
        currentDeleteType = deleteBtn.getAttribute('data-type');

        // Update confirmation message
        const message = `Are you sure you want to delete this ${currentDeleteType}?`;
        document.getElementById('confirmationMessage').textContent = message;

        // Show dialog
        document.getElementById('confirmationDialog').classList.add('active');
      }
    });
 
  //Delete
    // ✅ NEW: Confirm button uses fetch POST
document.getElementById('confirmDelete').addEventListener('click', function() {
  if (currentDeleteId && currentDeleteType) {
    let servletPath = '';
    let bodyData = '';

    switch (currentDeleteType) {
      case 'member':
        servletPath = 'member-delete';
        bodyData = 'id=' + encodeURIComponent(currentDeleteId);
        break;
      case 'admin':
        servletPath = 'admin-delete';
        bodyData = 'id=' + encodeURIComponent(currentDeleteId);
        break;
      case 'department':
        servletPath = 'department-delete';
        bodyData = 'departmentName=' + encodeURIComponent(currentDeleteId);
        break;
      case 'entry':
        servletPath = 'delete-entry';
        bodyData = 'ifile_no=' + encodeURIComponent(currentDeleteId);  // KEY CHANGE HERE
        break;
      default:
        showNotification('error', 'Invalid delete type');
        return;
    }

    fetch(contextPath + '/' + servletPath, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: bodyData
    })
    .then(res => res.json())
    .then(data => {
      if (data.status === 'success') {
        window.location.href = 'superadmin.jsp?success=' + encodeURIComponent(data.message);
      } else {
        showNotification('error', data.message);
      }
    })
    .catch(err => {
      showNotification('error', 'Failed to delete: ' + err);
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
        
        // Check if we've already shown this success message
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
    const userManagementCard = document.getElementById('userManagementCard');
    const departmentManagementCard = document.getElementById('departmentManagementCard');
    const userManagementSection = document.getElementById('userManagementSection');
    const departmentManagementSection = document.getElementById('departmentManagementSection');
    
    userManagementCard.addEventListener('click', function() {
        // Close other sections
        departmentManagementSection.classList.remove('active');
        departmentManagementCard.classList.remove('active');
        
        // Open this section
        userManagementSection.classList.add('active');
        userManagementCard.classList.add('active');
        
        // Scroll to section
        userManagementSection.scrollIntoView({behavior: 'smooth', block: 'start'});
    });
    
    departmentManagementCard.addEventListener('click', function() {
        // Close other sections
        userManagementSection.classList.remove('active');
        userManagementCard.classList.remove('active');
        
        // Open this section
        departmentManagementSection.classList.add('active');
        departmentManagementCard.classList.add('active');
        
        // Scroll to section
        departmentManagementSection.scrollIntoView({behavior: 'smooth', block: 'start'});
    });
    
    // Close section
    function closeSection(sectionId) {
        const section = document.getElementById(sectionId);
        section.classList.remove('active');
        
        // Remove active class from card
        if (sectionId === 'userManagementSection') {
            userManagementCard.classList.remove('active');
        } else if (sectionId === 'departmentManagementSection') {
            departmentManagementCard.classList.remove('active');
        }
    }
    
    // User type tabs
    const userTypeTabs = document.querySelectorAll('.user-type-tab');
    userTypeTabs.forEach(tab => {
        tab.addEventListener('click', function() {
            // Remove active class from all tabs
            userTypeTabs.forEach(t => t.classList.remove('active'));
            
            // Add active class to clicked tab
            this.classList.add('active');
            
            // Hide all sections
            document.querySelectorAll('.user-form-section').forEach(section => {
                section.classList.remove('active');
            });
            
            // Show target section
            const target = this.getAttribute('data-target');
            document.getElementById(target).classList.add('active');
        });
    });
    
    // Department tabs
    const departmentTabs = document.querySelectorAll('.department-tab');
    departmentTabs.forEach(tab => {
        tab.addEventListener('click', function() {
            // Remove active class from all tabs
            departmentTabs.forEach(t => t.classList.remove('active'));
            
            // Add active class to clicked tab
            this.classList.add('active');
            
            // Hide all sections
            document.querySelectorAll('.department-section').forEach(section => {
                section.classList.remove('active');
            });
            
            // Show target section
            const target = this.getAttribute('data-target');
            document.getElementById(target).classList.add('active');
        });
    });
    
    // Department field visibility based on user type
    // Department field visibility based on user type
const userTypeSelect = document.getElementById('userType');
const departmentField = document.getElementById('departmentField');
const userFormFields = document.getElementById('userFormFields');
const departmentSelect = document.getElementById('department');

userTypeSelect.addEventListener('change', function() {
    if (this.value) {
        // Show the form fields
        userFormFields.style.display = 'block';
        
        if (this.value === 'superadmin') {
            departmentField.style.display = 'none';
            departmentSelect.removeAttribute('required');
        } else {
            departmentField.style.display = 'block';
            departmentSelect.setAttribute('required', 'required');
            
            // If admin is selected, disable departments with existing heads
            if (this.value === 'admin') {
                Array.from(departmentSelect.options).forEach(option => {
                    if (option.text.includes('(Head assigned)')) {
                        option.disabled = true;
                        if (option.selected) {
                            option.selected = false;
                            departmentSelect.value = '';
                        }
                    } else {
                        option.disabled = false;
                    }
                });
            } else {
                // For member, enable all departments
                Array.from(departmentSelect.options).forEach(option => {
                    option.disabled = false;
                });
            }
        }
    } else {
        // Hide form fields if no type selected
        userFormFields.style.display = 'none';
    }
});
    
    // Password toggle
    const passwordField = document.getElementById('passwordField');
    const togglePassword = document.getElementById('togglePassword');
    
    togglePassword.addEventListener('click', function() {
        const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordField.setAttribute('type', type);
        
        // Toggle eye icon
        if (type === 'password') {
            this.innerHTML = '<i class="fas fa-eye"></i>';
        } else {
            this.innerHTML = '<i class="fas fa-eye-slash"></i>';
        }
    });
    
    function showNotification(type, message) {
        const container = document.getElementById('notificationContainer');
        const notification = document.createElement('div');
        
        // Determine icon and title based on type
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
        
        // Create notification elements
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
        
        // Build notification structure
        notification.appendChild(notificationIcon);
        notification.appendChild(notificationContent);
        notification.appendChild(closeButton);
        
        // Add refresh button for success notifications
        if (type === 'success') {
            const refreshButton = document.createElement('button');
            refreshButton.className = 'notification-refresh';
            refreshButton.innerHTML = '<i class="fas fa-sync-alt"></i> Refresh';
            notification.appendChild(refreshButton);
        }
        
        // Prepend to show newest on top
        container.insertBefore(notification, container.firstChild);
        
        // Trigger show animation
        setTimeout(() => {
            notification.classList.add('show');
        }, 10);
        
        // Auto-remove after 8 seconds (longer for success messages)
        const removeTimeout = setTimeout(() => {
            notification.classList.remove('show');
            notification.classList.add('hide');
            setTimeout(() => notification.remove(), 500);
        }, type === 'success' ? 8000 : 5000);
        
        // Manual close
        closeButton.addEventListener('click', () => {
            clearTimeout(removeTimeout);
            notification.classList.remove('show');
            notification.classList.add('hide');
            setTimeout(() => notification.remove(), 500);
        });
        
        // Add refresh functionality for success notifications
        if (type === 'success') {
            const refreshButton = notification.querySelector('.notification-refresh');
            refreshButton.addEventListener('click', () => {
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
    
    // Add CSS animations
    const style = document.createElement('style');
    style.innerHTML = `
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeOut {
            from { opacity: 1; transform: translateY(0); }
            to { opacity: 0; transform: translateY(-20px); }
        }
    `;
    document.head.appendChild(style);
    
 //  submission
    document.getElementById('addUserForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    // Show loading indicator
    const submitBtn = document.querySelector('#addUserForm button[type="submit"]');
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
        	// ✅ On success, redirect with ?success= message — like your delete logic
            window.location.href = 'superadmin.jsp?success=' + encodeURIComponent(data.message);
            // Clear form fields
            document.getElementById('name').value = '';
            document.getElementById('username').value = '';
            document.getElementById('email').value = '';
            document.getElementById('passwordField').value = '';
            document.getElementById('userType').value = '';
            document.getElementById('userFormFields').style.display = 'none';
        } else {
            showNotification('error', data.message);
            // Highlight problematic field
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
        const id = editBtn.getAttribute('data-id');
        const type = editBtn.getAttribute('data-type');
        
        if (type === 'entry') {
            window.location.href = 'edit-entry.jsp?ifile_no=' + id;
        } else {
            window.location.href = contextPath + '/edit-' + type + '.jsp?id=' + id;
        }
    }
});
    
    
    // Initialize UI
    document.addEventListener('DOMContentLoaded', function() {
        // Hide form fields initially
        document.getElementById('userFormFields').style.display = 'none';
        
        // Hide department field for superadmin by default
        document.getElementById('departmentField').style.display = 'none';
        
        // Animate elements on load
        document.querySelectorAll('.feature-card').forEach((card, index) => {
            setTimeout(() => {
                card.style.animation = 'fadeInUp 0.6s ease-out forwards';
            }, index * 150);
        });
    });
    
 // Update department field requirement based on user type
    userTypeSelect.addEventListener('change', function() {
        if (this.value) {
            // Show the form fields
            userFormFields.style.display = 'block';
            
            if (this.value === 'superadmin') {
                departmentField.style.display = 'none';
                document.getElementById('department').removeAttribute('required');
            } else {
                departmentField.style.display = 'block';
                document.getElementById('department').setAttribute('required', 'required');
            }
        } else {
            // Hide form fields if no type selected
            userFormFields.style.display = 'none';
        }
    });
 
 
 // Add this with other feature card event listeners
    const entriesManagementCard = document.getElementById('entriesManagementCard');
    const entriesManagementSection = document.getElementById('entriesManagementSection');

    entriesManagementCard.addEventListener('click', function() {
        // Close other sections
        userManagementSection.classList.remove('active');
        userManagementCard.classList.remove('active');
        departmentManagementSection.classList.remove('active');
        departmentManagementCard.classList.remove('active');
        
        // Open this section
        entriesManagementSection.classList.add('active');
        entriesManagementCard.classList.add('active');
        
        // Scroll to section
        entriesManagementSection.scrollIntoView({behavior: 'smooth', block: 'start'});
    });

    // Add to closeSection function
    function closeSection(sectionId) {
        const section = document.getElementById(sectionId);
        section.classList.remove('active');
        
        // Remove active class from card
        if (sectionId === 'userManagementSection') {
            userManagementCard.classList.remove('active');
        } else if (sectionId === 'departmentManagementSection') {
            departmentManagementCard.classList.remove('active');
        } else if (sectionId === 'entriesManagementSection') {
            entriesManagementCard.classList.remove('active');
        }
    }

    // Report generation functions (same as in member.jsp)
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
        window.location.href = 'generate-report-common?refDate=' + selectedReportDate + '&days=' + daysParam + '&allDepartments=true';
    }
</script>
</body>
</html>
