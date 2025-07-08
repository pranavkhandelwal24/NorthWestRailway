package com.nwr;

import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DAOConnection {
    private static String url;
    private static String user;
    private static String pass;

    static {
        try {
            Properties props = new Properties();

            // Load from /WEB-INF/config.properties
            InputStream input = DAOConnection.class
                .getClassLoader()
                .getResourceAsStream("WEB-INF/config.properties");

            if (input == null) {
                // fallback for local development
                input = new FileInputStream("src/main/webapp/WEB-INF/config.properties");
            }

            props.load(input);

            url = props.getProperty("DB_URL");
            user = props.getProperty("DB_USER");
            pass = props.getProperty("DB_PASS");

            // Load JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, pass);
    }
}
