# LidForm - Quick Reference Guide

## 🚀 Quick Commands

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Format code
npm run format

# Check code
npm run check
```

## 🔗 Important URLs (Development)

- **Landing Page:** http://localhost:5173
- **Login:** http://localhost:5173/auth/login
- **Signup:** http://localhost:5173/auth/signup
- **Dashboard:** http://localhost:5173/dashboard
- **Form Submission:** http://localhost:5173/f/{form-id}

## 📋 Database Tables

### `forms`
- `id` - UUID (primary key)
- `user_id` - UUID (foreign key to auth.users)
- `title` - VARCHAR(255)
- `description` - TEXT
- `thank_you_message` - TEXT
- `is_active` - BOOLEAN
- `created_at` - TIMESTAMP
- `updated_at` - TIMESTAMP

### `form_fields`
- `id` - UUID (primary key)
- `form_id` - UUID (foreign key to forms)
- `field_type` - VARCHAR(50) - enum: text, email, phone, dropdown, file
- `label` - VARCHAR(255)
- `placeholder` - VARCHAR(255)
- `required` - BOOLEAN
- `options` - JSONB (for dropdown options)
- `position` - INTEGER
- `created_at` - TIMESTAMP

### `submissions`
- `id` - UUID (primary key)
- `form_id` - UUID (foreign key to forms)
- `submitted_at` - TIMESTAMP
- `user_agent` - TEXT
- `ip_address` - INET

### `submission_responses`
- `id` - UUID (primary key)
- `submission_id` - UUID (foreign key to submissions)
- `field_id` - UUID (foreign key to form_fields)
- `value` - TEXT
- `created_at` - TIMESTAMP

## 🔐 Environment Variables

Create a `.env` file with:

```env
PUBLIC_SUPABASE_URL=https://your-project.supabase.co
PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

## 🎨 Color Palette

### Primary Colors
- **Indigo:** `bg-indigo-600`, `text-indigo-600`
- **Blue:** `bg-blue-600`, `text-blue-600`
- **Purple:** `bg-purple-600`, `text-purple-600`

### Status Colors
- **Success:** `bg-green-600`, `text-green-600`
- **Error:** `bg-red-600`, `text-red-600`
- **Warning:** `bg-yellow-600`, `text-yellow-600`

### Neutral Colors
- **Gray:** `bg-gray-50`, `bg-gray-100`, `bg-gray-600`, `bg-gray-900`

## 📝 Common Operations

### Create a New Form (Programmatically)

```typescript
const { data: newForm, error } = await supabase
  .from('forms')
  .insert({
    title: 'My Form',
    description: 'Form description',
    user_id: user.id,
    is_active: true
  })
  .select()
  .single();
```

### Add Fields to a Form

```typescript
const fields = [
  {
    form_id: formId,
    field_type: 'email',
    label: 'Email Address',
    placeholder: 'your@email.com',
    required: true,
    position: 0
  },
  {
    form_id: formId,
    field_type: 'text',
    label: 'Full Name',
    placeholder: 'John Doe',
    required: true,
    position: 1
  }
];

const { error } = await supabase
  .from('form_fields')
  .insert(fields);
```

### Query Form with Fields

```typescript
const { data: form } = await supabase
  .from('forms')
  .select(`
    *,
    form_fields (*)
  `)
  .eq('id', formId)
  .single();
```

### Submit a Form Response

```typescript
// 1. Create submission
const { data: submission } = await supabase
  .from('submissions')
  .insert({
    form_id: formId
  })
  .select()
  .single();

// 2. Create responses
const responses = fields.map(field => ({
  submission_id: submission.id,
  field_id: field.id,
  value: formData[field.id]
}));

await supabase
  .from('submission_responses')
  .insert(responses);
```

### Get All Submissions with Responses

```typescript
const { data: submissions } = await supabase
  .from('submissions')
  .select(`
    id,
    submitted_at,
    submission_responses (
      id,
      field_id,
      value
    )
  `)
  .eq('form_id', formId)
  .order('submitted_at', { ascending: false });
```

## 🛡️ RLS Policies Summary

### Forms
- Users can view/create/update/delete their own forms
- No public access to forms table

### Form Fields
- Users can manage fields of their own forms
- Anyone can view fields of active forms (for submission page)

### Submissions
- Anyone can create submissions for active forms
- Form owners can view submissions of their forms

### Submission Responses
- Anyone can create responses when submitting
- Form owners can view responses

## 🔧 Troubleshooting

### Issue: "Row level security is enabled but no policies exist"
**Solution:** Run the entire `supabase-schema.sql` file in Supabase SQL Editor

### Issue: "Auth session missing"
**Solution:** Check that cookies are enabled and Supabase hooks are properly configured

### Issue: "Cannot read properties of undefined"
**Solution:** Ensure all data is loaded before rendering (use loading states)

### Issue: "CORS error"
**Solution:** Add your domain to Supabase allowed origins in Project Settings

### Issue: Form not accepting submissions
**Solution:** Check that `is_active` is set to `true` on the form

## 📦 Project Dependencies

### Core
- `@sveltejs/kit` - Framework
- `svelte` - UI library
- `@supabase/supabase-js` - Supabase client
- `@supabase/ssr` - Server-side rendering support

### Styling
- `tailwindcss` - CSS framework
- `@tailwindcss/forms` - Form styling
- `@tailwindcss/typography` - Typography plugin

### Development
- `typescript` - Type checking
- `vite` - Build tool
- `prettier` - Code formatting

## 🎯 Key Files to Know

| File | Purpose |
|------|---------|
| `src/hooks.server.ts` | Server-side authentication |
| `src/routes/+layout.ts` | Client-side Supabase setup |
| `src/routes/+layout.server.ts` | Server-side session management |
| `supabase-schema.sql` | Complete database schema |
| `.env` | Environment variables (don't commit!) |
| `svelte.config.js` | SvelteKit configuration |
| `vite.config.ts` | Vite configuration |

## 📞 Support Resources

- **Supabase Docs:** https://supabase.com/docs
- **SvelteKit Docs:** https://kit.svelte.dev/docs
- **Tailwind CSS:** https://tailwindcss.com/docs
- **Svelte 5 Docs:** https://svelte-5-preview.vercel.app/docs

## 💡 Pro Tips

1. **Always test in incognito mode** to verify authentication flows
2. **Use browser DevTools** to inspect Supabase queries
3. **Check Supabase Logs** in the dashboard for RLS issues
4. **Use TypeScript** for better type safety with Supabase
5. **Enable email confirmation** in production for security

---

**Happy Building! 🚀**

