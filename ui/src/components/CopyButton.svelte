<script>
  import { tick } from 'svelte';
  export let text;

  async function setClipboard(val) {
    const input = document.querySelector('.clipboard');
    input.value = val;
    await tick();

    input.select();
    input.setSelectionRange(0, 9999);

    document.execCommand('copy');

    input.value = '';
  }
</script>

<button on:click={() => setClipboard(text)} class="btn min-h-0 p-1.5 text-xs h-auto rounded-full">
  <i class="fa-solid fa-copy" />
</button>
