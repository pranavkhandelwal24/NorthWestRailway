<%@ page import="java.sql.*, java.util.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>


<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
    response.setDateHeader("Expires", 0); // Proxies.
%>

<%
if (session.getAttribute("username") == null || session.getAttribute("role") == null) {
    response.sendRedirect("login.jsp");
    return;
}
//Get user details from session
String username     = (String) session.getAttribute("username");

//🔑 Get the user's department
String department = "";
try {
 Class.forName("com.mysql.cj.jdbc.Driver");
 Connection deptConn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/defaultdb?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");
 PreparedStatement deptPs = deptConn.prepareStatement("SELECT department FROM members WHERE username = ?");
 deptPs.setString(1, username);
 ResultSet deptRs = deptPs.executeQuery();
 if (deptRs.next()) {
     department = deptRs.getString("department");
     session.setAttribute("department", department);

 }
 deptRs.close();
 deptPs.close();
 deptConn.close();
} catch (Exception e) {
 e.printStackTrace();
}

    // Get first name from session
    String firstName = "";
    String fullNameAttr = (String) session.getAttribute("fullName");
    if (fullNameAttr != null && !fullNameAttr.isEmpty()) {
        firstName = fullNameAttr.split(" ")[0];
    } else {
        firstName = "User";
    }

    String searchFile = request.getParameter("searchFile");
    List<String[]> entries = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/defaultdb?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");

        String query = "SELECT * FROM register_entries WHERE department = ?";

        if (searchFile != null && !searchFile.trim().isEmpty()) {
            query += " AND ifile_no = ?";
        }

        PreparedStatement ps = conn.prepareStatement(query);
        ps.setString(1, department);

        if (searchFile != null && !searchFile.trim().isEmpty()) {
        	try {
        	    ps.setInt(2, Integer.parseInt(searchFile.trim()));
        	} catch (NumberFormatException e) {
        	    // fallback: skip or handle gracefully
        	}

        }

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            entries.add(new String[]{
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


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NWR Member Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/member.css">
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
    
    <!-- Include Navigation -->
    <%@ include file="/WEB-INF/navbar.jsp" %>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="hero-bg"></div>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <div class="hero-card">
                <h1 class="hero-title">Member Dashboard</h1>
                <p class="hero-description">
                    Welcome back, <%= firstName %>! Manage your railway files and access important resources 
                    through this comprehensive member portal.
                </p>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <h2 class="section-title">My Dashboard</h2>
        
        <!-- Feature Cards -->
        <div class="features">
            <div class="feature-card " id="fileManagementCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-file-alt"></i>
                    </div>
                    <h3 class="feature-title">File Management</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        Add, edit, and track your railway files. View status updates and manage all your 
                        file entries in one place.
                    </p>
                </div>
            </div>
            
            <div class="feature-card" id="resourcesCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-link"></i>
                    </div>
                    <h3 class="feature-title">Manage  Entries &amp; Generate Reports</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        View and manage all file entries in your department. Generate comprehensive reports 
                        for analysis and record-keeping.
                    </p>
                </div>
            </div>
        </div>
        
        <!-- File Management Section -->
        <div class="management-section" id="fileManagementSection">
            <div class="section-header">
                <h3 class="section-subtitle">File Management</h3>
                <button class="close-section" onclick="closeSection('fileManagementSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <!-- Add New File Form -->
            <div class="form-grid">
                <form id="fileForm" action="register-entry" method="post">
                
                	<div class="form-group">
                        <label class="form-label">System</label>
                        <select name="system" id="system" class="form-control" required>
                            <option value="">-- Select --</option>
                            <option value="E-Office">E-Office</option>
                            <option value="IRPSM">IRPSM</option>
                        </select>
                    </div>
                	
                		
                    <div class="form-group">
                        <label class="form-label">Internal File No</label>
                        <input type="text" name="ifile_no" id="ifile_no" class="form-control" placeholder="Enter internal file number" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">External File No</label>
                        <input type="text" name="efile_no" id="efile_no" class="form-control" placeholder="Enter external file number" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Details</label>
                        <input type="text" name="details" id="details" class="form-control" placeholder="Enter details" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Function Year</label>
                        <input type="text" name="function_year" id="function_year" class="form-control" placeholder="Enter function year">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Subject</label>
                        <input type="text" name="subject" id="subject" class="form-control" placeholder="Enter subject" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Proposed Cost</label>
                        <input type="number" step="0.01" name="proposed_cost" id="proposed_cost" class="form-control" placeholder="Enter proposed cost" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Vetted Cost</label>
                        <input type="number" step="0.01" name="vetted_cost" id="vetted_cost" class="form-control" placeholder="Enter vetted cost">
                    </div>
                    
                
                    
                    <div class="form-group">
                        <label class="form-label">Received Date</label>
                        <input type="date" name="received_date" id="received_date" class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Putup Date</label>
                        <input type="date" name="putup_date" id="putup_date" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Dispatch Date</label>
                        <input type="date" name="dispatch_date" id="dispatch_date" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select name="status" id="status" class="form-control">
                            <option value="">-- Select --</option>
                            <option value="V">V</option>
                            <option value="R">R</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Add File
                    </button>
                </form>
            </div>
            
            </div>
            
           
            
            
        <!-- Generate Reports -->
<div class="management-section" id="resourcesSection">
    <div class="section-header">
        <h3 class="section-subtitle">Entries</h3>
        <button class="close-section" onclick="closeSection('resourcesSection')">
            <i class="fas fa-times"></i>
        </button>
    </div>
     
     
     <!-- Search Files -->
            <div class="form-group">
                <form method="get" action="member.jsp">
                    <label class="form-label">Search by Internal File Number</label>
                    <div style="display: flex; gap: 10px;">
                        <input type="text" name="searchFile" class="form-control" 
                               placeholder="Enter internal file number" 
                               value="<%= (searchFile != null) ? searchFile : "" %>">
                        <button type="submit" class="btn btn-primary" style="width: auto;">
                            <i class="fas fa-search"></i> Search
                        </button>
                        <% if (searchFile != null && !searchFile.isEmpty()) { %>
                            <a href="member.jsp" class="btn btn-primary" style="width: auto;">
                                <i class="fas fa-times"></i> Clear
                            </a>
                        <% } %>
                    </div>
                </form>
            </div>
            
            <!-- Files Table -->
             <!-- Files Table with Serial Number and hyphens for null values -->
        <div class="table-container">
            <table class="data-table">
    <thead>
        <tr>
            <th>Sr No.</th>
            <th>Username</th> <!-- Added this column -->
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
        <% if (entries.isEmpty()) { %>
            <tr>
                <td colspan="15" style="text-align: center; padding: 40px;">
                    <i class="fas fa-file-alt" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                    <h4 style="color: var(--primary);">No Files Found</h4>
                    <p style="color: var(--gray);">Add your first file to get started</p>
                </td>
            </tr>
        <% } else { 
            int srNo = 1;
            for (String[] entry : entries) { 
        %>
        <tr>
            <td><%= srNo++ %></td>
            <td><%= entry[2] != null ? entry[2] : '-' %></td> <!-- Username column -->
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
              <h3 class="section-subtitle">Generate Reports]</h3>
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
    
    <!-- Include Footer -->
    <%@ include file="/WEB-INF/footer.jsp" %>
    
    <!-- Notification container -->
    <div id="notificationContainer" style="position: fixed; top: 20px; right: 20px; max-width: 450px; z-index: 10000; display: flex; flex-direction: column; gap: 15px;"></div>
    
    <script>
		document.addEventListener('DOMContentLoaded', function() {
		
		  const contextPath = '<%= request.getContextPath() %>';
		
		  // Globals for delete
		  let currentDeleteId = null;
		  let currentDeleteType = null;
		
		  // Delete button handler
		  document.addEventListener('click', function(e) {
		    const deleteBtn = e.target.closest('.btn-delete');
		    if (deleteBtn) {
		      e.preventDefault();
		      currentDeleteId = deleteBtn.getAttribute('data-id');
		      currentDeleteType = deleteBtn.getAttribute('data-type');
		
		      const message = `Are you sure you want to delete this ${currentDeleteType}?`;
		      document.getElementById('confirmationMessage').textContent = message;
		      document.getElementById('confirmationDialog').classList.add('active');
		    }
		  });
		
		  // Confirm delete handler
		  document.getElementById('confirmDelete').addEventListener('click', function() {
		    if (!currentDeleteId || !currentDeleteType) return;
		
		    let servletPath = '';
		    switch (currentDeleteType) {
		      case 'entry':
		        servletPath = 'delete-entry';
		        break;
		      default:
		        showNotification('error', 'Invalid delete type');
		        return;
		    }
		
		 // With this:
		    const params = new URLSearchParams();
		    params.append('ifile_no', currentDeleteId);

		    fetch(contextPath + '/' + servletPath, {
		      method: 'POST',
		      headers: {
		        'Content-Type': 'application/x-www-form-urlencoded'
		      },
		      body: params
		    })
		    .then(response => {
		      if (!response.ok) {
		        throw new Error('Network response was not ok');
		      }
		      return response.json();
		    })
		    .then(data => {
		      if (data.status === 'success') {
		    	  window.location.href = 'member.jsp?success=' + encodeURIComponent(data.message);
		      } else {
		        showNotification('error', data.message);
		      }
		    })
		    .catch(error => {
		      showNotification('error', 'Error deleting file: ' + error.message);
		    })
		    .finally(() => {
		      document.getElementById('confirmationDialog').classList.remove('active');
		      currentDeleteId = null;
		      currentDeleteType = null;
		    });
		  });
		
		  // Cancel delete handler
		  document.getElementById('cancelDelete').addEventListener('click', function() {
		    document.getElementById('confirmationDialog').classList.remove('active');
		    currentDeleteId = null;
		    currentDeleteType = null;
		  });

  // ✅ Feature cards
  const fileManagementCard = document.getElementById('fileManagementCard');
  const resourcesCard = document.getElementById('resourcesCard');
  const fileManagementSection = document.getElementById('fileManagementSection');
  const resourcesSection = document.getElementById('resourcesSection');

  fileManagementCard.addEventListener('click', function () {
    resourcesSection.classList.remove('active');
    resourcesCard.classList.remove('active');

    fileManagementSection.classList.add('active');
    fileManagementCard.classList.add('active');

    fileManagementSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
  });

  resourcesCard.addEventListener('click', function () {
    fileManagementSection.classList.remove('active');
    fileManagementCard.classList.remove('active');

    resourcesSection.classList.add('active');
    resourcesCard.classList.add('active');

    resourcesSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
  });

  // ✅ Check for success/error in URL for notifications
  const urlParams = new URLSearchParams(window.location.search);
  const successMsg = urlParams.get('success');
  const errorMsg = urlParams.get('error');

  if (successMsg) {
    showNotification('success', successMsg);
    const newUrl = window.location.pathname;
    window.history.replaceState({}, document.title, newUrl);
  }

  if (errorMsg) {
    showNotification('error', errorMsg);
  }

  // ✅ Animate feature cards
  document.querySelectorAll('.feature-card').forEach((card, index) => {
    setTimeout(() => {
      card.style.animation = 'fadeInUp 0.6s ease-out forwards';
    }, index * 150);
  });

}); // END DOMContentLoaded

// ✅ Keep global helper functions outside:
function closeSection(sectionId) {
  const section = document.getElementById(sectionId);
  section.classList.remove('active');

  if (sectionId === 'fileManagementSection') {
    document.getElementById('fileManagementCard').classList.remove('active');
  } else if (sectionId === 'resourcesSection') {
    document.getElementById('resourcesCard').classList.remove('active');
  }
}

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
}

//Report generation functions
let selectedReportDate = null;

function setReportDate() {
    const dateInput = document.getElementById('reportReferenceDate');
    if (!dateInput.value) {
        showNotification('error', 'Please select a reference date');
        return;
    }
    
    selectedReportDate = dateInput.value;
    document.getElementById('reportButtons').style.display = 'block';
 // Format the date for display (e.g., "2023-12-25" becomes "Dec 25, 2023")
    const formattedDate = new Date(selectedReportDate).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
    showNotification('success', `Reports will be generated relative to referencedate ${formattedDate}`);
}

function generateReportFromDate(days) {
	  if (!selectedReportDate) {
	    showNotification('error', 'Please select a reference date first');
	    return;
	  }
	  const daysParam = days.toString();
	  window.location.href = 'generate-report?refDate=' + selectedReportDate + '&days=' + daysParam;
	}


</script>
</body>
</html>