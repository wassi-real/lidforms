-- SECURE RLS Fix: Only owners see their forms, public can only see shared forms
-- Run this in your Supabase SQL Editor to fix the security issue

-- Drop ALL existing policies first
DROP POLICY IF EXISTS "Allow public read access to forms" ON forms;
DROP POLICY IF EXISTS "Allow public read access to form fields" ON form_fields;
DROP POLICY IF EXISTS "Allow public read access to submissions" ON submissions;
DROP POLICY IF EXISTS "Allow public read access to submission responses" ON submission_responses;
DROP POLICY IF EXISTS "Users can only read their own forms" ON forms;
DROP POLICY IF EXISTS "Users can only read their own form fields" ON form_fields;
DROP POLICY IF EXISTS "Users can only read their own submissions" ON submissions;
DROP POLICY IF EXISTS "Users can only read their own submission responses" ON submission_responses;

-- ============================================================================
-- FORMS TABLE POLICIES
-- ============================================================================

-- SECURE: Only form owners can read their own forms for management
CREATE POLICY "Form owners can read their own forms" ON forms
    FOR SELECT
    USING (auth.uid() = user_id);

-- SECURE: Only form owners can update their own forms
CREATE POLICY "Form owners can update their own forms" ON forms
    FOR UPDATE
    USING (auth.uid() = user_id);

-- SECURE: Only form owners can delete their own forms
CREATE POLICY "Form owners can delete their own forms" ON forms
    FOR DELETE
    USING (auth.uid() = user_id);

-- SECURE: Only authenticated users can create forms
CREATE POLICY "Authenticated users can create forms" ON forms
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- PUBLIC: Anyone can read ACTIVE forms (for sharing)
CREATE POLICY "Public can read active forms" ON forms
    FOR SELECT
    USING (is_active = true);

-- ============================================================================
-- FORM FIELDS TABLE POLICIES
-- ============================================================================

-- SECURE: Only form owners can read form fields for their own forms
CREATE POLICY "Form owners can read their own form fields" ON form_fields
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- SECURE: Only form owners can manage form fields for their own forms
CREATE POLICY "Form owners can insert their own form fields" ON form_fields
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

CREATE POLICY "Form owners can update their own form fields" ON form_fields
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

CREATE POLICY "Form owners can delete their own form fields" ON form_fields
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- PUBLIC: Anyone can read form fields for ACTIVE forms (for sharing)
CREATE POLICY "Public can read form fields for active forms" ON form_fields
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = form_fields.form_id 
            AND forms.is_active = true
        )
    );

-- ============================================================================
-- SUBMISSIONS TABLE POLICIES
-- ============================================================================

-- SECURE: Only form owners can read submissions for their own forms
CREATE POLICY "Form owners can read submissions for their own forms" ON submissions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- SECURE: Only form owners can delete submissions for their own forms
CREATE POLICY "Form owners can delete submissions for their own forms" ON submissions
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.user_id = auth.uid()
        )
    );

-- PUBLIC: Anyone can insert submissions (for form submissions)
CREATE POLICY "Public can insert submissions" ON submissions
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.is_active = true
        )
    );

-- PUBLIC: Anyone can read their own submissions (for confirmation)
CREATE POLICY "Public can read submissions for active forms" ON submissions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM forms 
            WHERE forms.id = submissions.form_id 
            AND forms.is_active = true
        )
    );

-- ============================================================================
-- SUBMISSION RESPONSES TABLE POLICIES
-- ============================================================================

-- SECURE: Only form owners can read submission responses for their own forms
CREATE POLICY "Form owners can read submission responses for their own forms" ON submission_responses
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE submissions.id = submission_responses.submission_id 
            AND forms.user_id = auth.uid()
        )
    );

-- SECURE: Only form owners can delete submission responses for their own forms
CREATE POLICY "Form owners can delete submission responses for their own forms" ON submission_responses
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE submissions.id = submission_responses.submission_id 
            AND forms.user_id = auth.uid()
        )
    );

-- PUBLIC: Anyone can insert submission responses (for form submissions)
CREATE POLICY "Public can insert submission responses" ON submission_responses
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE forms.is_active = true
        )
    );

-- PUBLIC: Anyone can read submission responses for active forms (for confirmation)
CREATE POLICY "Public can read submission responses for active forms" ON submission_responses
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE forms.is_active = true
        )
    );
