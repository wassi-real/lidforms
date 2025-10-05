import { PUBLIC_SUPABASE_ANON_KEY, PUBLIC_SUPABASE_URL } from '$env/static/public';
import { createBrowserClient, createServerClient, isBrowser } from '@supabase/ssr';
import type { LayoutLoad } from './$types';

export const load: LayoutLoad = async ({ data, depends, fetch }) => {
	depends('supabase:auth');

	// Only create supabase client on browser side
	if (isBrowser()) {
		const supabase = createBrowserClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, {
			global: {
				fetch
			}
		});

		const {
			data: { session }
		} = await supabase.auth.getSession();

		const {
			data: { user }
		} = await supabase.auth.getUser();

		return { supabase, session, user };
	}

	// On server side, don't return supabase client to avoid serialization
	return { session: null, user: null };
};

