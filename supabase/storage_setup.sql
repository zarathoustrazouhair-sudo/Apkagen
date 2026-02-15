-- Create the blog_images bucket
insert into storage.buckets (id, name, public)
values ('blog_images', 'blog_images', true);

-- Enable RLS for storage.objects
alter table storage.objects enable row level security;

-- Allow Public Access for Reading
create policy "Public Access"
on storage.objects for select
using ( bucket_id = 'blog_images' );

-- Allow Authenticated Users to Upload
create policy "Auth Upload"
on storage.objects for insert
with check ( bucket_id = 'blog_images' and auth.role() = 'authenticated' );

-- Allow Authenticated Users to Update (if needed)
create policy "Auth Update"
on storage.objects for update
using ( bucket_id = 'blog_images' and auth.role() = 'authenticated' );

-- Allow Authenticated Users to Delete (if needed)
create policy "Auth Delete"
on storage.objects for delete
using ( bucket_id = 'blog_images' and auth.role() = 'authenticated' );
