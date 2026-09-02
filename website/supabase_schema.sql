-- =========================================================================
-- ECOSYNAPSE SUPABASE CLOUD DATABASE SCHEMA & SEED SCRIPT
-- Paste this script into your Supabase SQL Editor (https://supabase.com)
-- =========================================================================

-- 1. Create Smart Bins Telemetry Table
CREATE TABLE IF NOT EXISTS bins (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'Residential',
    dry_fill INT NOT NULL DEFAULT 0,
    wet_fill INT NOT NULL DEFAULT 0,
    overall_fill INT NOT NULL DEFAULT 0,
    battery INT NOT NULL DEFAULT 100,
    weight NUMERIC(5, 2) NOT NULL DEFAULT 0.0,
    moisture_level INT NOT NULL DEFAULT 10,
    is_online BOOLEAN NOT NULL DEFAULT true,
    has_contamination BOOLEAN NOT NULL DEFAULT false,
    has_liquid_leak BOOLEAN NOT NULL DEFAULT false,
    predicted_full_hours NUMERIC(4, 1) NOT NULL DEFAULT 24.0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create Users & EcoPoints Table
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    user_type TEXT NOT NULL DEFAULT 'Resident', -- 'Resident' or 'Owner'
    flat_no TEXT NOT NULL,
    eco_points INT NOT NULL DEFAULT 0,
    eco_score INT NOT NULL DEFAULT 50,
    total_disposals INT NOT NULL DEFAULT 0,
    rank INT NOT NULL DEFAULT 42,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create Real-Time Audit Events Log Table
CREATE TABLE IF NOT EXISTS system_events (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    bin_id TEXT REFERENCES bins(id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    severity TEXT NOT NULL DEFAULT 'info'
);

-- 4. Create Available Rewards Table
CREATE TABLE IF NOT EXISTS rewards (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    cost_points INT NOT NULL,
    category TEXT NOT NULL,
    description TEXT NOT NULL
);

-- =========================================================================
-- ENABLE ROW LEVEL SECURITY (RLS) & POLICIES
-- =========================================================================
ALTER TABLE bins ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;

-- Allow public read access to all telemetry tables
CREATE POLICY "Public Read Access Bins" ON bins FOR SELECT USING (true);
CREATE POLICY "Public Read Access Users" ON users FOR SELECT USING (true);
CREATE POLICY "Public Read Access Events" ON system_events FOR SELECT USING (true);
CREATE POLICY "Public Read Access Rewards" ON rewards FOR SELECT USING (true);

-- Allow public write access for demo/telemetry ingestion
CREATE POLICY "Public Insert/Update Bins" ON bins FOR ALL USING (true);
CREATE POLICY "Public Insert/Update Users" ON users FOR ALL USING (true);
CREATE POLICY "Public Insert/Update Events" ON system_events FOR ALL USING (true);

-- Enable Realtime Subscriptions on Bins and Events tables
ALTER PUBLICATION supabase_realtime ADD TABLE bins;
ALTER PUBLICATION supabase_realtime ADD TABLE system_events;

-- =========================================================================
-- SEED INITIAL MOCK DATA FOR THE TEAM
-- =========================================================================
INSERT INTO bins (id, name, location, type, dry_fill, wet_fill, overall_fill, battery, weight, moisture_level, is_online, has_contamination, has_liquid_leak, predicted_full_hours)
VALUES 
('BIN-101', 'Tech Park Block A', 'Building A Entrance', 'Commercial', 42, 88, 65, 92, 14.2, 78, true, false, false, 3.5),
('BIN-102', 'Greenwood Block B', 'Tower B Lobby', 'Residential', 91, 95, 93, 78, 22.8, 85, true, true, true, 0.8),
('BIN-103', 'Greenwood Gate 2', 'Residential Gate 2', 'Residential', 25, 30, 28, 45, 6.5, 20, true, false, false, 18.2),
('BIN-104', 'Central Plaza Park', 'North Walking Track', 'Public Park', 70, 12, 41, 88, 9.1, 15, true, false, false, 7.4),
('BIN-105', 'Clubhouse Quad', 'Sports Complex Lobby', 'Residential', 15, 10, 12, 15, 2.1, 10, false, false, false, 42.0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO users (id, name, user_type, flat_no, eco_points, eco_score, total_disposals, rank)
VALUES 
('USR-1001', 'Ananya Sharma', 'Owner', 'C-701', 1450, 99, 112, 1),
('USR-1002', 'Vikram Mehta', 'Resident', 'B-304', 1280, 97, 98, 2),
('USR-1003', 'Priya Sundaram', 'Owner', 'A-102', 1150, 96, 85, 3),
('USR-1004', 'Rahul Verma', 'Resident', 'D-502', 980, 95, 74, 4),
('USR-1005', 'Kavita Nair', 'Owner', 'C-203', 890, 94, 68, 5),
('USR-1006', 'Arjun Patel', 'Resident', 'A-604', 820, 94, 61, 6),
('USR-1007', 'Sneha Kulkarni', 'Owner', 'B-801', 760, 93, 55, 7),
('USR-1008', 'Deepak Roy', 'Resident', 'D-101', 710, 93, 49, 8),
('USR-1009', 'Meera Deshmukh', 'Owner', 'A-303', 650, 92, 44, 9),
('USR-1010', 'Rohan Gupta', 'Resident', 'C-405', 610, 92, 40, 10),
('USR-8042', 'Sriram', 'Resident', 'A-402', 450, 92, 34, 42)
ON CONFLICT (id) DO NOTHING;

INSERT INTO rewards (id, title, cost_points, category, description)
VALUES 
('REW-101', '₹200 Maintenance Fee Voucher', 400, 'Apartment Perk', 'Direct credit towards your monthly apartment maintenance bill.'),
('REW-102', 'Free Organic Compost Bag (5kg)', 100, 'Gardening', 'Nutrient-rich organic compost produced from apartment wet waste.'),
('REW-103', 'Clubhouse Event Pass', 250, 'Lifestyle', 'Free 1-day pass for private event booking at the apartment clubhouse.'),
('REW-104', 'Eco Champion Badge & Certificate', 500, 'Recognition', 'Physical green certificate and plaque awarded at Society AGM.')
ON CONFLICT (id) DO NOTHING;

