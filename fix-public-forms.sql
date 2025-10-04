-- Quick Fix: Allow Public Access to Forms
-- Run this in your Supabase SQL Editor to immediately fix the public form access issue

-- Drop existing restrictive policies (if they exist)
DROP POLICY IF EXISTS "Users can only read their own forms" ON forms;
DROP POLICY IF EXISTS "Users can only read their own form fields" ON form_fields;
DROP POLICY IF EXISTS "Users can only read their own submissions" ON submissions;
DROP POLICY IF EXISTS "Users can only read their own submission responses" ON submission_responses;

-- Allow anyone to read forms (for public access)
CREATE POLICY "Allow public read access to forms" ON forms
    FOR SELECT
    USING (true);

-- Allow anyone to read form fields (for public access)
CREATE POLICY "Allow public read access to form fields" ON form_fields
    FOR SELECT
    USING (true);

-- Allow anyone to insert submissions (for public submissions)
CREATE POLICY "Allow public insert access to submissions" ON submissions
    FOR INSERT
    WITH CHECK (true);

-- Allow anyone to read submissions (for confirmation after submission)
CREATE POLICY "Allow public read access to submissions" ON submissions
    FOR SELECT
    USING (true);

-- Allow anyone to insert submission responses (for public submissions)
CREATE POLICY "Allow public insert access to submission responses" ON submission_responses
    FOR INSERT
    WITH CHECK (true);

-- Allow anyone to read submission responses (for confirmation after submission)
CREATE POLICY "Allow public read access to submission responses" ON submission_responses
    FOR SELECT
    USING (true);

-- Keep the existing authenticated user policies for form management
-- (These should already exist from your original schema)

-- Test the fix by checking if anonymous users can now access forms
-- You can test this by opening your form URL in an incognito browser window
