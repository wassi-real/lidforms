-- Run this to verify your RLS policies are correct
-- This will show you EXACTLY what policies are active

SELECT 
    schemaname,
    tablename,
    policyname,
    CASE 
        WHEN roles = '{authenticated}' THEN 'authenticated'
        WHEN roles = '{anon}' THEN 'anonymous'
        ELSE roles::text
    END as user_type,
    cmd as operation,
    CASE 
        WHEN qual IS NOT NULL THEN 'Has USING clause (SELECT/UPDATE/DELETE)'
        ELSE 'No USING clause'
    END as using_check,
    CASE 
        WHEN with_check IS NOT NULL THEN 'Has WITH CHECK clause (INSERT/UPDATE)'
        ELSE 'No WITH CHECK clause'
    END as with_check_clause
FROM pg_policies 
WHERE tablename IN ('forms', 'form_fields', 'submissions', 'submission_responses')
ORDER BY tablename, user_type, operation;

-- Expected output after running FINAL-SECURE-RLS.sql:
-- 
-- FORMS TABLE:
-- - 4 policies for 'authenticated' (INSERT, SELECT, UPDATE, DELETE) - only own forms
-- - 1 policy for 'anon' (SELECT) - only active forms
--
-- FORM_FIELDS TABLE:
-- - 4 policies for 'authenticated' (INSERT, SELECT, UPDATE, DELETE) - only own form fields
-- - 1 policy for 'anon' (SELECT) - only fields of active forms
--
-- SUBMISSIONS TABLE:
-- - 2 policies for 'authenticated' (SELECT, DELETE) - only submissions of own forms
-- - 1 policy for 'anon' (INSERT) - only to active forms
--
-- SUBMISSION_RESPONSES TABLE:
-- - 2 policies for 'authenticated' (SELECT, DELETE) - only responses of own forms
-- - 1 policy for 'anon' (INSERT) - only to active forms
