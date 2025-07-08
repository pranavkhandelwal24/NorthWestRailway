<%-- navbar.jsp --%>
<%@ page import="java.sql.*" %>
<%
    
	if (session == null || session.getAttribute("username") == null || session.getAttribute("role") == null) {
	    response.sendRedirect("login.jsp");
	    return;
	}

    String fullName = (String) session.getAttribute("fullName");
    String role = (String) session.getAttribute("role");

    // Defensive fallback
    if (fullName == null) fullName = "User";
    if (role == null) role = "member";

    String userFirstName = fullName.split(" ")[0];

    String roleDisplayName;
    switch (role) {
        case "superadmin":
            roleDisplayName = "Super Admin";
            break;
        case "admin":
            roleDisplayName = "Admin";
            break;
        case "member":
            roleDisplayName = "Member";
            break;
        default:
            roleDisplayName = "Null";
    }
%>

<link rel="stylesheet" href="css/navbar.css">


<div class="top-nav">
    <div class="nav-left">
        <div class="logo">
            <img src="https://upload.wikimedia.org/wikipedia/en/thumb/8/83/Indian_Railways.svg/1200px-Indian_Railways.svg.png" 
                 alt="Indian Railways">
            <div class="nav-title">North Western Railway</div>
        </div>
    </div>
    <div class="nav-right">
        <div class="user-menu" id="userMenu">
            <div class="user-info">
                <div class="user-avatar">
                    <% 
                        String[] names = fullName.split(" ");
                        String initials = names[0].substring(0, 1);
                        if (names.length > 1) {
                            initials += names[names.length-1].substring(0, 1);
                        }
                    %>
                    <%= initials.toUpperCase() %>
                </div>
                <div class="user-details">
                    <h4><%= userFirstName %></h4>
                    <p><%= roleDisplayName %></p>
                </div>
                <i class="fas fa-chevron-down"></i>
            </div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="edit-profile.jsp" class="dropdown-item">
                    <i class="fas fa-user-cog"></i> Edit Profile
                </a>
                <% if ("superadmin".equals(role)) { %>
    				<a href="superadmin.jsp" class="dropdown-item">
        			<i class="fas fa-tachometer-alt"></i> SuperAdmin Panel
    				</a>
				<% } else if ("admin".equals(role)) { %>
				    <a href="admin.jsp" class="dropdown-item">
				        <i class="fas fa-tools"></i> Admin Dashboard
				    </a>
				<% } else if ("member".equals(role)) { %>
				    <a href="member.jsp" class="dropdown-item">
				        <i class="fas fa-tools"></i> Member Dashboard
				    </a>
				<% } %>
                <a href="logout.jsp" class="dropdown-item">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
  const userMenu = document.getElementById('userMenu');
  const dropdownMenu = document.getElementById('dropdownMenu');

  if (userMenu && dropdownMenu) {
    // Toggle dropdown when clicking the user menu
    userMenu.addEventListener('click', function(e) {
      e.stopPropagation();
      dropdownMenu.classList.toggle('show');
    });

    // Close dropdown when clicking anywhere else
    document.addEventListener('click', function() {
      dropdownMenu.classList.remove('show');
    });
  }
});
</script>
