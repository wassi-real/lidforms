# LidForm - Simple Form Builder 📋

A **minimal but scalable MVP** for a form web app where businesses can create forms, share them, and collect submissions.

## 🎯 Project Goal

A **simple web app** where businesses can create forms (feedback, contact, survey, onboarding, order forms, etc.), share a link, and collect submissions.

---

## ✅ Implemented Features

### 1. **Landing Page** ✓
* Beautiful gradient design with modern UI
* Clear headline: "Create simple forms in seconds"
* Prominent CTA: "Start Free"
* Feature highlights and pricing tiers displayed

### 2. **Authentication** ✓
* Email/password signup and login via Supabase Auth
* Google OAuth support (requires configuration)
* Secure session management
* Protected dashboard routes

### 3. **Form Builder** ✓
* Create unlimited forms
* 5 field types: Text, Email, Phone, Dropdown, File Upload
* Reorder fields with up/down buttons
* Field settings:
  - Custom labels and placeholders
  - Required field toggle
  - Dropdown options (multi-line input)
* Form settings:
  - Title, description
  - Custom thank-you message
  - Active/inactive toggle

### 4. **Form Sharing** ✓
* Each form gets a unique URL (`/f/{form-id}`)
* Copy-to-clipboard functionality
* Embed code (iframe) for websites
* Preview button to test forms before sharing

### 5. **Public Form Submission** ✓
* Clean, responsive submission page
* Field validation (required fields, email format, etc.)
* Success message after submission
* Only active forms accept responses

### 6. **Dashboard** ✓
* View all created forms
* Form cards with:
  - Title, description, creation date
  - Active/inactive status badge
  - Quick actions (Edit, View, Delete)
* Empty state with CTA
* Responsive grid layout

### 7. **Submission Management** ✓
* View all submissions in table format
* Display submission date/time
* See all responses for each submission
* Delete individual submissions
* Export to CSV functionality

### 8. **CSV Export** ✓
* One-click CSV export
* Includes all fields and submission dates
* Handles special characters and commas
* Auto-generated filename

---

## 🛠️ Tech Stack

* **Frontend:** SvelteKit 2 with Svelte 5 (runes mode)
* **Styling:** Tailwind CSS 4 with forms & typography plugins
* **Backend/DB:** Supabase (PostgreSQL, Auth, RLS)
* **Deployment:** Vercel-ready with adapter
* **Language:** TypeScript

---

## 💰 Business Model (Planned)

* **Free plan:** 1 form, 20 submissions/month
* **Pro plan:** $15/month — unlimited forms & 1000 submissions
* **Lifetime deal:** $49 one-time (early traction strategy)

*(Payment integration with Stripe not yet implemented)*

---

## 🖥️ User Journey

1. **Sign up** → Create account with Google/email
2. **Create Form** → Add fields, customize settings
3. **Share Form** → Copy link or embed code
4. **Collect Responses** → Users submit via public link
5. **View Submissions** → See all responses in dashboard
6. **Export Data** → Download CSV for analysis

---

## 🚀 Getting Started

See **[SETUP.md](./SETUP.md)** for detailed setup instructions including:
- Installing dependencies
- Setting up Supabase
- Running the database schema
- Configuring environment variables
- Running the development server
- Deploying to production

**Quick Start:**
```bash
npm install
# Set up .env with Supabase credentials
# Run supabase-schema.sql in Supabase SQL Editor
# IMPORTANT: Disable email confirmation in Supabase Dashboard:
# Authentication → Settings → Uncheck "Enable email confirmations"
npm run dev
```

---

## 📁 Project Structure

```
lidform/
├── src/
│   ├── routes/
│   │   ├── +page.svelte              # Landing page
│   │   ├── +layout.svelte            # Root layout
│   │   ├── +layout.ts                # Client-side layout load
│   │   ├── +layout.server.ts         # Server-side layout load
│   │   ├── auth/
│   │   │   ├── login/                # Login page
│   │   │   ├── signup/               # Signup page
│   │   │   ├── callback/             # OAuth callback
│   │   │   └── logout/               # Logout endpoint
│   │   ├── dashboard/
│   │   │   ├── +page.svelte          # Dashboard (forms list)
│   │   │   └── forms/[id]/
│   │   │       ├── +page.svelte      # View submissions
│   │   │       └── edit/
│   │   │           └── +page.svelte  # Edit form
│   │   └── f/[id]/
│   │       └── +page.svelte          # Public form submission
│   ├── lib/
│   │   └── supabase.ts               # Supabase client
│   └── hooks.server.ts               # Server-side hooks
├── supabase-schema.sql               # Database schema & RLS
├── SETUP.md                          # Detailed setup guide
└── README.md                         # This file
```

---

## 🔐 Security

* Row Level Security (RLS) enabled on all tables
* Users can only access their own forms
* Public can submit to active forms only
* Secure session management with Supabase Auth
* Environment variables for sensitive data

---

## 🎨 UI/UX Highlights

* Modern gradient backgrounds
* Smooth transitions and hover effects
* Responsive design (mobile, tablet, desktop)
* Loading states and skeleton screens
* Accessible forms with proper labels
* Clear error messages
* Empty states with CTAs

---

## 🔮 Future Enhancements

### High Priority
- [ ] Payment integration (Stripe)
- [ ] Usage limits enforcement (free vs pro)
- [ ] Email notifications on new submissions
- [ ] File upload to Supabase Storage

### Medium Priority
- [ ] More field types (textarea, checkbox, radio, date)
- [ ] Drag-and-drop field reordering
- [ ] Form templates
- [ ] Custom form styling/themes
- [ ] Duplicate form functionality

### Nice to Have
- [ ] Analytics dashboard (charts, graphs)
- [ ] Webhooks for integrations
- [ ] Multi-page forms
- [ ] Conditional logic
- [ ] Team collaboration features
- [ ] Custom domains

---

## 📄 License

This project is open for educational and commercial use.

---

## 🤝 Contributing

This is a solo project built as an MVP. Feel free to fork and customize for your needs!

---

**Built with ❤️ using SvelteKit and Supabase**
