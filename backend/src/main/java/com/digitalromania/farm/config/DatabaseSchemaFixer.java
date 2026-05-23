package com.digitalromania.farm.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(name = "app.database-schema-fixer.enabled", havingValue = "true", matchIfMissing = true)
public class DatabaseSchemaFixer implements CommandLineRunner {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) {
        try {
            jdbcTemplate.execute("UPDATE users SET role = 'ADMIN' WHERE role = 'CIVIL_SERVANT'");
            jdbcTemplate.execute("ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check");
            jdbcTemplate.execute("""
                ALTER TABLE users ADD CONSTRAINT users_role_check
                CHECK (role IN ('FARMER', 'VET', 'ADMIN', 'SYSTEM'))
                """);
        } catch (Exception e) {
            System.err.println("Could not update users role constraint: " + e.getMessage());
        }
    }
}
