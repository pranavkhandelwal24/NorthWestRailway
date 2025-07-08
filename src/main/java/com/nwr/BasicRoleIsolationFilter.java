package com.nwr;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@WebFilter("/*")
public class BasicRoleIsolationFilter implements Filter {

    private static final Set<String> PUBLIC_PATHS = new HashSet<>(Arrays.asList(
        "/login.jsp", "/login", "/auth", "/logout",
        "/register.jsp", "/register",
        "/forgot-password.jsp",   // ✅ add this
        "/send-reset-link",
        "/ResetPasswordServlet",
        "/reset-password.jsp",   // ✅ MUST add this!

        "/css/", "/js/", "/images/", "/favicon.ico"
    ));

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String path = req.getServletPath();

        // Allow public paths
        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("role") == null) {
            // Not logged in
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String role = ((String) session.getAttribute("role")).toLowerCase().trim();

        if (!isRoleAllowed(role, path)) {
            res.sendRedirect(req.getContextPath() + "/unauthorized.jsp");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isPublic(String path) {
        for (String publicPath : PUBLIC_PATHS) {
            if (path.startsWith(publicPath)) {
                return true;
            }
        }
        return false;
    }

    private boolean isRoleAllowed(String role, String path) {
        // Prevent direct cross-role page access
        switch (role) {
            case "superadmin":
                return !path.equals("/admin.jsp") && !path.equals("/member.jsp");
            case "admin":
                return !path.equals("/superadmin.jsp") && !path.equals("/member.jsp");
            case "member":
                return !path.equals("/superadmin.jsp") && !path.equals("/admin.jsp");
            default:
                return false; // Unknown role → block
        }
    }

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void destroy() {}
}
