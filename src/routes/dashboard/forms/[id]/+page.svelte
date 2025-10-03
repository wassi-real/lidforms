<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import type { PageData } from './$types';
	import { onMount } from 'svelte';
	import Toast from '$lib/components/Toast.svelte';

	let { data }: { data: PageData } = $props();

	let form = $state<any>(null);
	let fields = $state<any[]>([]);
	let submissions = $state<any[]>([]);
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
		await loadData();
	});

	async function loadData() {
		loading = true;
		const formId = $page.params.id;

		// Load form
		const { data: formData, error: formError } = await data.supabase
			.from('forms')
			.select('*')
			.eq('id', formId)
			.single();

		if (formError) {
			console.error('Error loading form:', formError);
			showToast('Failed to load form', 'error');
			goto('/dashboard');
			return;
		}

		form = formData;

		// Load fields
		const { data: fieldsData } = await data.supabase
			.from('form_fields')
			.select('*')
			.eq('form_id', formId)
			.order('position', { ascending: true });

		fields = fieldsData || [];

		// Load submissions with responses
		const { data: submissionsData } = await data.supabase
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

		submissions = submissionsData || [];
		loading = false;
	}

	function getResponseValue(submission: any, fieldId: string) {
		const response = submission.submission_responses?.find((r: any) => r.field_id === fieldId);
		return response?.value || '-';
	}

	async function exportToCSV() {
		if (submissions.length === 0) {
			showToast('No submissions to export', 'info');
			return;
		}

		// Create CSV header
		const headers = ['Submission Date', ...fields.map(f => f.label)];
		const csvRows = [headers.join(',')];

		// Add data rows
		for (const submission of submissions) {
			const row = [
				new Date(submission.submitted_at).toLocaleString(),
				...fields.map(field => {
					const value = getResponseValue(submission, field.id);
					// Escape quotes and wrap in quotes if contains comma
					return value.includes(',') || value.includes('"') 
						? `"${value.replace(/"/g, '""')}"` 
						: value;
				})
			];
			csvRows.push(row.join(','));
		}

		// Download CSV
		const csvContent = csvRows.join('\n');
		const blob = new Blob([csvContent], { type: 'text/csv' });
		const url = window.URL.createObjectURL(blob);
		const a = document.createElement('a');
		a.href = url;
		a.download = `${form.title.replace(/[^a-z0-9]/gi, '_').toLowerCase()}_submissions.csv`;
		a.click();
		window.URL.revokeObjectURL(url);
		showToast('CSV exported successfully!', 'success');
	}

	async function deleteSubmission(submissionId: string) {
		const { error } = await data.supabase
			.from('submissions')
			.delete()
			.eq('id', submissionId);

		if (error) {
			console.error('Error deleting submission:', error);
			showToast('Failed to delete submission', 'error');
		} else {
			showToast('Submission deleted', 'success');
			await loadData();
		}
	}
</script>

<svelte:head>
	<title>Form Submissions - LidForm</title>
	<meta name="description" content="View and export form submissions with LidForm dashboard." />
</svelte:head>

<div class="min-h-screen bg-white">
	<!-- Header -->
	<header class="bg-white border-b-2 border-gray-200 sticky top-0 z-50 backdrop-blur-sm bg-white/95">
		<div class="container mx-auto px-4 py-4">
			<div class="flex items-center justify-between">
				<div class="flex items-center gap-4">
					<a href="/dashboard" class="flex items-center gap-3 group">
						<img src="/Logo (1).png" alt="LidForm" class="w-8 h-8 transition-transform group-hover:scale-105" />
						<span class="text-xl font-bold text-gray-900">LidForm</span>
					</a>
					<a href="/dashboard" class="text-gray-600 hover:text-black font-semibold transition-colors flex items-center gap-2">
						<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
						</svg>
						Dashboard
					</a>
				</div>
				<div class="flex items-center gap-3">
					<a
						href="/dashboard/forms/{$page.params.id}/edit"
						class="px-5 py-2.5 border-2 border-gray-900 text-gray-900 font-semibold rounded-xl hover:bg-gray-900 hover:text-white transition-all"
					>
						Edit Form
					</a>
					<button
						onclick={exportToCSV}
						class="px-6 py-2.5 bg-green-600 text-white font-semibold rounded-xl hover:bg-green-700 transition-all hover:-translate-y-0.5 shadow-lg flex items-center gap-2"
					>
						<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
						</svg>
						Export CSV
					</button>
				</div>
			</div>
		</div>
	</header>

	{#if loading}
		<div class="container mx-auto px-4 py-20 text-center">
			<div class="inline-block animate-spin rounded-full h-16 w-16 border-4 border-gray-200 border-t-black"></div>
			<p class="text-gray-600 mt-6 text-lg">Loading submissions...</p>
		</div>
	{:else if form}
		<main class="container mx-auto px-4 py-12">
			<!-- Form Info -->
			<div class="bg-white rounded-3xl border-2 border-gray-200 p-10 mb-6 animate-fade-in">
				<div class="flex items-start justify-between">
					<div>
						<h1 class="text-4xl font-extrabold text-gray-900 mb-3">{form.title}</h1>
						{#if form.description}
							<p class="text-gray-600 mb-4 text-lg">{form.description}</p>
						{/if}
						<div class="flex items-center gap-4">
							<span class="px-4 py-2 text-sm font-bold rounded-full {form.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}">
								{form.is_active ? 'Active' : 'Inactive'}
							</span>
							<span class="text-gray-900 font-semibold">
								{submissions.length} submission{submissions.length !== 1 ? 's' : ''}
							</span>
						</div>
					</div>
				</div>
			</div>

			<!-- Submissions -->
			<div class="bg-white rounded-3xl border-2 border-gray-200 p-10 animate-fade-in" style="animation-delay: 0.1s;">
				<h2 class="text-3xl font-bold text-gray-900 mb-8">Submissions</h2>

				{#if submissions.length === 0}
					<div class="text-center py-16 border-2 border-dashed border-gray-300 rounded-2xl">
						<div class="w-20 h-20 bg-gray-100 rounded-3xl flex items-center justify-center mx-auto mb-6">
							<svg class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
							</svg>
						</div>
						<p class="text-gray-600 mb-2 text-lg">No submissions yet</p>
						<p class="text-sm text-gray-500">Share your form to start collecting responses</p>
					</div>
				{:else}
					<div class="overflow-x-auto rounded-2xl border-2 border-gray-200">
						<table class="w-full">
							<thead class="bg-gray-50">
								<tr>
									<th class="text-left py-4 px-6 text-sm font-bold text-gray-900 border-b-2 border-gray-200">Date</th>
									{#each fields as field}
										<th class="text-left py-4 px-6 text-sm font-bold text-gray-900 border-b-2 border-gray-200">{field.label}</th>
									{/each}
									<th class="text-left py-4 px-6 text-sm font-bold text-gray-900 border-b-2 border-gray-200">Actions</th>
								</tr>
							</thead>
							<tbody>
								{#each submissions as submission (submission.id)}
									<tr class="border-b border-gray-100 hover:bg-gray-50 transition-colors">
										<td class="py-4 px-6 text-sm text-gray-700">
											<div class="font-semibold">{new Date(submission.submitted_at).toLocaleDateString()}</div>
											<div class="text-xs text-gray-500">
												{new Date(submission.submitted_at).toLocaleTimeString()}
											</div>
										</td>
										{#each fields as field}
											<td class="py-4 px-6 text-sm text-gray-900 max-w-xs">
												<div class="truncate">{getResponseValue(submission, field.id)}</div>
											</td>
										{/each}
										<td class="py-4 px-6">
											<button
												onclick={() => {
													if (confirm('Delete this submission?')) {
														deleteSubmission(submission.id);
													}
												}}
												class="text-red-600 hover:text-red-700 text-sm font-semibold transition-colors"
											>
												Delete
											</button>
										</td>
									</tr>
								{/each}
							</tbody>
						</table>
					</div>
				{/if}
			</div>
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
