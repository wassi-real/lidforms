<script lang="ts">
	import { goto } from '$app/navigation';
	import type { PageData } from './$types';
	import { onMount } from 'svelte';
	import Toast from '$lib/components/Toast.svelte';

	let { data }: { data: PageData } = $props();

	let currentPassword = $state('');
	let newPassword = $state('');
	let confirmPassword = $state('');
	let loading = $state(false);
	let toastShow = $state(false);
	let toastMessage = $state('');
	let toastType = $state<'success' | 'error' | 'info'>('info');

	function showToast(message: string, type: 'success' | 'error' | 'info' = 'info') {
		toastMessage = message;
		toastType = type;
		toastShow = true;
	}

	async function changePassword() {
		if (!currentPassword || !newPassword || !confirmPassword) {
			showToast('Please fill in all password fields', 'error');
			return;
		}

		if (newPassword !== confirmPassword) {
			showToast('New passwords do not match', 'error');
			return;
		}

		if (newPassword.length < 6) {
			showToast('New password must be at least 6 characters', 'error');
			return;
		}

		loading = true;

		const { error } = await data.supabase.auth.updateUser({
			password: newPassword
		});

		loading = false;

		if (error) {
			showToast('Failed to update password: ' + error.message, 'error');
		} else {
			showToast('Password updated successfully!', 'success');
			currentPassword = '';
			newPassword = '';
			confirmPassword = '';
		}
	}

	async function handleLogout() {
		const response = await fetch('/auth/logout', {
			method: 'POST'
		});
		if (response.ok) {
			showToast('Logged out successfully', 'success');
			setTimeout(() => goto('/'), 1000);
		}
	}

	async function deleteAccount() {
		if (!confirm('Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your forms and data.')) {
			return;
		}

		if (!confirm('This is your final warning. Type "DELETE" to confirm account deletion.')) {
			return;
		}

		const confirmation = prompt('Type "DELETE" to confirm account deletion:');
		if (confirmation !== 'DELETE') {
			showToast('Account deletion cancelled', 'info');
			return;
		}

		loading = true;

		try {
			// Delete all user's forms and related data first
			const { error: formsError } = await data.supabase
				.from('forms')
				.delete()
				.eq('user_id', data.user?.id);

			if (formsError) {
				console.error('Error deleting forms:', formsError);
				showToast('Failed to delete account data', 'error');
				loading = false;
				return;
			}

			// Delete the user account
			const { error: deleteError } = await data.supabase.auth.admin.deleteUser(data.user?.id);

			if (deleteError) {
				console.error('Error deleting user:', deleteError);
				showToast('Failed to delete account', 'error');
			} else {
				showToast('Account deleted successfully', 'success');
				setTimeout(() => goto('/'), 1000);
			}
		} catch (error) {
			console.error('Unexpected error:', error);
			showToast('An unexpected error occurred', 'error');
		}

		loading = false;
	}
</script>

<svelte:head>
	<title>Settings - LidForm</title>
	<meta name="description" content="Manage your LidForm account settings, change password, and account preferences." />
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
						Back to Dashboard
					</a>
				</div>
			</div>
		</div>
	</header>

	<!-- Main Content -->
	<main class="container mx-auto px-4 py-12 max-w-4xl">
		<div class="mb-12 animate-fade-in-up">
			<h1 class="text-5xl font-extrabold text-gray-900 mb-3">Settings</h1>
			<p class="text-gray-600 text-lg">Manage your account preferences and security</p>
		</div>

		<!-- Account Info -->
		<div class="bg-white rounded-3xl border-2 border-gray-200 p-10 mb-6 animate-fade-in-up" style="animation-delay: 0.1s;">
			<h2 class="text-2xl font-bold text-gray-900 mb-6">Account Information</h2>
			<div class="space-y-4">
				<div>
					<label for="email-address" class="block text-sm font-semibold text-gray-900 mb-2">Email Address</label>
					<input
						id="email-address"
						type="email"
						value={data.user?.email || ''}
						readonly
						class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl bg-gray-50 text-gray-700"
					/>
					<p class="text-sm text-gray-500 mt-2">Email address cannot be changed</p>
				</div>
				<div>
					<label for="account-created" class="block text-sm font-semibold text-gray-900 mb-2">Account Created</label>
					<input
						id="account-created"
						type="text"
						value={data.user?.created_at ? new Date(data.user.created_at).toLocaleDateString() : ''}
						readonly
						class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl bg-gray-50 text-gray-700"
					/>
				</div>
			</div>
		</div>

		<!-- Change Password -->
		<div class="bg-white rounded-3xl border-2 border-gray-200 p-10 mb-6 animate-fade-in-up" style="animation-delay: 0.2s;">
			<h2 class="text-2xl font-bold text-gray-900 mb-6">Change Password</h2>
			<form onsubmit={(e) => { e.preventDefault(); changePassword(); }} class="space-y-6">
				<div>
					<label for="current-password" class="block text-sm font-semibold text-gray-900 mb-2">
						Current Password
					</label>
					<input
						id="current-password"
						type="password"
						bind:value={currentPassword}
						class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl focus:ring-2 focus:ring-black focus:border-black transition-all"
						placeholder="Enter your current password"
					/>
				</div>
				<div>
					<label for="new-password" class="block text-sm font-semibold text-gray-900 mb-2">
						New Password
					</label>
					<input
						id="new-password"
						type="password"
						bind:value={newPassword}
						class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl focus:ring-2 focus:ring-black focus:border-black transition-all"
						placeholder="Enter your new password"
					/>
				</div>
				<div>
					<label for="confirm-password" class="block text-sm font-semibold text-gray-900 mb-2">
						Confirm New Password
					</label>
					<input
						id="confirm-password"
						type="password"
						bind:value={confirmPassword}
						class="w-full px-5 py-4 border-2 border-gray-200 rounded-2xl focus:ring-2 focus:ring-black focus:border-black transition-all"
						placeholder="Confirm your new password"
					/>
				</div>
				<button
					type="submit"
					disabled={loading}
					class="px-8 py-4 bg-black text-white font-bold rounded-2xl hover:bg-gray-800 disabled:opacity-50 transition-all hover:-translate-y-0.5 shadow-lg"
				>
					{loading ? 'Updating...' : 'Update Password'}
				</button>
			</form>
		</div>

		<!-- Account Actions -->
		<div class="bg-white rounded-3xl border-2 border-gray-200 p-10 animate-fade-in-up" style="animation-delay: 0.3s;">
			<h2 class="text-2xl font-bold text-gray-900 mb-6">Account Actions</h2>
			<div class="space-y-4">
				<div class="p-6 bg-gray-50 rounded-2xl">
					<h3 class="text-lg font-semibold text-gray-900 mb-2">Sign Out</h3>
					<p class="text-gray-600 mb-4">Sign out of your account on this device</p>
					<button
						onclick={handleLogout}
						class="px-6 py-3 border-2 border-gray-900 text-gray-900 font-semibold rounded-xl hover:bg-gray-900 hover:text-white transition-all"
					>
						Sign Out
					</button>
				</div>

				<div class="p-6 bg-red-50 border-2 border-red-200 rounded-2xl">
					<h3 class="text-lg font-semibold text-red-900 mb-2">Delete Account</h3>
					<p class="text-red-700 mb-4">
						<strong>Warning:</strong> This action cannot be undone. This will permanently delete your account, 
						all your forms, and all associated data.
					</p>
					<button
						onclick={deleteAccount}
						disabled={loading}
						class="px-6 py-3 border-2 border-red-500 text-red-600 font-semibold rounded-xl hover:bg-red-500 hover:text-white transition-all disabled:opacity-50"
					>
						{loading ? 'Deleting...' : 'Delete Account'}
					</button>
				</div>
			</div>
		</div>
	</main>
</div>

<Toast bind:show={toastShow} bind:message={toastMessage} bind:type={toastType} />

<style>
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

	.animate-fade-in-up {
		animation: fade-in-up 0.6s ease-out;
		animation-fill-mode: both;
	}
</style>
