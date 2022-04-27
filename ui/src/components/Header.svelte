<script>
  function close() {
    fetch(`https://${GetParentResourceName()}/close`);
  }
</script>

<div class="flex justify-between items-center">
  <div class="font-bold text-lg">Friends</div>

  <button on:click={close} class="btn btn-sm btn-circle">
    <i class="fa-solid fa-xmark text-lg" />
  </button>
</div>
