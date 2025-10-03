<script lang="ts">
	import { onMount } from 'svelte';
	
	let { 
		message = $bindable(''),
		type = $bindable<'success' | 'error' | 'info'>('info'),
		show = $bindable(false)
	} = $props();

	let timeoutId: ReturnType<typeof setTimeout>;

	$effect(() => {
		if (show) {
			clearTimeout(timeoutId);
			timeoutId = setTimeout(() => {
				show = false;
			}, 4000);
		}
	});

	function close() {
		show = false;
	}
</script>

{#if show}
	<div 
		class="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 animate-slide-up"
		role="alert"
	>
		<div class="bg-white border-2 {type === 'success' ? 'border-green-500' : type === 'error' ? 'border-red-500' : 'border-gray-900'} rounded-2xl shadow-2xl px-6 py-4 flex items-center gap-4 min-w-[300px] max-w-[500px]">
			{#if type === 'success'}
				<div class="w-10 h-10 rounded-full bg-green-500 flex items-center justify-center flex-shrink-0">
					<svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
					</svg>
				</div>
			{:else if type === 'error'}
				<div class="w-10 h-10 rounded-full bg-red-500 flex items-center justify-center flex-shrink-0">
					<svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
					</svg>
				</div>
			{:else}
				<div class="w-10 h-10 rounded-full bg-gray-900 flex items-center justify-center flex-shrink-0">
					<svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
					</svg>
				</div>
			{/if}
			
			<p class="text-gray-900 font-medium flex-1">{message}</p>
			
			<button 
				onclick={close}
				class="text-gray-400 hover:text-gray-900 transition-colors"
				aria-label="Close notification"
			>
				<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
				</svg>
			</button>
		</div>
	</div>
{/if}

<style>
	@keyframes slide-up {
		from {
			transform: translate(-50%, 100px);
			opacity: 0;
		}
		to {
			transform: translate(-50%, 0);
			opacity: 1;
		}
	}

	.animate-slide-up {
		animation: slide-up 0.3s ease-out;
	}
</style>

