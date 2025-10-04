<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import type { PageData } from './$types';
	import { onMount } from 'svelte';
	import Toast from '$lib/components/Toast.svelte';

	let { data }: { data: PageData } = $props();

	let form = $state<any>(null);
	let fields = $state<any[]>([]);
	let loading = $state(true);
	let saving = $state(false);
	let toastShow = $state(false);
	let toastMessage = $state('');
	let toastType = $state<'success' | 'error' | 'info'>('info');
	let activeTab = $state<'settings' | 'fields' | 'share'>('settings');

	function showToast(message: string, type: 'success' | 'error' | 'info' = 'info') {
		toastMessage = message;
		toastType = type;
		toastShow = true;
	}

	const fieldTypes = [
		{ value: 'text', label: 'Text' },
		{ value: 'email', label: 'Email' },
		{ value: 'phone', label: 'Phone' },
		{ value: 'dropdown', label: 'Dropdown' }
	];

	onMount(async () => {
		await loadForm();
	});

	async function loadForm() {
		loading = true;
		const formId = $page.params.id;

		// Load form - ONLY if user owns it
		const { data: formData, error: formError } = await data.supabase
			.from('forms')
			.select('*')
			.eq('id', formId)
			.eq('user_id', data.user?.id)
			.single();

		if (formError) {
			console.error('Error loading form:', formError);
			showToast('Failed to load form - Access denied', 'error');
			goto('/dashboard');
			return;
		}

		form = formData;

		// Load fields
		const { data: fieldsData, error: fieldsError } = await data.supabase
			.from('form_fields')
			.select('*')
			.eq('form_id', formId)
			.order('position', { ascending: true });

		if (fieldsError) {
			console.error('Error loading fields:', fieldsError);
		} else {
			fields = fieldsData || [];
		}

		loading = false;
	}

	async function saveForm() {
		if (!form) {
			showToast('Form data not loaded', 'error');
			return;
		}
		
		saving = true;

		try {
			// Update form
			const { error: formError } = await data.supabase
				.from('forms')
				.update({
					title: form.title,
					description: form.description,
					thank_you_message: form.thank_you_message,
					is_active: form.is_active
				})
				.eq('id', form.id);

			if (formError) {
				console.error('Error updating form:', formError);
				showToast('Failed to save form: ' + formError.message, 'error');
				saving = false;
				return;
			}

			// Delete all existing fields
			const { error: deleteError } = await data.supabase
				.from('form_fields')
				.delete()
				.eq('form_id', form.id);

			if (deleteError) {
				console.error('Error deleting old fields:', deleteError);
			}

			// Insert all fields with updated positions
			if (fields.length > 0) {
				const fieldsToInsert = fields.map((field, index) => ({
					form_id: form.id,
					field_type: field.field_type,
					label: field.label,
					placeholder: field.placeholder || '',
					required: field.required || false,
					options: field.options || null,
					position: index
				}));

				const { error: fieldsError } = await data.supabase
					.from('form_fields')
					.insert(fieldsToInsert);

				if (fieldsError) {
					console.error('Error saving fields:', fieldsError);
					showToast('Failed to save fields: ' + fieldsError.message, 'error');
					saving = false;
					return;
				}
			}

			saving = false;
			showToast('Form saved successfully!', 'success');
			
			// Reload the form to show saved data
			await loadForm();
		} catch (error) {
			console.error('Unexpected error:', error);
			showToast('An unexpected error occurred', 'error');
			saving = false;
		}
	}

	function addField() {
		fields = [
			...fields,
			{
				field_type: 'text',
				label: 'New Field',
				placeholder: '',
				required: false,
				options: null,
				position: fields.length
			}
		];
	}

	function removeField(index: number) {
		fields = fields.filter((_, i) => i !== index);
	}

	function moveFieldUp(index: number) {
		if (index === 0) return;
		const newFields = [...fields];
		[newFields[index - 1], newFields[index]] = [newFields[index], newFields[index - 1]];
		fields = newFields;
	}

	function moveFieldDown(index: number) {
		if (index === fields.length - 1) return;
		const newFields = [...fields];
		[newFields[index], newFields[index + 1]] = [newFields[index + 1], newFields[index]];
		fields = newFields;
	}

	function updateFieldType(index: number, type: string) {
		fields[index].field_type = type;
		if (type === 'dropdown' && !fields[index].options) {
			fields[index].options = ['Option 1', 'Option 2', 'Option 3'];
		}
	}

	function copyLink() {
		navigator.clipboard.writeText(`${window.location.origin}/f/${form.id}`);
		showToast('Link copied to clipboard!', 'success');
	}
</script>

<svelte:head>
	<title>Edit Form - LidForm</title>
	<meta name="description" content="Build and customize your form with LidForm's intuitive form builder." />
</svelte:head>

<div class="min-h-screen bg-white">
	<!-- Header -->
	<header class="bg-white border-b-2 border-gray-200 sticky top-0 z-50 backdrop-blur-sm bg-white/95">
		<div class="container mx-auto px-4 py-3 md:py-4">
			<div class="flex items-center justify-between flex-wrap gap-3">
				<div class="flex items-center gap-2 md:gap-4">
					<a href="/dashboard" class="flex items-center gap-2 group">
						<img src="/Logo (1).png" alt="LidForm" class="w-7 h-7 md:w-8 md:h-8 transition-transform group-hover:scale-105" />
						<span class="text-lg md:text-xl font-bold text-gray-900">LidForm</span>
					</a>
					<a href="/dashboard" class="text-gray-600 hover:text-black text-sm md:text-base font-semibold transition-colors flex items-center gap-1">
						<svg class="w-4 h-4 md:w-5 md:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
						</svg>
						<span class="hidden sm:inline">Back</span>
					</a>
				</div>
				<div class="flex items-center gap-2">
					<a
						href="/f/{$page.params.id}"
						target="_blank"
						class="px-3 py-2 md:px-5 md:py-2.5 border-2 border-gray-900 text-gray-900 text-sm md:text-base font-semibold rounded-xl hover:bg-gray-900 hover:text-white transition-all"
					>
						Preview
					</a>
					<button
						onclick={saveForm}
						disabled={saving}
						class="px-4 md:px-8 py-2 md:py-2.5 bg-black text-white text-sm md:text-base font-bold rounded-xl hover:bg-gray-800 disabled:opacity-50 transition-all hover:-translate-y-0.5 shadow-lg"
					>
						{saving ? 'Saving...' : 'Save'}
					</button>
				</div>
			</div>
		</div>
	</header>

	{#if loading}
		<div class="container mx-auto px-4 py-20 text-center">
			<div class="inline-block animate-spin rounded-full h-16 w-16 border-4 border-gray-200 border-t-black"></div>
			<p class="text-gray-600 mt-6 text-lg">Loading form...</p>
		</div>
	{:else if form}
		<main class="container mx-auto px-4 py-6 md:py-12 max-w-5xl">
			<!-- Tabs Navigation -->
			<div class="bg-white rounded-2xl md:rounded-3xl border-2 border-gray-200 p-1.5 md:p-2 mb-4 md:mb-6 flex gap-1 md:gap-2 animate-fade-in overflow-x-auto">
				<button
					onclick={() => activeTab = 'settings'}
					class="flex-1 min-w-[100px] px-3 md:px-6 py-3 md:py-4 rounded-xl md:rounded-2xl font-bold text-sm md:text-lg transition-all {activeTab === 'settings' ? 'bg-black text-white shadow-lg' : 'bg-transparent text-gray-600 hover:bg-gray-100'}"
				>
					<div class="flex items-center justify-center gap-1.5 md:gap-2">
						<svg class="w-4 h-4 md:w-5 md:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
						</svg>
						<span class="whitespace-nowrap">Settings</span>
					</div>
				</button>
				<button
					onclick={() => activeTab = 'fields'}
					class="flex-1 min-w-[100px] px-3 md:px-6 py-3 md:py-4 rounded-xl md:rounded-2xl font-bold text-sm md:text-lg transition-all {activeTab === 'fields' ? 'bg-black text-white shadow-lg' : 'bg-transparent text-gray-600 hover:bg-gray-100'}"
				>
					<div class="flex items-center justify-center gap-1.5 md:gap-2">
						<svg class="w-4 h-4 md:w-5 md:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
						</svg>
						<span class="whitespace-nowrap">Fields</span>
					</div>
				</button>
				<button
					onclick={() => activeTab = 'share'}
					class="flex-1 min-w-[100px] px-3 md:px-6 py-3 md:py-4 rounded-xl md:rounded-2xl font-bold text-sm md:text-lg transition-all {activeTab === 'share' ? 'bg-black text-white shadow-lg' : 'bg-transparent text-gray-600 hover:bg-gray-100'}"
				>
					<div class="flex items-center justify-center gap-1.5 md:gap-2">
						<svg class="w-4 h-4 md:w-5 md:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
						</svg>
						<span class="whitespace-nowrap">Share</span>
					</div>
				</button>
			</div>

			<!-- Tab Content -->
			{#if activeTab === 'settings'}
			<!-- Form Settings -->
			<div class="bg-white rounded-2xl md:rounded-3xl border-2 border-gray-200 p-6 md:p-10 animate-fade-in">
				<h2 class="text-2xl md:text-3xl font-bold text-gray-900 mb-6 md:mb-8">Form Settings</h2>

				<div class="space-y-6">
					<div>
						<label for="form-title" class="block text-sm font-semibold text-gray-900 mb-3">
							Form Title
						</label>
						<input
							id="form-title"
							type="text"
							bind:value={form.title}
							class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl focus:ring-2 focus:ring-black focus:border-black transition-all text-lg"
							placeholder="My Awesome Form"
						/>
					</div>

					<div>
						<label for="form-description" class="block text-sm font-semibold text-gray-900 mb-3">
							Description
						</label>
						<textarea
							id="form-description"
							bind:value={form.description}
							rows="3"
							class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl focus:ring-2 focus:ring-black focus:border-black transition-all"
							placeholder="Tell users what this form is for..."
						></textarea>
					</div>

					<div>
						<label for="thank-you-message" class="block text-sm font-semibold text-gray-900 mb-3">
							Thank You Message
						</label>
						<input
							id="thank-you-message"
							type="text"
							bind:value={form.thank_you_message}
							class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl focus:ring-2 focus:ring-black focus:border-black transition-all"
							placeholder="Thank you for your submission!"
						/>
					</div>

					<div class="flex items-center gap-3 p-4 bg-gray-50 rounded-2xl">
						<input
							id="is_active"
							type="checkbox"
							bind:checked={form.is_active}
							class="w-6 h-6 text-black border-gray-300 rounded focus:ring-2 focus:ring-black"
						/>
						<label for="is_active" class="text-sm font-semibold text-gray-900">
							Form is active (accepting responses)
						</label>
					</div>
				</div>
			</div>
			{/if}

			{#if activeTab === 'fields'}
			<!-- Form Fields -->
			<div class="bg-white rounded-2xl md:rounded-3xl border-2 border-gray-200 p-6 md:p-10 animate-fade-in">
				<div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6 md:mb-8">
					<h2 class="text-2xl md:text-3xl font-bold text-gray-900">Form Fields</h2>
					<button
						onclick={addField}
						class="w-full sm:w-auto px-4 md:px-6 py-2.5 md:py-3 bg-black text-white text-sm md:text-base font-semibold rounded-xl hover:bg-gray-800 transition-all hover:-translate-y-0.5 shadow-lg flex items-center justify-center gap-2"
					>
						<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
						</svg>
						Add Field
					</button>
				</div>

				{#if fields.length === 0}
					<div class="text-center py-16 border-2 border-dashed border-gray-300 rounded-2xl">
						<div class="w-16 h-16 bg-gray-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
							<svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
							</svg>
						</div>
						<p class="text-gray-600 mb-4">No fields yet. Add your first field to get started.</p>
						<button
							onclick={addField}
							class="px-8 py-3 bg-black text-white font-semibold rounded-xl hover:bg-gray-800 transition-all"
						>
							Add Field
						</button>
					</div>
				{:else}
					<div class="space-y-4">
						{#each fields as field, index (index)}
							<div class="border-2 border-gray-200 rounded-2xl p-6 bg-gray-50 hover:border-gray-400 transition-all">
								<div class="flex items-start gap-4">
									<!-- Move buttons -->
									<div class="flex flex-col gap-1">
										<button
											onclick={() => moveFieldUp(index)}
											disabled={index === 0}
											class="px-2 py-1 text-gray-600 hover:text-black disabled:opacity-30 transition-colors"
											title="Move up"
										>
											<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7" />
											</svg>
										</button>
										<button
											onclick={() => moveFieldDown(index)}
											disabled={index === fields.length - 1}
											class="px-2 py-1 text-gray-600 hover:text-black disabled:opacity-30 transition-colors"
											title="Move down"
										>
											<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
											</svg>
										</button>
									</div>

									<!-- Field config -->
									<div class="flex-1 space-y-4">
										<div class="grid md:grid-cols-2 gap-4">
											<div>
												<label for="field-type-{index}" class="block text-sm font-semibold text-gray-900 mb-2">
													Field Type
												</label>
												<select
													id="field-type-{index}"
													value={field.field_type}
													onchange={(e) => updateFieldType(index, e.currentTarget.value)}
													class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-black focus:border-black transition-all"
												>
													{#each fieldTypes as type}
														<option value={type.value}>{type.label}</option>
													{/each}
												</select>
											</div>

											<div>
												<label for="field-label-{index}" class="block text-sm font-semibold text-gray-900 mb-2">
													Label
												</label>
												<input
													id="field-label-{index}"
													type="text"
													bind:value={field.label}
													class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-black focus:border-black transition-all"
													placeholder="Field label"
												/>
											</div>
										</div>

										<div>
											<label for="field-placeholder-{index}" class="block text-sm font-semibold text-gray-900 mb-2">
												Placeholder
											</label>
											<input
												id="field-placeholder-{index}"
												type="text"
												bind:value={field.placeholder}
												class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-black focus:border-black transition-all"
												placeholder="Placeholder text"
											/>
										</div>

										{#if field.field_type === 'dropdown'}
											<div>
												<label for="field-options-{index}" class="block text-sm font-semibold text-gray-900 mb-2">
													Options (one per line)
												</label>
												<textarea
													id="field-options-{index}"
													value={Array.isArray(field.options) ? field.options.join('\n') : ''}
													oninput={(e) => {
														field.options = e.currentTarget.value.split('\n').filter(o => o.trim());
													}}
													rows="4"
													class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-black focus:border-black transition-all"
													placeholder="Option 1&#10;Option 2&#10;Option 3"
												></textarea>
											</div>
										{/if}

										<div class="flex items-center gap-3 p-3 bg-white rounded-xl">
											<input
												id="required_{index}"
												type="checkbox"
												bind:checked={field.required}
												class="w-5 h-5 text-black border-gray-300 rounded focus:ring-2 focus:ring-black"
											/>
											<label for="required_{index}" class="text-sm font-semibold text-gray-900">
												Required field
											</label>
										</div>
									</div>

									<!-- Delete button -->
									<button
										onclick={() => removeField(index)}
										class="px-3 py-3 text-red-600 hover:text-red-700 font-semibold transition-colors"
										title="Delete field"
									>
										<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
										</svg>
									</button>
								</div>
							</div>
						{/each}
					</div>
				{/if}
			</div>
			{/if}

			{#if activeTab === 'share'}
			<!-- Share Section -->
			<div class="bg-white rounded-2xl md:rounded-3xl border-2 border-gray-200 p-6 md:p-10 animate-fade-in">
				<h2 class="text-2xl md:text-3xl font-bold text-gray-900 mb-6 md:mb-8">Share Your Form</h2>
				
				<div class="space-y-6">
					<div>
						<label for="form-url" class="block text-sm font-semibold text-gray-900 mb-3">
							Form URL
						</label>
						<div class="flex gap-3">
							<input
								id="form-url"
								type="text"
								readonly
								value="{window.location.origin}/f/{form.id}"
								class="flex-1 px-5 py-4 border-2 border-gray-200 rounded-2xl bg-gray-50 text-gray-700"
							/>
							<button
								onclick={copyLink}
								class="px-8 py-4 bg-black text-white font-semibold rounded-2xl hover:bg-gray-800 transition-all hover:-translate-y-0.5 shadow-lg"
							>
								Copy
							</button>
						</div>
					</div>

					<div>
						<label for="embed-code" class="block text-sm font-semibold text-gray-900 mb-3">
							Embed Code (iframe)
						</label>
						<textarea
							id="embed-code"
							readonly
							value={`<iframe src="${window.location.origin}/f/${form.id}" width="100%" height="600" frameborder="0"></iframe>`}
							rows="3"
							class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl bg-gray-50 font-mono text-sm text-gray-700"
						></textarea>
					</div>
				</div>
			</div>
			{/if}
		</main>
	{/if}
</div>

<Toast bind:show={toastShow} bind:message={toastMessage} bind:type={toastType} />

<style>
	@keyframes fade-in {
		from {
			opacity: 0;
			transform: translateY(20px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.animate-fade-in {
		animation: fade-in 0.6s ease-out;
		animation-fill-mode: both;
	}
</style>
