import type { PageLoad } from './$types';

export const load: PageLoad = async ({ params }) => {
	return {
		formId: params.id
	};
};

