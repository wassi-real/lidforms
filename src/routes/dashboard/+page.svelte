<script lang="ts">
	import { goto, invalidate } from '$app/navigation';
	import type { PageData } from './$types';
	import { onMount } from 'svelte';
	import Toast from '$lib/components/Toast.svelte';

	let { data }: { data: PageData } = $props();

	let forms = $state<any[]>([]);
	let loading = $state(true);
	let toastShow = $state(false);
	let toastMessage = $state('');
	let toastType = $state<'success' | 'error' | 'info'>('info');

	function showToast(message: string, type: 'success' | 'error' | 'info' = 'info') {
		toastMessage = message;
		toastType = type;
		toastShow = true;
	}

	onMount(async () => {
		await loadForms();
	});

	async function loadForms() {
		loading = true;
		const { data: formsData, error } = await data.supabase
			.from('forms')
			.select('*')
			.order('created_at', { ascending: false });

		if (error) {
			console.error('Error loading forms:', error);
			showToast('Failed to load forms', 'error');
		} else {
			forms = formsData || [];
		}
		loading = false;
	}

	async function createNewForm() {
		const { data: newForm, error } = await data.supabase
			.from('forms')
			.insert({
				title: 'Untitled Form',
				description: '',
				user_id: data.user?.id
			})
			.select()
			.single();

		if (error) {
			console.error('Error creating form:', error);
			showToast('Failed to create form', 'error');
		} else {
			showToast('Form created successfully!', 'success');
			goto(`/dashboard/forms/${newForm.id}/edit`);
		}
	}

	async function deleteForm(formId: string, formTitle: string) {
		const { error } = await data.supabase.from('forms').delete().eq('id', formId);

		if (error) {
			console.error('Error deleting form:', error);
			showToast('Failed to delete form', 'error');
		} else {
			showToast(`"${formTitle}" deleted successfully`, 'success');
			await loadForms();
		}
	}
</script>

<svelte:head>
	<title>Dashboard - LidForm</title>
	<meta name="description" content="Manage your forms, view submissions, and export data with LidForm dashboard." />
</svelte:head>

<div class="min-h-screen bg-white">
	<!-- Header -->
	<header class="bg-white border-b-2 border-gray-200 sticky top-0 z-50 backdrop-blur-sm bg-white/95">
		<div class="container mx-auto px-4 py-4">
			<div class="flex items-center justify-between">
				<a href="/dashboard" class="flex items-center gap-3 group">
					<img src="/Logo (1).png" alt="LidForm" class="w-11 h-11 transition-transform group-hover:scale-105" />
					<span class="text-2xl font-bold text-gray-900">LidForm</span>
				</a>
				<div class="flex items-center gap-4">
					<span class="text-gray-600 hidden md:block">{data.user?.email}</span>
					<a
						href="/dashboard/settings"
						class="px-5 py-2.5 border-2 border-gray-900 text-gray-900 font-semibold rounded-xl hover:bg-gray-900 hover:text-white transition-all"
					>
						Settings
					</a>
				</div>
			</div>
		</div>
	</header>

	<!-- Main Content -->
	<main class="container mx-auto px-4 py-12">
		<div class="mb-12 flex items-center justify-between animate-fade-in-up">
			<div>
				<h1 class="text-5xl font-extrabold text-gray-900 mb-3">My Forms</h1>
				<p class="text-gray-600 text-lg">Create and manage your forms</p>
			</div>
			<button
				onclick={createNewForm}
				class="px-8 py-4 bg-black text-white font-bold rounded-2xl hover:bg-gray-800 transition-all shadow-2xl hover:shadow-3xl hover:-translate-y-1 flex items-center gap-2"
			>
				<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
				</svg>
				New Form
			</button>
		</div>

		{#if loading}
			<div class="text-center py-20">
				<div class="inline-block animate-spin rounded-full h-16 w-16 border-4 border-gray-200 border-t-black"></div>
				<p class="text-gray-600 mt-6 text-lg">Loading forms...</p>
			</div>
		{:else if forms.length === 0}
			<div class="bg-white rounded-3xl border-2 border-gray-200 p-16 text-center animate-fade-in">
				<div class="w-24 h-24 bg-gray-100 rounded-3xl flex items-center justify-center mx-auto mb-8">
					<svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
					</svg>
				</div>
				<h2 class="text-3xl font-bold text-gray-900 mb-3">No forms yet</h2>
				<p class="text-gray-600 mb-8 text-lg">Create your first form to start collecting responses</p>
				<button
					onclick={createNewForm}
					class="px-10 py-4 bg-black text-white font-bold rounded-2xl hover:bg-gray-800 transition-all hover:-translate-y-1 shadow-2xl"
				>
					Create Your First Form
				</button>
			</div>
		{:else}
			<div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
				{#each forms as form, index (form.id)}
					<div 
						class="group bg-white rounded-3xl border-2 border-gray-200 hover:border-black transition-all duration-300 p-8 hover:-translate-y-2 hover:shadow-2xl animate-fade-in-up"
						style="animation-delay: {index * 0.1}s;"
					>
						<div class="flex items-start justify-between mb-6">
							<div class="flex-1">
								<h3 class="text-2xl font-bold text-gray-900 mb-2 group-hover:text-black transition-colors">{form.title}</h3>
								<p class="text-sm text-gray-500">
									{new Date(form.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
								</p>
							</div>
							<span class="px-3 py-1.5 text-xs font-bold rounded-full {form.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}">
								{form.is_active ? 'Active' : 'Inactive'}
							</span>
						</div>

						{#if form.description}
							<p class="text-gray-600 mb-6 line-clamp-2 leading-relaxed">{form.description}</p>
						{:else}
							<p class="text-gray-400 mb-6 italic">No description</p>
						{/if}

						<div class="flex gap-3">
							<a
								href="/dashboard/forms/{form.id}/edit"
								class="flex-1 px-4 py-3 bg-black text-white text-center font-semibold rounded-xl hover:bg-gray-800 transition-all"
							>
								Edit
							</a>
							<a
								href="/dashboard/forms/{form.id}"
								class="flex-1 px-4 py-3 border-2 border-gray-900 text-gray-900 text-center font-semibold rounded-xl hover:bg-gray-900 hover:text-white transition-all"
							>
								View
							</a>
							<button
								onclick={() => {
									if (confirm(`Delete "${form.title}"?`)) {
										deleteForm(form.id, form.title);
									}
								}}
								class="px-4 py-3 border-2 border-red-500 text-red-600 font-semibold rounded-xl hover:bg-red-500 hover:text-white transition-all"
								title="Delete form"
							>
								<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
								</svg>
							</button>
						</div>
					</div>
				{/each}
			</div>
		{/if}
	</main>
</div>

<Toast bind:show={toastShow} bind:message={toastMessage} bind:type={toastType} />

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
			transform: translateY(30px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.animate-fade-in {
		animation: fade-in 0.6s ease-out;
	}

	.animate-fade-in-up {
		animation: fade-in-up 0.8s ease-out;
		animation-fill-mode: both;
	}
</style>
