-- Create the "user" table manually if Hibernate doesn't
CREATE TABLE IF NOT EXISTS "user" (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

-- Insert test data

INSERT INTO "user" (username, password) 
VALUES ('testuser', 'testpassword') 
ON CONFLICT (username) 
DO NOTHING;

