-- ULTIMATE FIX: Allow authenticated users to see BOTH their own forms AND public forms
-- This ensures logged-in users can view shared forms from other users
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
-- STEP 3: FORMS TABLE - COMBINED POLICIES
-- ============================================================================

-- Policy 1: Users can INSERT their own forms
CREATE POLICY "users_insert_own_forms" ON forms
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Policy 2: Users can SELECT their own forms OR active forms (for viewing shared forms)
CREATE POLICY "users_select_own_or_active_forms" ON forms
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id OR is_active = true);

-- Policy 3: Users can UPDATE only their own forms
CREATE POLICY "users_update_own_forms" ON forms
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy 4: Users can DELETE only their own forms
CREATE POLICY "users_delete_own_forms" ON forms
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Policy 5: Anonymous users can SELECT ONLY active forms
CREATE POLICY "anon_select_active_forms" ON forms
    FOR SELECT
    TO anon
    USING (is_active = true);

-- ============================================================================
-- STEP 4: FORM_FIELDS TABLE - COMBINED POLICIES
-- ============================================================================

-- Policy 1: Users can INSERT fields for their own forms
CREATE POLICY "users_insert_own_form_fields" ON form_fields
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Policy 2: Users can SELECT fields for their own forms OR active forms
CREATE POLICY "users_select_own_or_active_form_fields" ON form_fields
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND (forms.user_id = auth.uid() OR forms.is_active = true)
        )
    );

-- Policy 3: Users can UPDATE fields for their own forms only
CREATE POLICY "users_update_own_form_fields" ON form_fields
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

-- Policy 4: Users can DELETE fields for their own forms only
CREATE POLICY "users_delete_own_form_fields" ON form_fields
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
-- STEP 5: SUBMISSIONS TABLE - COMBINED POLICIES
-- ============================================================================

-- Policy 1: Users can SELECT submissions for their own forms only
CREATE POLICY "users_select_own_submissions" ON submissions
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Policy 2: Users can DELETE submissions for their own forms only
CREATE POLICY "users_delete_own_submissions" ON submissions
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Policy 3: Users can INSERT submissions to active forms (including other users' forms)
CREATE POLICY "users_insert_submissions_active_forms" ON submissions
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.is_active = true
        )
    );

-- Policy 4: Anonymous users can INSERT submissions ONLY to active forms
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
-- STEP 6: SUBMISSION_RESPONSES TABLE - COMBINED POLICIES
-- ============================================================================

-- Policy 1: Users can SELECT responses for their own forms only
CREATE POLICY "users_select_own_submission_responses" ON submission_responses
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

-- Policy 2: Users can DELETE responses for their own forms only
CREATE POLICY "users_delete_own_submission_responses" ON submission_responses
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

-- Policy 3: Users can INSERT responses to active forms (including other users' forms)
CREATE POLICY "users_insert_submission_responses_active" ON submission_responses
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE submissions.id = submission_responses.submission_id 
            AND forms.is_active = true
        )
    );

-- Policy 4: Anonymous users can INSERT responses ONLY to submissions of active forms
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
SELECT 
    tablename,
    policyname,
    CASE 
        WHEN roles = '{authenticated}' THEN 'authenticated'
        WHEN roles = '{anon}' THEN 'anonymous'
        ELSE roles::text
    END as user_type,
    cmd as operation
FROM pg_policies 
WHERE tablename IN ('forms', 'form_fields', 'submissions', 'submission_responses')
ORDER BY tablename, policyname;
