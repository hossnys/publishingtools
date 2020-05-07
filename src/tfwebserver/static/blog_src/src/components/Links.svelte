<script>
  export let header = "";
  export let links = [];
</script>

{#if links}
  <ul>
    {#each links as link}
      {#if Object.keys(link).length}
        <li>
          {#if link.img}
            <a href={link.link} target="_blank">
              <img
                src={link.img}
                alt={link.img}
                style="height: 50px;width: 50px;" />
            </a>
          {:else}
            <a href={link.link} target="_blank">{link.title}</a>
            <!-- else content here -->
          {/if}
        </li>
      {/if}
    {/each}
  </ul>
{/if}
