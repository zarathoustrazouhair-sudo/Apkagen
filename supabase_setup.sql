-- 1. Create the 'blog_images' bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('blog_images', 'blog_images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Enable RLS on storage.objects (just in case)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 3. Create Policy: Public Read Access for 'blog_images'
-- Drop first to allow re-running script without error
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
CREATE POLICY "Public Access"
  ON storage.objects FOR SELECT
  USING ( bucket_id = 'blog_images' );

-- 4. Create Policy: Authenticated Upload for 'blog_images'
DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;
CREATE POLICY "Authenticated Upload"
  ON storage.objects FOR INSERT
  WITH CHECK ( bucket_id = 'blog_images' AND auth.role() = 'authenticated' );

-- 5. Create 'blog_posts' table
CREATE TABLE IF NOT EXISTS public.blog_posts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  title text NOT NULL,
  content text NOT NULL,
  image_url text NULL,
  author_id uuid NOT NULL REFERENCES auth.users(id),
  CONSTRAINT blog_posts_pkey PRIMARY KEY (id)
);

-- 6. Enable RLS on blog_posts
ALTER TABLE public.blog_posts ENABLE ROW LEVEL SECURITY;

-- 7. Policies for blog_posts
DROP POLICY IF EXISTS "Enable read access for all users" ON "public"."blog_posts";
CREATE POLICY "Enable read access for all users" ON "public"."blog_posts"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON "public"."blog_posts";
CREATE POLICY "Enable insert for authenticated users only" ON "public"."blog_posts"
AS PERMISSIVE FOR INSERT
TO authenticated
WITH CHECK (true);
