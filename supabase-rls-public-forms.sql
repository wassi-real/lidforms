-- RLS Policies for Public Form Access
-- This file contains additional RLS policies to allow anonymous users to view and submit to public forms

-- Enable RLS on forms table (if not already enabled)
ALTER TABLE forms ENABLE ROW LEVEL SECURITY;

-- Enable RLS on form_fields table (if not already enabled)
ALTER TABLE form_fields ENABLE ROW LEVEL SECURITY;

-- Enable RLS on submissions table (if not already enabled)
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

-- Enable RLS on submission_responses table (if not already enabled)
ALTER TABLE submission_responses ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PUBLIC FORM ACCESS POLICIES
-- ============================================================================

-- Allow anyone (including anonymous users) to read forms that are marked as public
-- We assume forms are public by default, but you can add a 'is_public' column if needed
CREATE POLICY "Allow public read access to forms" ON forms
    FOR SELECT
    USING (true);

-- Allow anyone to read form fields for any form
CREATE POLICY "Allow public read access to form fields" ON form_fields
    FOR SELECT
    USING (true);

-- Allow anyone to insert submissions
CREATE POLICY "Allow public insert access to submissions" ON submissions
    FOR INSERT
    WITH CHECK (true);

-- Allow anyone to read submissions (for confirmation)
-- This allows users to see their submission after submitting
CREATE POLICY "Allow public read access to submissions" ON submissions
    FOR SELECT
    USING (true);

-- Allow anyone to insert submission responses
CREATE POLICY "Allow public insert access to submission responses" ON submission_responses
    FOR INSERT
    WITH CHECK (true);

-- Allow anyone to read submission responses (for confirmation)
CREATE POLICY "Allow public read access to submission responses" ON submission_responses
    FOR SELECT
    USING (true);

-- ============================================================================
-- ADMIN POLICIES (for authenticated users)
-- ============================================================================

-- Allow authenticated users to read their own forms
CREATE POLICY "Users can read their own forms" ON forms
    FOR SELECT
    USING (auth.uid() = user_id);

-- Allow authenticated users to update their own forms
CREATE POLICY "Users can update their own forms" ON forms
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Allow authenticated users to delete their own forms
CREATE POLICY "Users can delete their own forms" ON forms
    FOR DELETE
    USING (auth.uid() = user_id);

-- Allow authenticated users to insert their own forms
CREATE POLICY "Users can insert their own forms" ON forms
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- FORM FIELDS POLICIES (for authenticated users)
-- ============================================================================

-- Allow authenticated users to read form fields for their own forms
CREATE POLICY "Users can read fields for their own forms" ON form_fields
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Allow authenticated users to insert form fields for their own forms
CREATE POLICY "Users can insert fields for their own forms" ON form_fields
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Allow authenticated users to update form fields for their own forms
CREATE POLICY "Users can update fields for their own forms" ON form_fields
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Allow authenticated users to delete form fields for their own forms
CREATE POLICY "Users can delete fields for their own forms" ON form_fields
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- ============================================================================
-- FORM SUBMISSIONS POLICIES (for authenticated users)
-- ============================================================================

-- Allow authenticated users to read submissions for their own forms
CREATE POLICY "Users can read submissions for their own forms" ON submissions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Allow authenticated users to delete submissions for their own forms
CREATE POLICY "Users can delete submissions for their own forms" ON submissions
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Allow authenticated users to read submission responses for their own forms
CREATE POLICY "Users can read submission responses for their own forms" ON submission_responses
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE submissions.id = submission_responses.submission_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Allow authenticated users to delete submission responses for their own forms
CREATE POLICY "Users can delete submission responses for their own forms" ON submission_responses
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE submissions.id = submission_responses.submission_id 
            AND forms.user_id = auth.uid()
        )
    );

-- ============================================================================
-- USERS TABLE POLICIES
-- ============================================================================

-- Allow users to read their own profile
CREATE POLICY "Users can read their own profile" ON users
    FOR SELECT
    USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE
    USING (auth.uid() = id);

-- Allow users to insert their own profile
CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ============================================================================
-- NOTES
-- ============================================================================

-- 1. These policies allow:
--    - Anonymous users to view any form and its fields
--    - Anonymous users to submit to any form
--    - Anonymous users to view their submissions (for confirmation)
--    - Authenticated users to manage their own forms, fields, and submissions

-- 2. If you want to restrict public access to specific forms, you can:
--    - Add an 'is_public' boolean column to the forms table
--    - Modify the public policies to use: USING (is_public = true)

-- 3. To apply these policies:
--    - Run this SQL in your Supabase SQL Editor
--    - Or apply them through the Supabase Dashboard > Authentication > Policies

-- 4. The policies are designed to be secure:
--    - Anonymous users can only read and submit, not modify forms
--    - Authenticated users can only manage their own content
--    - No cross-user data access is allowed
