-- FINAL SECURE RLS FIX - Completely remove all policies and start fresh
-- This ensures NO duplicate or conflicting policies exist
-- Run this in your Supabase SQL Editor

-- ============================================================================
-- STEP 1: COMPLETELY DROP ALL EXISTING POLICIES
-- ============================================================================

-- Drop ALL policies on forms table
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'forms') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON forms';
    END LOOP;
END $$;

-- Drop ALL policies on form_fields table
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'form_fields') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON form_fields';
    END LOOP;
END $$;

-- Drop ALL policies on submissions table
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'submissions') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON submissions';
    END LOOP;
END $$;

-- Drop ALL policies on submission_responses table
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'submission_responses') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON submission_responses';
    END LOOP;
END $$;

-- ============================================================================
-- STEP 2: ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE submission_responses ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 3: FORMS TABLE - STRICT POLICIES
-- ============================================================================

-- Policy 1: Authenticated users can INSERT their own forms
CREATE POLICY "auth_insert_own_forms" ON forms
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Policy 2: Authenticated users can SELECT their own forms
CREATE POLICY "auth_select_own_forms" ON forms
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Policy 3: Authenticated users can UPDATE their own forms
CREATE POLICY "auth_update_own_forms" ON forms
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy 4: Authenticated users can DELETE their own forms
CREATE POLICY "auth_delete_own_forms" ON forms
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Policy 5: Anonymous users can SELECT ONLY active forms
CREATE POLICY "anon_select_active_forms" ON forms
    FOR SELECT
    TO anon
    USING (is_active = true);

-- ============================================================================
-- STEP 4: FORM_FIELDS TABLE - STRICT POLICIES
-- ============================================================================

-- Policy 1: Authenticated users can INSERT fields for their own forms
CREATE POLICY "auth_insert_own_form_fields" ON form_fields
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Policy 2: Authenticated users can SELECT fields for their own forms
CREATE POLICY "auth_select_own_form_fields" ON form_fields
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Policy 3: Authenticated users can UPDATE fields for their own forms
CREATE POLICY "auth_update_own_form_fields" ON form_fields
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Policy 4: Authenticated users can DELETE fields for their own forms
CREATE POLICY "auth_delete_own_form_fields" ON form_fields
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Policy 5: Anonymous users can SELECT fields ONLY for active forms
CREATE POLICY "anon_select_active_form_fields" ON form_fields
    FOR SELECT
    TO anon
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.is_active = true
        )
    );

-- ============================================================================
-- STEP 5: SUBMISSIONS TABLE - STRICT POLICIES
-- ============================================================================

-- Policy 1: Authenticated users can SELECT submissions for their own forms
CREATE POLICY "auth_select_own_submissions" ON submissions
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Policy 2: Authenticated users can DELETE submissions for their own forms
CREATE POLICY "auth_delete_own_submissions" ON submissions
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Policy 3: Anonymous users can INSERT submissions ONLY to active forms
CREATE POLICY "anon_insert_submissions_active_forms" ON submissions
    FOR INSERT
    TO anon
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.is_active = true
        )
    );

-- ============================================================================
-- STEP 6: SUBMISSION_RESPONSES TABLE - STRICT POLICIES
-- ============================================================================

-- Policy 1: Authenticated users can SELECT responses for their own forms
CREATE POLICY "auth_select_own_submission_responses" ON submission_responses
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE submissions.id = submission_responses.submission_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Policy 2: Authenticated users can DELETE responses for their own forms
CREATE POLICY "auth_delete_own_submission_responses" ON submission_responses
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE submissions.id = submission_responses.submission_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Policy 3: Anonymous users can INSERT responses ONLY to submissions of active forms
CREATE POLICY "anon_insert_submission_responses_active" ON submission_responses
    FOR INSERT
    TO anon
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE submissions.id = submission_responses.submission_id 
            AND forms.is_active = true
        )
    );

-- ============================================================================
-- STEP 7: VERIFICATION - List all policies
-- ============================================================================

-- Run this to verify policies are correct:
SELECT schemaname, tablename, policyname, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename IN ('forms', 'form_fields', 'submissions', 'submission_responses')
ORDER BY tablename, policyname;
