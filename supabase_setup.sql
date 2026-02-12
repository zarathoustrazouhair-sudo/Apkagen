-- Create bucket 'blog_images'
INSERT INTO storage.buckets (id, name, public)
VALUES ('blog_images', 'blog_images', true)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Policy to allow public read access
CREATE POLICY "Public Access"
  ON storage.objects FOR SELECT
  USING ( bucket_id = 'blog_images' );

-- Policy to allow authenticated uploads
CREATE POLICY "Authenticated Upload"
  ON storage.objects FOR INSERT
  WITH CHECK ( bucket_id = 'blog_images' AND auth.role() = 'authenticated' );

-- Create 'blog_posts' table
CREATE TABLE IF NOT EXISTS public.blog_posts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  title text NOT NULL,
  content text NOT NULL,
  image_url text NULL,
  author_id uuid NOT NULL REFERENCES auth.users(id),
  CONSTRAINT blog_posts_pkey PRIMARY KEY (id)
);

-- Enable RLS on blog_posts
ALTER TABLE public.blog_posts ENABLE ROW LEVEL SECURITY;

-- Allow read access to everyone
CREATE POLICY "Enable read access for all users" ON "public"."blog_posts"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

-- Allow authenticated users to insert posts
CREATE POLICY "Enable insert for authenticated users only" ON "public"."blog_posts"
AS PERMISSIVE FOR INSERT
TO authenticated
WITH CHECK (true);
