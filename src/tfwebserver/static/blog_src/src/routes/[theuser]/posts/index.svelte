<script context="module">
  import { getPosts, getMetadata } from "../../_api";

  export async function preload({ host, path, params, query }) {
    console.log("params in posts index", JSON.stringify(params));

    let pageNum = parseInt(query.page);
    if (!pageNum) {
      this.redirect(302, `${params.theuser}/posts?page=1`);
    }

    let allPosts = await getPosts(params.theuser);

    // please notice it might be undefined
    // parseInt(undefined) > 0 -> false
    // parseInt(undefined) < 0 -> false
    // because.. javascript `\-()-/`

    if (pageNum > 0) {
      pageNum--;
    }

    console.log(allPosts.length);
    // console.log("parsed blogs ", allPosts);
    let totalPostsLength = allPosts.length;
    const metadata = await getMetadata(params.theuser);

    let per_page = metadata.posts_per_page || 5;
    let begin = pageNum * per_page;
    let end = pageNum * per_page + per_page;
    let posts = allPosts.slice(begin, end);

    return { path, posts, totalPostsLength, metadata };
  }
</script>

<script>
  import PostList from "../../../components/PostList.svelte";
  import ListPagination from "../../../components/ListPagination.svelte";

  export let posts = [];
  export let metadata;
  export let totalPostsLength;
  export let path;
  import { stores } from "@sapper/app";
  const { preloading, page, session } = stores();
  console.log("in posts index", $page.params);
  export let username = $page.params.theuser;
  export let pageNum = $page.query.page;
</script>

<svelte:head>
  <title>Blog</title>

  {#if metadata.cookie_consent_popup}
    <!-- cookie script -->
    <script type="text/javascript">
      cookieconsent.run({
        notice_banner_type: "headline",
        consent_type: "express",
        palette: "light",
        language: "en",
        website_name: "https://blog.threefold.io/",
        cookies_policy_url: "https://wiki.threefold.io/#/privacypolicy"
      });
    </script>
  {/if}

</svelte:head>

{#await posts then value}
  <div class="row">
    <PostList posts={value} {username} />
  </div>
  <div class="row">
    <ListPagination
      articlesCount={totalPostsLength}
      articlesPerPage={metadata.posts_per_page}
      objectPath="/blog/{username}/posts"
      page={pageNum} />
  </div>
{/await}
