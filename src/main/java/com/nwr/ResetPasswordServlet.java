package com.nwr;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Properties;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String SALT = "nwr-railway-system";

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String token = req.getParameter("token");
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirm");

        if (token == null || token.trim().isEmpty()) {
            sendErrorResponse(res, "Invalid token.");
            return;
        }

        if (password == null || confirm == null || !password.equals(confirm)) {
            sendErrorResponse(res, "Passwords do not match.");
            return;
        }

        Connection con = null;
        try {
            // Load DB config from properties file
            Properties config = new Properties();
            try (InputStream input = getServletContext().getResourceAsStream("/WEB-INF/config.properties")) {
                if (input == null) {
                    throw new ServletException("Could not find WEB-INF/config.properties");
                }
                config.load(input);
            }

            String dbUrl = config.getProperty("DB_URL");
            String dbUser = config.getProperty("DB_USER");
            String dbPass = config.getProperty("DB_PASS");

            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // Get user email from token
            String getEmailQuery = "SELECT email FROM password_reset_tokens WHERE token = ?";
            PreparedStatement getEmailStmt = con.prepareStatement(getEmailQuery);
            getEmailStmt.setString(1, token);
            ResultSet rs = getEmailStmt.executeQuery();

            if (!rs.next()) {
                sendErrorResponse(res, "Invalid or expired token.");
                return;
            }

            String email = rs.getString("email");

            // Hash the new password
            String hashedPassword = hashPassword(password);

            // Find which table the email belongs to and update there
            String[] tables = {"superadmins", "admins", "members"};
            boolean updated = false;

            for (String table : tables) {
                String checkQuery = "SELECT * FROM " + table + " WHERE email = ?";
                PreparedStatement checkStmt = con.prepareStatement(checkQuery);
                checkStmt.setString(1, email);
                ResultSet checkRs = checkStmt.executeQuery();

                if (checkRs.next()) {
                    String updateQuery = "UPDATE " + table + " SET password = ? WHERE email = ?";
                    PreparedStatement updateStmt = con.prepareStatement(updateQuery);
                    updateStmt.setString(1, hashedPassword);
                    updateStmt.setString(2, email);
                    updateStmt.executeUpdate();
                    updated = true;
                    break;
                }
            }

            if (!updated) {
                sendErrorResponse(res, "User not found.");
                return;
            }

            // Delete the used token
            String deleteTokenQuery = "DELETE FROM password_reset_tokens WHERE token = ?";
            PreparedStatement deleteStmt = con.prepareStatement(deleteTokenQuery);
            deleteStmt.setString(1, token);
            deleteStmt.executeUpdate();

            // Respond success with redirect
            sendSuccessResponse(res);

        } catch (Exception e) {
            e.printStackTrace();
            sendErrorResponse(res, "Error occurred: " + e.getMessage());
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }

    private String hashPassword(String password) throws NoSuchAlgorithmException {
        String saltedPassword = SALT + password;
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(saltedPassword.getBytes());
        byte[] digest = md.digest();
        StringBuilder sb = new StringBuilder();
        for (byte b : digest) {
            sb.append(String.format("%02x", b & 0xff));
        }
        return sb.toString();
    }

    private void sendSuccessResponse(HttpServletResponse res) throws IOException {
        res.setContentType("text/html");
        res.getWriter().println("<!DOCTYPE html>");
        res.getWriter().println("<html lang='en'>");
        res.getWriter().println("<head>");
        res.getWriter().println("<meta charset='UTF-8'>");
        res.getWriter().println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        res.getWriter().println("<title>Password Reset Successful</title>");
        res.getWriter().println("<link href='https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap' rel='stylesheet'>");
        res.getWriter().println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css'>");
        res.getWriter().println("<meta http-equiv='refresh' content='3;URL=login.jsp'/>");
        res.getWriter().println("<style>");
        res.getWriter().println(":root {");
        res.getWriter().println("  --primary: #0056b3;");
        res.getWriter().println("  --primary-light: #3a7fc5;");
        res.getWriter().println("  --primary-dark: #003d7a;");
        res.getWriter().println("  --success: #28a745;");
        res.getWriter().println("  --glass-bg: rgba(255, 255, 255, 0.9);");
        res.getWriter().println("  --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);");
        res.getWriter().println("}");
        res.getWriter().println("* { margin: 0; padding: 0; box-sizing: border-box; }");
        res.getWriter().println("body {");
        res.getWriter().println("  font-family: 'Poppins', sans-serif;");
        res.getWriter().println("  background: linear-gradient(135deg, var(--primary-dark), var(--primary));");
        res.getWriter().println("  min-height: 100vh;");
        res.getWriter().println("  display: flex;");
        res.getWriter().println("  justify-content: center;");
        res.getWriter().println("  align-items: center;");
        res.getWriter().println("  padding: 20px;");
        res.getWriter().println("}");
        res.getWriter().println(".success-container {");
        res.getWriter().println("  background: var(--glass-bg);");
        res.getWriter().println("  backdrop-filter: blur(10px);");
        res.getWriter().println("  border-radius: 20px;");
        res.getWriter().println("  padding: 40px;");
        res.getWriter().println("  box-shadow: var(--card-shadow);");
        res.getWriter().println("  text-align: center;");
        res.getWriter().println("  max-width: 500px;");
        res.getWriter().println("  width: 100%;");
        res.getWriter().println("}");
        res.getWriter().println(".success-icon {");
        res.getWriter().println("  font-size: 4rem;");
        res.getWriter().println("  color: var(--success);");
        res.getWriter().println("  margin-bottom: 20px;");
        res.getWriter().println("}");
        res.getWriter().println("h2 {");
        res.getWriter().println("  color: var(--primary-dark);");
        res.getWriter().println("  margin-bottom: 15px;");
        res.getWriter().println("}");
        res.getWriter().println("p {");
        res.getWriter().println("  color: #555;");
        res.getWriter().println("  margin-bottom: 20px;");
        res.getWriter().println("}");
        res.getWriter().println(".logo {");
        res.getWriter().println("  height: 50px;");
        res.getWriter().println("  margin-bottom: 20px;");
        res.getWriter().println("}");
        res.getWriter().println("@media (max-width: 768px) {");
        res.getWriter().println("  .success-container { padding: 30px; }");
        res.getWriter().println("}");
        res.getWriter().println("</style>");
        res.getWriter().println("</head>");
        res.getWriter().println("<body>");
        res.getWriter().println("<div class='success-container'>");
        res.getWriter().println("<img src='https://upload.wikimedia.org/wikipedia/en/thumb/8/83/Indian_Railways.svg/1200px-Indian_Railways.svg.png' alt='Indian Railways Logo' class='logo'>");
        res.getWriter().println("<div class='success-icon'><i class='fas fa-check-circle'></i></div>");
        res.getWriter().println("<h2>Password Reset Successful</h2>");
        res.getWriter().println("<p>Your password has been updated successfully.</p>");
        res.getWriter().println("<p>You will be redirected to login page shortly...</p>");
        res.getWriter().println("</div>");
        res.getWriter().println("</body>");
        res.getWriter().println("</html>");
    }

    private void sendErrorResponse(HttpServletResponse res, String message) throws IOException {
        res.setContentType("text/html");
        res.getWriter().println("<!DOCTYPE html>");
        res.getWriter().println("<html lang='en'>");
        res.getWriter().println("<head>");
        res.getWriter().println("<meta charset='UTF-8'>");
        res.getWriter().println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        res.getWriter().println("<title>Error</title>");
        res.getWriter().println("<link href='https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap' rel='stylesheet'>");
        res.getWriter().println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css'>");
        res.getWriter().println("<style>");
        res.getWriter().println(":root {");
        res.getWriter().println("  --primary: #0056b3;");
        res.getWriter().println("  --primary-dark: #003d7a;");
        res.getWriter().println("  --error: #dc3545;");
        res.getWriter().println("  --glass-bg: rgba(255, 255, 255, 0.9);");
        res.getWriter().println("  --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);");
        res.getWriter().println("}");
        res.getWriter().println("* { margin: 0; padding: 0; box-sizing: border-box; }");
        res.getWriter().println("body {");
        res.getWriter().println("  font-family: 'Poppins', sans-serif;");
        res.getWriter().println("  background: linear-gradient(135deg, var(--primary-dark), var(--primary));");
        res.getWriter().println("  min-height: 100vh;");
        res.getWriter().println("  display: flex;");
        res.getWriter().println("  justify-content: center;");
        res.getWriter().println("  align-items: center;");
        res.getWriter().println("  padding: 20px;");
        res.getWriter().println("}");
        res.getWriter().println(".error-container {");
        res.getWriter().println("  background: var(--glass-bg);");
        res.getWriter().println("  backdrop-filter: blur(10px);");
        res.getWriter().println("  border-radius: 20px;");
        res.getWriter().println("  padding: 40px;");
        res.getWriter().println("  box-shadow: var(--card-shadow);");
        res.getWriter().println("  text-align: center;");
        res.getWriter().println("  max-width: 500px;");
        res.getWriter().println("  width: 100%;");
        res.getWriter().println("}");
        res.getWriter().println(".error-icon {");
        res.getWriter().println("  font-size: 4rem;");
        res.getWriter().println("  color: var(--error);");
        res.getWriter().println("  margin-bottom: 20px;");
        res.getWriter().println("}");
        res.getWriter().println("h2 {");
        res.getWriter().println("  color: var(--primary-dark);");
        res.getWriter().println("  margin-bottom: 15px;");
        res.getWriter().println("}");
        res.getWriter().println("p {");
        res.getWriter().println("  color: #721c24;");
        res.getWriter().println("  margin-bottom: 20px;");
        res.getWriter().println("}");
        res.getWriter().println(".logo {");
        res.getWriter().println("  height: 50px;");
        res.getWriter().println("  margin-bottom: 20px;");
        res.getWriter().println("}");
        res.getWriter().println("@media (max-width: 768px) {");
        res.getWriter().println("  .error-container { padding: 30px; }");
        res.getWriter().println("}");
        res.getWriter().println("</style>");
        res.getWriter().println("</head>");
        res.getWriter().println("<body>");
        res.getWriter().println("<div class='error-container'>");
        res.getWriter().println("<img src='https://upload.wikimedia.org/wikipedia/en/thumb/8/83/Indian_Railways.svg/1200px-Indian_Railways.svg.png' alt='Indian Railways Logo' class='logo'>");
        res.getWriter().println("<div class='error-icon'><i class='fas fa-exclamation-circle'></i></div>");
        res.getWriter().println("<h2>Error</h2>");
        res.getWriter().println("<p>" + message + "</p>");
        res.getWriter().println("</div>");
        res.getWriter().println("</body>");
        res.getWriter().println("</html>");
    }
}