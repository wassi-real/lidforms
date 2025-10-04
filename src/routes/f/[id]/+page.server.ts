import type { PageServerLoad, Actions } from './$types';
import { createClient } from '@supabase/supabase-js';
import { SUPABASE_URL, SUPABASE_SERVICE_KEY } from '$env/static/private';

// Create admin client with service role key for bypassing RLS
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
	auth: {
		autoRefreshToken: false,
		persistSession: false
	}
});

export const load: PageServerLoad = async ({ params }) => {
	return {
		formId: params.id
	};
};

export const actions: Actions = {
	submit: async ({ request, params }) => {
		try {
			const formData = await request.formData();
			const formId = params.id;

			// First, verify the form exists and is active
			const { data: form, error: formError } = await supabaseAdmin
				.from('forms')
				.select('id, is_active, title')
				.eq('id', formId)
				.eq('is_active', true)
				.single();

			if (formError || !form) {
			return {
				type: 'failure',
				status: 404,
				data: {
					error: 'Form not found or is no longer accepting responses'
				}
			};
			}

			// Get form fields
			const { data: fields, error: fieldsError } = await supabaseAdmin
				.from('form_fields')
				.select('*')
				.eq('form_id', formId)
				.order('position', { ascending: true });

			if (fieldsError) {
			return {
				type: 'failure',
				status: 500,
				data: {
					error: 'Failed to load form fields'
				}
			};
			}

			// Validate required fields
			for (const field of fields || []) {
				if (field.required && !formData.get(field.id)) {
				return {
					type: 'failure',
					status: 400,
					data: {
						error: `Please fill in the required field: ${field.label}`
					}
				};
				}
			}

			// Create submission
			const { data: submission, error: submissionError } = await supabaseAdmin
				.from('submissions')
				.insert({
					form_id: formId
				})
				.select()
				.single();

		if (submissionError) {
			console.error('Submission error:', submissionError);
			return {
				type: 'failure',
				status: 500,
				data: {
					error: 'Failed to submit form. Please try again.'
				}
			};
		}

			// Create responses
			const responses = (fields || [])
				.filter(field => formData.get(field.id))
				.map(field => ({
					submission_id: submission.id,
					field_id: field.id,
					value: String(formData.get(field.id))
				}));

			if (responses.length > 0) {
				const { error: responsesError } = await supabaseAdmin
					.from('submission_responses')
					.insert(responses);

			if (responsesError) {
				console.error('Responses error:', responsesError);
				return {
					type: 'failure',
					status: 500,
					data: {
						error: 'Failed to submit form. Please try again.'
					}
				};
			}
			}

			return {
				type: 'success',
				message: 'Form submitted successfully!'
			};

		} catch (error) {
			console.error('Form submission error:', error);
			return {
				type: 'failure',
				status: 500,
				data: {
					error: 'An unexpected error occurred. Please try again.'
				}
			};
		}
	}
};
