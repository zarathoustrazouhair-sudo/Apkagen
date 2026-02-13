-- Create the storage bucket for blog images if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('blog_images', 'blog_images', true)
ON CONFLICT (id) DO NOTHING;

-- Policy to allow public read access to the blog_images bucket
create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'blog_images' );

-- Policy to allow authenticated uploads (Restrict to authenticated users in a real app,
-- but for this MVP/Demo we might allow public or just authenticated)
-- Assuming the app uses Supabase Auth or we want to allow uploads for the demo.
-- Let's allow public inserts for now to avoid auth issues in this demo context if auth is bypassed.
create policy "Public Upload"
  on storage.objects for insert
  with check ( bucket_id = 'blog_images' );

-- Policy for updates/deletes if needed
create policy "Public Update"
  on storage.objects for update
  using ( bucket_id = 'blog_images' );

create policy "Public Delete"
  on storage.objects for delete
  using ( bucket_id = 'blog_images' );
