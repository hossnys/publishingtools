<script>
    import {
        search
    } from "../routes/_api";

  import { stores } from "@sapper/app";

  const { preloading, page, session } = stores();

  export let blogName = $page.params.theuser;
  let query = "";
  export let search_res = "";

  export async function search_method(e) {

    e.preventDefault();
    search_res = await search(blogName, query);
  }
  export function clear_results(e) {
    if (e.key === "Escape" || e.type === "click") {
      search_res = "";
    } else if (e.key == "Backspace") {
      if (query === "") {
        search_res = "";
      }
    }
  }
</script>

<form on:submit={search_method} on:keyup={clear_results} class="search-form">
  <div class="form-group">
    <input
      type="search"
      bind:value={query}
      placeholder="What are you looking for?"
      id="search" />
    <button type="submit" class="submit search-btn" on:click={search_method}>
      <i class="icon-search" />
    </button>
    {#if search_res}
      <p>Search Result</p>
      <ul>
        {#each search_res as res}
          <li class="list-results">
            <a
              href="{res.blog_name}/{res.type}/{res.slug}"
              on:click={clear_results}>
              {res.type}: {res.slug}
            </a>
          </li>
        {/each}
      </ul>
      <p>Total: {Object.keys(search_res).length} Results</p>
    {/if}
  </div>
</form>
