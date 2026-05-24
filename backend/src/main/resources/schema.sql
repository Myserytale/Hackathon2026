-- Run before JPA schema update (spring.sql.init.mode=always)
ALTER TABLE IF EXISTS users ADD COLUMN IF NOT EXISTS name VARCHAR(255);
ALTER TABLE IF EXISTS users ADD COLUMN IF NOT EXISTS email VARCHAR(255);
UPDATE users SET name = username WHERE name IS NULL;
UPDATE users SET email = username || '@demo.roeid.local' WHERE email IS NULL;
