<script context="module">
import {
    getTags
} from "../../_api"

  export async function preload({ params, query }) {
  let tags = await getTags(params.theuser);
    return {tags};
  }
</script>

<script>
  import TagList from "../../../components/TagList.svelte";
  export let tags = [];
</script>

<style>
  ul {
    margin: 0 0 1em 0;
    line-height: 1.5;
  }
</style>

<svelte:head>
  <title>Tags</title>
</svelte:head>

{#await tags then value}
  <TagList tags={value} />
{/await}
