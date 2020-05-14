<script>
  import showdown from "showdown";
  import Tags from "./Tags.svelte";
  import { excerptOf } from "../_helper.js";
  export let post = "";
  import { stores } from "@sapper/app";
  const { preloading, page, session } = stores();
  export let username = $page.params.theuser;
  let converter = new showdown.Converter({ metadata: true });
  converter.setFlavor("github");
  let mdtext = converter.makeHtml(post.content);
  export let showExcerpt = true;
  let post_image = post.post_image;
  let post_image_link = "";

  if (!post_image) {
    post_image_link = "img/blog-post-1.jpeg";
  } else if (!post_image.startsWith("http")) {
    post_image_link = `/blog/${username}/assets/images/${post_image}`;
  } else {
    post_image_link = post_image;
  }

  let post_author_image = post.author_image;
  let post_author_image_link = "";
  let summary = "";
  if (!post_author_image) {
    post_author_image_link = "me.jpg";
  } else if (!post_author_image.startsWith("http")) {
    post_author_image_link = `/blog/${username}/assets/images/${post_author_image}`;
  } else {
    post_author_image_link = post_author_image;
  }

  //   let summary = mdtext
  //     .split("\n")
  //     .splice(1)
  //     .join("\n")
  //     .slice(0, 300);
  summary = post.description || post.excerpt || excerptOf(mdtext);
  //   import { fly } from "svelte/transition";
  export function format(inputDate) {
    var date = new Date(inputDate);
    if (!isNaN(date.getTime())) {
      var day = date.getDate().toString();
      var month = (date.getMonth() + 1).toString();
      // Months use 0 index.

      return (
        (day[1] ? day : "0" + day[0]) +
        "/" +
        (month[1] ? month : "0" + month[0]) +
        "/" +
        date.getFullYear()
      );
    }
  }
</script>

<div class="post col-xl-6">
  <div class="post-thumbnail text-center">
    <a rel="prefetch" href="{username}/posts/{post.slug}">
      <img
        src={post_image_link}
        onerror="this.src='img/blog-post-1.jpeg'"
        alt="..."
        class="img-fluid" />
    </a>
  </div>
  <div class="post-details">
    <div
      class="post-footer d-flex align-items-center flex-column flex-sm-row my-3">
      <a
        href="{username}/posts/{post.slug}"
        class="author d-flex align-items-center flex-wrap">
        <div class="avatar">
          <img
            src={post_author_image_link}
            onerror="this.src='me.jpg'"
            alt="..."
            class="img-fluid" />
        </div>
        <div class="title">
          <span class="font-weight-bold">{post.author}</span>
        </div>
      </a>
      <div class="d-flex align-items-center ml-auto flex-wrap">
        <!-- Change date format -->
        <div class="date">{format(post.published_at)}</div>
      </div>
    </div>

    <a rel="prefetch" href="{username}/posts/{post.slug}">
      <h3 class="h4">{post.title}</h3>
    </a>
    {#if showExcerpt}
      <p class="text-muted">{summary} ..</p>
    {/if}
    <div class="widget tags d-flex justify-content-between">
      {#if post.tags}
        {#if post.tags.length}
          <ul class="list-inline">
            {#each post.tags as tag}
              <li class="list-inline-item">
                <a href="{username}/tags/{tag}" class="tag">#{tag}</a>
              </li>
            {/each}
          </ul>
        {/if}
      {/if}
    </div>
  </div>
</div>
