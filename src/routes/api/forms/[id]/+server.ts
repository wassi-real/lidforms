import type { RequestHandler } from './$types';
import { createClient } from '@supabase/supabase-js';
import { SUPABASE_URL, SUPABASE_SERVICE_KEY } from '$env/static/private';
import { json } from '@sveltejs/kit';

// Create admin client with service role key for bypassing RLS
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
	auth: {
		autoRefreshToken: false,
		persistSession: false
	}
});

export const GET: RequestHandler = async ({ params }) => {
	try {
		const formId = params.id;

		// Get form data
		const { data: form, error: formError } = await supabaseAdmin
			.from('forms')
			.select('*')
			.eq('id', formId)
			.eq('is_active', true)
			.single();

		if (formError || !form) {
			return json({ error: 'Form not found or is no longer accepting responses' }, { status: 404 });
		}

		// Get form fields
		const { data: fields, error: fieldsError } = await supabaseAdmin
			.from('form_fields')
			.select('*')
			.eq('form_id', formId)
			.order('position', { ascending: true });

		if (fieldsError) {
			return json({ error: 'Failed to load form fields' }, { status: 500 });
		}

		return json({
			form,
			fields: fields || []
		});

	} catch (error) {
		console.error('API error:', error);
		return json({ error: 'Internal server error' }, { status: 500 });
	}
};
