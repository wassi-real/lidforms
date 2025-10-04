# Public Forms Access Setup

## Problem
Anonymous users (logged out users) cannot view or submit to shared form URLs. They see "form can't be found" error.

## Root Cause
The current RLS (Row Level Security) policies only allow authenticated users to access forms, fields, and submissions.

## Solution

### Option 1: Quick Fix (Recommended)
Run the SQL commands in `fix-public-forms.sql` in your Supabase SQL Editor:

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `fix-public-forms.sql`
4. Click **Run**

This will immediately allow anonymous users to:
- ✅ View any form
- ✅ View form fields  
- ✅ Submit to forms (creates records in `submissions` and `submission_responses` tables)
- ✅ See submission confirmation

### Option 2: Complete RLS Setup
For a more comprehensive setup, use `supabase-rls-public-forms.sql` which includes:
- Public access policies
- Authenticated user management policies
- Secure data isolation
- Complete form lifecycle management

## Testing

After applying the fix:

1. **Open an incognito/private browser window**
2. **Navigate to a form URL** (e.g., `https://yourdomain.com/f/your-form-id`)
3. **Verify**:
   - ✅ Form loads without login required
   - ✅ Form fields are visible
   - ✅ Can submit the form
   - ✅ See success message after submission

## Security Notes

The quick fix allows:
- **Read access**: Anyone can view forms and fields
- **Submit access**: Anyone can submit to forms
- **No modification**: Anonymous users cannot edit or delete forms
- **Owner control**: Authenticated users still manage their own forms

This is appropriate for a form builder where you want to collect public submissions.

## Alternative: Restricted Public Access

If you want to restrict which forms are publicly accessible:

1. Add a `is_public` column to the forms table:
   ```sql
   ALTER TABLE forms ADD COLUMN is_public BOOLEAN DEFAULT true;
   ```

2. Update the policies to check this column:
   ```sql
   CREATE POLICY "Allow public read access to public forms" ON forms
       FOR SELECT
       USING (is_public = true);
   ```

3. Set specific forms as private by updating the `is_public` column to `false`

## Files Created

- `fix-public-forms.sql` - Quick fix for immediate public access
- `supabase-rls-public-forms.sql` - Complete RLS policy setup
- `PUBLIC_FORMS_SETUP.md` - This documentation

## Next Steps

1. Run the SQL fix in Supabase
2. Test form sharing with anonymous users
3. Verify submissions are being collected
4. Check that form owners can still manage their forms
