-- LidForm Database Schema
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Forms table
CREATE TABLE IF NOT EXISTS forms (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    thank_you_message TEXT DEFAULT 'Thank you for your submission!',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Form fields table
CREATE TABLE IF NOT EXISTS form_fields (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    form_id UUID NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
    field_type VARCHAR(50) NOT NULL CHECK (field_type IN ('text', 'email', 'phone', 'dropdown')),
    label VARCHAR(255) NOT NULL,
    placeholder VARCHAR(255),
    required BOOLEAN DEFAULT false,
    options JSONB, -- For dropdown options
    position INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Submissions table
CREATE TABLE IF NOT EXISTS submissions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    form_id UUID NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_agent TEXT,
    ip_address INET
);

-- Submission responses table
CREATE TABLE IF NOT EXISTS submission_responses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
    field_id UUID NOT NULL REFERENCES form_fields(id) ON DELETE CASCADE,
    value TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_forms_user_id ON forms(user_id);
CREATE INDEX idx_form_fields_form_id ON form_fields(form_id);
CREATE INDEX idx_submissions_form_id ON submissions(form_id);
CREATE INDEX idx_submission_responses_submission_id ON submission_responses(submission_id);

-- Enable Row Level Security
ALTER TABLE forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE submission_responses ENABLE ROW LEVEL SECURITY;

-- RLS Policies for forms
CREATE POLICY "Users can view their own forms" ON forms
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own forms" ON forms
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own forms" ON forms
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own forms" ON forms
    FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for form_fields
CREATE POLICY "Users can view fields of their forms" ON form_fields
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM forms WHERE forms.id = form_fields.form_id AND forms.user_id = auth.uid()
        )
    );

CREATE POLICY "Anyone can view fields of active forms" ON form_fields
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM forms WHERE forms.id = form_fields.form_id AND forms.is_active = true
        )
    );

CREATE POLICY "Users can insert fields for their forms" ON form_fields
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM forms WHERE forms.id = form_fields.form_id AND forms.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update fields of their forms" ON form_fields
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM forms WHERE forms.id = form_fields.form_id AND forms.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete fields of their forms" ON form_fields
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM forms WHERE forms.id = form_fields.form_id AND forms.user_id = auth.uid()
        )
    );

-- RLS Policies for submissions (anyone can submit to active forms)
CREATE POLICY "Anyone can create submissions for active forms" ON submissions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM forms WHERE forms.id = submissions.form_id AND forms.is_active = true
        )
    );

CREATE POLICY "Form owners can view submissions" ON submissions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM forms WHERE forms.id = submissions.form_id AND forms.user_id = auth.uid()
        )
    );

-- RLS Policies for submission_responses
CREATE POLICY "Anyone can create responses for their submission" ON submission_responses
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE submissions.id = submission_responses.submission_id 
            AND forms.is_active = true
        )
    );

CREATE POLICY "Form owners can view responses" ON submission_responses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM submissions 
            JOIN forms ON forms.id = submissions.form_id 
            WHERE submissions.id = submission_responses.submission_id 
            AND forms.user_id = auth.uid()
        )
    );

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
CREATE TRIGGER update_forms_updated_at BEFORE UPDATE ON forms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

