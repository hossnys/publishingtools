<script>
  export let header = "";
  export let links = [];

  let getStyleForLink = link => {
    let theStyle = "height: 50px;width: 50px;";
    if (link.colorcode !== null) {
      theStyle += `color: ${link.colorcode}`;
    }
    console.log(`the style is ${theStyle}`);
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
