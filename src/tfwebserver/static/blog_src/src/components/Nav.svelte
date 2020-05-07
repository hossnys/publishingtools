<script>
  import showdown from "showdown";

  import { stores } from "@sapper/app";
  const { preloading, page, session } = stores();
  export let username = $page.params.theuser;
  if (username === undefined) {
    username == "blog";
  }
  $: currentuser = $page.params.theuser;
  export let segment;
  export let pages = [];
  import SearchBar from "./SearchBar.svelte";
  export let metadata = {};
  let converter = new showdown.Converter({ metadata: true });
  if (metadata.allow_navbar === undefined) {
    metadata.allow_navbar = true; // handeling all blogs case
  }
</script>

{#if metadata.allow_navbar}
  <nav class="navbar fixed-top border-0">
    <div class="container">
      <a class="logo mr-auto" href="/blog/{username}/posts">
        <img src="img/TFT-LOGO.png" alt="TFT Logo" />
      </a>
    </div>
  </nav>
{/if}
