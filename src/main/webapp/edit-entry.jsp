<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("username") == null || session.getAttribute("role") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userrole = session.getAttribute("role").toString();
    String username = session.getAttribute("username").toString();
    String ifile_no = request.getParameter("ifile_no");

    // Initialize variables with default values
    String proposedCost = "";
    String vettedCost = "";
    String savings = "";
    String putupDate = "";
    String dispatchDate = "";
    String status = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://pranavkhandelwal24-nwrregister.i.aivencloud.com:12438/defaultdb?useSSL=true&requireSSL=true&serverTimezone=UTC","avnadmin","AVNS_Adj10hYW-Y7UfsohGWv");
        
        // Get the current entry details
        String sql = "SELECT proposed_cost, vetted_cost, savings, putup_date, dispatch_date, status FROM register_entries WHERE ifile_no = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, ifile_no);
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            proposedCost = rs.getString("proposed_cost");
            vettedCost = rs.getString("vetted_cost");
            savings = rs.getString("savings");
            putupDate = rs.getString("putup_date");
            dispatchDate = rs.getString("dispatch_date");
            status = rs.getString("status");
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
    <title>Edit File Entry</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/edit-profile.css">
    <style>
        .readonly-field {
            background-color: #f5f5f5;
            cursor: not-allowed;
        }
        .savings-display {
            font-weight: bold;
            color: #28a745;
            padding: 10px;
            background-color: #f8f9fa;
            border-radius: 4px;
            margin-top: 5px;
        }
    </style>
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
                <h1 class="hero-title">Edit File Entry</h1>
                <p class="hero-description">Update file details for file number: <%= ifile_no %></p>
            </div>
        </div>
    </div>

    <div class="main-content">
        <h2 class="section-title">Edit File Entry</h2>

        <div class="edit-form-container">
            <div class="form-header">
                <h3 class="form-title">Update File Details</h3>
                <button class="back-button" onclick="window.location.href='<%= userrole %>.jsp'">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </button>
            </div>

            <form id="editEntryForm" action="edit-entry" method="post">
                <input type="hidden" name="ifile_no" value="<%= ifile_no %>">
                <input type="hidden" name="proposed_cost" id="proposed_cost_hidden" value="<%= proposedCost %>">

                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Proposed Cost (Read-only)</label>
                        <input type="text" value="<%= proposedCost %>" class="form-control readonly-field" readonly>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Vetted Cost</label>
                        <input type="number" step="0.01" name="vetted_cost" id="vetted_cost" 
                               value="<%= vettedCost != null ? vettedCost : "" %>" 
                               class="form-control" onchange="calculateSavings()">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Savings</label>
                        <div class="savings-display" id="savingsDisplay">
                            <%= savings != null ? savings : "0.00" %>
                        </div>
                        <input type="hidden" name="savings" id="savings" value="<%= savings != null ? savings : "0.00" %>">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Putup Date</label>
                        <input type="date" name="putup_date" value="<%= putupDate != null ? putupDate : "" %>" class="form-control">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Dispatch Date</label>
                        <input type="date" name="dispatch_date" value="<%= dispatchDate != null ? dispatchDate : "" %>" class="form-control">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-control">
                        	<option value="">-- Select --</option>
                            <option value="V" <%= "V".equals(status) ? "selected" : "" %>>V (Verified)</option>
                            <option value="R" <%= "R".equals(status) ? "selected" : "" %>>R (Rejected)</option>
                        </select>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Update Entry
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

    <script>
        function calculateSavings() {
            const proposedCost = parseFloat(document.getElementById('proposed_cost_hidden').value) || 0;
            const vettedCost = parseFloat(document.getElementById('vetted_cost').value) || 0;
            const savings = proposedCost - vettedCost;
            
            document.getElementById('savingsDisplay').textContent = savings.toFixed(2);
            document.getElementById('savings').value = savings.toFixed(2);
        }
        
        // Initialize savings calculation on page load
        document.addEventListener('DOMContentLoaded', function() {
            calculateSavings();
            
            // Check for success/error messages in URL
            const urlParams = new URLSearchParams(window.location.search);
            const successMsg = urlParams.get('success');
            const errorMsg = urlParams.get('error');
            
            if (successMsg) {
                showNotification('success', successMsg);
                // Remove the success parameter from URL
                const newUrl = window.location.pathname;
                window.history.replaceState({}, document.title, newUrl);
            }
            
            if (errorMsg) {
                showNotification('error', errorMsg);
            }
        });
    </script>
</body>
</html>