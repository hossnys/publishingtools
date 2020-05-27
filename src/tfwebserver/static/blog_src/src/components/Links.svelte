<script>
  export let header = "";
  export let links = [];

  let getStyleForLink = link => {
    let theStyle = "";
    console.log(typeof link.colorcode);
    console.log(`color code is >${link.colorcode}<`);
    if (link.colorcode.trim() !== "" || link.colorcode !== null) {
      theStyle += `color: ${link.colorcode}`;
    }
    return theStyle;
  };
</script>

{#if links}
  <ul>
    {#each links as link}
      <li>
        {#if link.link || link.page}
          <a href={link.link || link.page} target="_blank">

            {#if link.faclass}
              <i class={link.faclass} style={getStyleForLink(link)} />
            {/if}

            {#if link.img}
              <img src={link.img} alt={link.img} />
            {/if}

            {#if link.title}{link.title}{/if}

          </a>
        {/if}
      </li>
    {/each}
  </ul>
{/if}
