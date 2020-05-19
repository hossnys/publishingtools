<script>
  export let header = "";
  export let links = [];
</script>

{#if links}
  <ul>
    {#each links as link}
      <li>
        {#if link.link || link.page}
          <a href={link.link || link.page} target="_blank">

            {#if link.faclass}
              <i class={link.faclass} />
            {/if}

            {#if link.img}
              <img
                src={link.img}
                alt={link.img}
                style="height: 50px;width: 50px;" />
            {/if}

            {#if link.title}{link.title}{/if}

          </a>
        {/if}
      </li>
    {/each}
  </ul>
{/if}
