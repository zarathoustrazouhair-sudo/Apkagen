-- Create the bucket for blog images
INSERT INTO storage.buckets (id, name, public)
VALUES ('blog_images', 'blog_images', true)
ON CONFLICT (id) DO NOTHING;

-- Policy to allow public access to images
CREATE POLICY "Public Access"
  ON storage.objects FOR SELECT
  USING ( bucket_id = 'blog_images' );

-- Policy to allow authenticated uploads (Syndic/Admin)
CREATE POLICY "Authenticated Upload"
  ON storage.objects FOR INSERT
  WITH CHECK ( bucket_id = 'blog_images' AND auth.role() = 'authenticated' );

-- Policy to allow authenticated updates
CREATE POLICY "Authenticated Update"
  ON storage.objects FOR UPDATE
  USING ( bucket_id = 'blog_images' AND auth.role() = 'authenticated' );

-- Policy to allow authenticated deletes
CREATE POLICY "Authenticated Delete"
  ON storage.objects FOR DELETE
  USING ( bucket_id = 'blog_images' AND auth.role() = 'authenticated' );
