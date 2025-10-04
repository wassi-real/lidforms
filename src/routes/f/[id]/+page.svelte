<script lang="ts">
	import type { PageData, ActionData } from './$types';
	import { onMount } from 'svelte';
	import { enhance } from '$app/forms';

	let { data, form }: { data: PageData; form: ActionData } = $props();

	let formData = $state<any>(null);
	let fields = $state<any[]>([]);
	let loading = $state(true);
	let submitting = $state(false);
	let submitted = $state(false);
	let error = $state('');
	let formFields = $state<Record<string, any>>({});

	onMount(async () => {
		await loadForm();
	});

	async function loadForm() {
		loading = true;
		// Fetch form data from server using service role key
		try {
			const response = await fetch(`/api/forms/${data.formId}`);
			const result = await response.json();
			
			if (!response.ok || result.error) {
				error = 'Form not found or is no longer accepting responses';
				loading = false;
				return;
			}

			formData = result.form;
			fields = result.fields || [];
			loading = false;
		} catch (err) {
			console.error('Load form error:', err);
			error = 'Failed to load form. Please try again.';
			loading = false;
		}
	}

</script>

<svelte:head>
	<title>Form - LidForm</title>
	<meta name="description" content="Fill out this form created with LidForm." />
</svelte:head>

<div class="min-h-screen bg-white flex flex-col">
	<div class="flex-1 py-12 px-4">
		{#if loading}
			<div class="max-w-2xl mx-auto text-center py-20">
				<div class="inline-block animate-spin rounded-full h-16 w-16 border-4 border-gray-200 border-t-black"></div>
				<p class="text-gray-600 mt-6 text-lg">Loading form...</p>
			</div>
		{:else if error && !form}
			<div class="max-w-2xl mx-auto bg-white rounded-3xl border-2 border-red-200 p-12 text-center animate-fade-in">
				<div class="w-20 h-20 bg-red-100 rounded-3xl flex items-center justify-center mx-auto mb-6">
					<svg class="w-10 h-10 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
					</svg>
				</div>
				<h1 class="text-3xl font-bold text-gray-900 mb-3">Form Not Available</h1>
				<p class="text-gray-600">{error}</p>
			</div>
		{:else if submitted}
			<div class="max-w-2xl mx-auto bg-white rounded-3xl border-2 border-green-200 p-16 text-center animate-scale-in">
				<div class="w-24 h-24 bg-green-500 rounded-full flex items-center justify-center mx-auto mb-8">
					<svg class="w-12 h-12 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
					</svg>
				</div>
				<h1 class="text-4xl font-extrabold text-gray-900 mb-4">
					{formData?.thank_you_message || 'Thank you for your submission!'}
				</h1>
				<p class="text-gray-600 text-lg">Your response has been recorded successfully.</p>
			</div>
		{:else if formData}
			<div class="max-w-2xl mx-auto">
				<div class="bg-white rounded-3xl border-2 border-gray-200 p-10 md:p-14 shadow-2xl animate-fade-in">
					<!-- Form Header -->
					<div class="mb-10">
						<h1 class="text-4xl font-extrabold text-gray-900 mb-3">{formData.title}</h1>
						{#if formData.description}
							<p class="text-gray-600 text-lg leading-relaxed">{formData.description}</p>
						{/if}
					</div>

					{#if error}
						<div class="bg-red-50 border-2 border-red-200 text-red-800 rounded-2xl p-4 mb-6 font-semibold">
							{error}
						</div>
					{/if}

					<!-- Form Fields -->
					<form method="POST" action="?/submit" use:enhance={() => {
						submitting = true;
						error = '';
						return async ({ result }) => {
							submitting = false;
							if (result.type === 'success') {
								submitted = true;
							} else if (result.type === 'failure') {
								error = (result.data as any)?.error || 'Failed to submit form. Please try again.';
							} else {
								error = 'Failed to submit form. Please try again.';
							}
						};
					}} class="space-y-6">
						{#each fields as field, index (field.id)}
							<div class="animate-fade-in-up" style="animation-delay: {index * 0.05}s;">
								<label for={field.id} class="block text-sm font-bold text-gray-900 mb-3">
									{field.label}
									{#if field.required}
										<span class="text-red-500">*</span>
									{/if}
								</label>

								{#if field.field_type === 'text'}
									<input
										id={field.id}
										name={field.id}
										type="text"
										bind:value={formFields[field.id]}
										required={field.required}
										placeholder={field.placeholder}
										class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl focus:ring-2 focus:ring-black focus:border-black transition-all text-lg"
									/>
								{:else if field.field_type === 'email'}
									<input
										id={field.id}
										name={field.id}
										type="email"
										bind:value={formFields[field.id]}
										required={field.required}
										placeholder={field.placeholder}
										class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl focus:ring-2 focus:ring-black focus:border-black transition-all text-lg"
									/>
								{:else if field.field_type === 'phone'}
									<input
										id={field.id}
										name={field.id}
										type="tel"
										bind:value={formFields[field.id]}
										required={field.required}
										placeholder={field.placeholder}
										class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl focus:ring-2 focus:ring-black focus:border-black transition-all text-lg"
									/>
								{:else if field.field_type === 'dropdown' && field.options}
									<select
										id={field.id}
										name={field.id}
										bind:value={formFields[field.id]}
										required={field.required}
										class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl focus:ring-2 focus:ring-black focus:border-black transition-all text-lg"
									>
										<option value="">Select an option...</option>
										{#each field.options as option}
											<option value={option}>{option}</option>
										{/each}
									</select>
								{/if}
							</div>
						{/each}

						<button
							type="submit"
							disabled={submitting}
							class="w-full px-8 py-5 bg-black text-white font-bold text-lg rounded-2xl hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-2xl hover:shadow-3xl hover:-translate-y-1"
						>
							{submitting ? 'Submitting...' : 'Submit'}
						</button>
					</form>
				</div>
			</div>
		{/if}
	</div>

	<!-- Footer with Logo -->
	<footer class="border-t-2 border-gray-200 py-8 mt-auto">
		<div class="container mx-auto px-4">
			<div class="flex flex-col items-center gap-4">
				<a href="/" class="flex items-center gap-3 group">
					<img src="/Logo (1).png" alt="LidForm" class="w-10 h-10 transition-transform group-hover:scale-110" />
					<span class="text-xl font-bold text-gray-900">LidForm</span>
				</a>
				<p class="text-sm text-gray-500">
					Powered by <a href="/" class="font-semibold text-gray-900 hover:underline">LidForm</a> • Create your own forms today
				</p>
			</div>
		</div>
	</footer>
</div>

<style>
	@keyframes fade-in {
		from {
			opacity: 0;
		}
		to {
			opacity: 1;
		}
	}

	@keyframes fade-in-up {
		from {
			opacity: 0;
			transform: translateY(20px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	@keyframes scale-in {
		from {
			opacity: 0;
			transform: scale(0.9);
		}
		to {
			opacity: 1;
			transform: scale(1);
		}
	}

	.animate-fade-in {
		animation: fade-in 0.6s ease-out;
	}

	.animate-fade-in-up {
		animation: fade-in-up 0.6s ease-out;
		animation-fill-mode: both;
	}

	.animate-scale-in {
		animation: scale-in 0.5s ease-out;
	}
</style>

