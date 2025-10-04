-- SIMPLE RLS FIX - Clean and straightforward
-- This keeps RLS enabled but makes the rules simple and clear
-- Run this in your Supabase SQL Editor

-- ============================================================================
-- STEP 1: DROP ALL EXISTING POLICIES
-- ============================================================================

DO $$ 
DECLARE 
    r RECORD;
BEGIN
    -- Drop all policies on forms
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'forms') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON forms';
    END LOOP;
    
    -- Drop all policies on form_fields
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'form_fields') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON form_fields';
    END LOOP;
    
    -- Drop all policies on submissions
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'submissions') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON submissions';
    END LOOP;
    
    -- Drop all policies on submission_responses
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'submission_responses') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON submission_responses';
    END LOOP;
END $$;

-- ============================================================================
-- STEP 2: CREATE SIMPLE, CLEAR POLICIES
-- ============================================================================

-- FORMS TABLE
-- Dashboard: Users see only their own forms (code filters with .eq('user_id'))
-- Public: Anyone can see active forms (code filters with .eq('is_active', true))
CREATE POLICY "forms_select" ON forms FOR SELECT USING (
    auth.uid() = user_id OR is_active = true
);

CREATE POLICY "forms_insert" ON forms FOR INSERT WITH CHECK (
    auth.uid() = user_id
);

CREATE POLICY "forms_update" ON forms FOR UPDATE USING (
    auth.uid() = user_id
);

CREATE POLICY "forms_delete" ON forms FOR DELETE USING (
    auth.uid() = user_id
);

-- FORM FIELDS TABLE  
-- Users can manage fields for their own forms
-- Anyone can view fields for active forms
CREATE POLICY "form_fields_select" ON form_fields FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM forms 
        WHERE forms.id = form_fields.form_id 
        AND (forms.user_id = auth.uid() OR forms.is_active = true)
    )
);

CREATE POLICY "form_fields_insert" ON form_fields FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM forms 
        WHERE forms.id = form_fields.form_id 
        AND forms.user_id = auth.uid()
    )
);

CREATE POLICY "form_fields_update" ON form_fields FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM forms 
        WHERE forms.id = form_fields.form_id 
        AND forms.user_id = auth.uid()
    )
);

CREATE POLICY "form_fields_delete" ON form_fields FOR DELETE USING (
    EXISTS (
        SELECT 1 FROM forms 
        WHERE forms.id = form_fields.form_id 
        AND forms.user_id = auth.uid()
    )
);

-- SUBMISSIONS TABLE
-- Users can view/manage submissions for their own forms
-- Anyone can submit to active forms
CREATE POLICY "submissions_select" ON submissions FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM forms 
        WHERE forms.id = submissions.form_id 
        AND forms.user_id = auth.uid()
    )
);

CREATE POLICY "submissions_insert" ON submissions FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM forms 
        WHERE forms.id = submissions.form_id 
        AND forms.is_active = true
    )
);

CREATE POLICY "submissions_delete" ON submissions FOR DELETE USING (
    EXISTS (
        SELECT 1 FROM forms 
        WHERE forms.id = submissions.form_id 
        AND forms.user_id = auth.uid()
    )
);

-- SUBMISSION RESPONSES TABLE
-- Users can view/manage responses for their own forms
-- Anyone can submit responses to active forms
CREATE POLICY "submission_responses_select" ON submission_responses FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM submissions 
        JOIN forms ON forms.id = submissions.form_id 
        WHERE submissions.id = submission_responses.submission_id 
        AND forms.user_id = auth.uid()
    )
);

CREATE POLICY "submission_responses_insert" ON submission_responses FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM submissions 
        JOIN forms ON forms.id = submissions.form_id 
        WHERE submissions.id = submission_responses.submission_id 
        AND forms.is_active = true
    )
);

CREATE POLICY "submission_responses_delete" ON submission_responses FOR DELETE USING (
    EXISTS (
        SELECT 1 FROM submissions 
        JOIN forms ON forms.id = submissions.form_id 
        WHERE submissions.id = submission_responses.submission_id 
        AND forms.user_id = auth.uid()
    )
);

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SELECT 
    tablename,
    policyname,
    cmd as operation
FROM pg_policies 
WHERE tablename IN ('forms', 'form_fields', 'submissions', 'submission_responses')
ORDER BY tablename, policyname;
