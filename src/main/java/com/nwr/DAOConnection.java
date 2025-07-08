package com.nwr;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DAOConnection {

    private static String host = System.getenv("DB_HOST");
    private static String port = System.getenv("DB_PORT");
    private static String dbName = System.getenv("DB_NAME");
    private static String user = System.getenv("DB_USER");
    private static String pass = System.getenv("DB_PASS");

    private static String jdbcUrl = "jdbc:mysql://" + host + ":" + port + "/" + dbName
            + "?useSSL=true&requireSSL=true&serverTimezone=UTC";

    // Static method to get connection
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(jdbcUrl, user, pass);
    }
}
