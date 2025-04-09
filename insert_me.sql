CREATE TABLE IF NOT EXISTS nexus_bans (
    banID VARCHAR(10) PRIMARY KEY,
    discordID VARCHAR(50) NOT NULL,
    license VARCHAR(100) NOT NULL,
    reason TEXT,
    bannedBy VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
