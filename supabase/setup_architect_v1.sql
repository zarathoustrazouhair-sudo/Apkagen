-- ARCHITECT V1 SETUP
-- 1. Table: apartments_status (Real-time Balance Mirror)
CREATE TABLE IF NOT EXISTS public.apartments_status (
    apartment_number INT PRIMARY KEY,
    current_balance FLOAT NOT NULL DEFAULT 0.0,
    last_updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.apartments_status ENABLE ROW LEVEL SECURITY;

-- Syndic/Adjoint (Admin) can UPSERT
-- Assuming 'role' claim or simple authenticated check for MVP
CREATE POLICY "Admins can update balances" ON public.apartments_status
    FOR ALL
    USING (auth.role() = 'authenticated') -- Refine with role check in prod
    WITH CHECK (auth.role() = 'authenticated');

-- Residents can SELECT
CREATE POLICY "Everyone can read balances" ON public.apartments_status
    FOR SELECT
    USING (true); -- Public read for transparency or auth restricted

-- 2. Storage Buckets
INSERT INTO storage.buckets (id, name, public)
VALUES ('receipts', 'receipts', false) -- Auth only
ON CONFLICT (id) DO NOTHING;

-- Policies for receipts
CREATE POLICY "Auth read receipts" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'receipts' AND auth.role() = 'authenticated');

CREATE POLICY "Admin upload receipts" ON storage.objects
    FOR INSERT
    WITH CHECK (bucket_id = 'receipts' AND auth.role() = 'authenticated');
