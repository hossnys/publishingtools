<script context="module">
  import { getPosts, getPages, getMetadata, getTags } from "../_api.js";

  export async function preload({ host, path, params, query }) {
    try {
      const pages = await getPages(params.theuser);
      const metadata = await getMetadata(params.theuser);
      const tags = await getTags(params.theuser);
      const allPosts = await getPosts(params.theuser);
      // please notice it might be undefined
      // parseInt(undefined) > 0 -> false
      // parseInt(undefined) < 0 -> false
      // because.. javascript `\-()-/`

      let posts = allPosts.slice(0, 3);

      return { pages, posts, metadata, tags };
    } catch (error) {
      console.log(error);
    }
  }
</script>

<script>
  import Nav from "../../components/Nav.svelte";
  import Sidebar from "../../components/Sidebar.svelte";
  import Footer from "../../components/Footer.svelte";
  // import Header from "../../components/Header.svelte";
  import TagCloud from "../../components/TagCloud.svelte";
  import ListPagination from "../../components/ListPagination.svelte";

  export let segment;
  export let pages = [];
  export let posts = [];
  export let metadata = {};
  export let tags = [];

  import { stores } from "@sapper/app";
  const { preloading, page, session } = stores();
</script>

<!-- {#await metadata then value}
  <Header
    blogName={value.blog_name}
    blogDescription={value.blog_description}
    blogLogo={value.blog_logo}
    authorName={value.authorName} />
{/await} -->

{#await pages}
  loading
{:then pagesvalue}
  {#await metadata then metavalue}

    <Nav {segment} metadata={metavalue} pages={pagesvalue} />
  {/await}
{/await}
<div>
  <div class="container">
    <div class="row">
      <main class="posts-listing col-lg-8">
        <div class="container">
          <!-- post -->
          <slot />
        </div>
      </main>

      <aside class="col-lg-4">
        <Sidebar {metadata} {tags} {posts} />
      </aside>
    </div>
  </div>
  {#await metadata then metavalue}
    <Footer {metavalue} />
  {/await}

</div>
