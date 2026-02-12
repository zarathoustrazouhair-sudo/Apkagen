-- 1. Create Bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('blog_images', 'blog_images', true);

-- 2. RLS Policies for 'blog_images' bucket

-- Enable RLS on objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Allow SELECT (Read) for Authenticated Users (except Concierge, enforced by App logic but can be enforced here too)
CREATE POLICY "Public Read Access" ON storage.objects FOR SELECT USING ( bucket_id = 'blog_images' );

-- Allow INSERT (Upload) for Authenticated Users (Except Concierge)
CREATE POLICY "Authenticated Upload" ON storage.objects FOR INSERT WITH CHECK (
  bucket_id = 'blog_images' AND
  auth.role() = 'authenticated' AND
  (SELECT role FROM public.profiles WHERE id = auth.uid()) != 'concierge'
);

-- Allow UPDATE/DELETE for Author
CREATE POLICY "Author Modify" ON storage.objects FOR ALL USING (
  bucket_id = 'blog_images' AND
  auth.uid() = owner
);
