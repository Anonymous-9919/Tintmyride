-- ============================================
-- Supabase Storage Configuration
-- Run this in Supabase SQL Editor after the migration
-- ============================================

-- Create storage bucket for website assets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'website-assets',
  'website-assets',
  true,
  10485760, -- 10MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml', 'application/pdf']
);

-- Allow public access to view files
CREATE POLICY "Public can view website assets"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'website-assets');

-- Allow authenticated users to upload their own files
CREATE POLICY "Users can upload their own assets"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'website-assets'
    AND auth.uid() = (storage.foldername(name))[1]::uuid
  );

-- Allow users to update their own files
CREATE POLICY "Users can update their own assets"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'website-assets'
    AND auth.uid() = (storage.foldername(name))[1]::uuid
  );

-- Allow users to delete their own files
CREATE POLICY "Users can delete their own assets"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'website-assets'
    AND auth.uid() = (storage.foldername(name))[1]::uuid
  ); 