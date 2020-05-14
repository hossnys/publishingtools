<script>
  import showdown from "showdown";
  import Tags from "./Tags.svelte";
  import { stores } from "@sapper/app";
  const { preloading, page, session } = stores();
  export let username = $page.params.theuser;
  export let metadata = {};
  export let post;
  console.log(post);
  let converter = new showdown.Converter({ metadata: true });
  converter.setFlavor("github");
  let mdtext, post_image_link, post_author_image_link;

  $: {
    mdtext = converter.makeHtml(post.content);

    let post_image = post.post_image;
    post_image_link = "";

    if (!post_image) {
      post_image_link = "img/blog-post-1.jpeg";
    } else if (!post_image.startsWith("http")) {
      post_image_link = `/blog/${username}/assets/images/${post_image}`;
    } else {
      post_image_link = post_image;
    }

    let post_author_image = post.author_image;
    post_author_image_link = "";
    if (!post_author_image) {
      post_author_image_link = "me.jpg";
    } else if (!post_author_image.startsWith("http")) {
      post_author_image_link = `/blog/${username}/assets/images/${post_author_image}`;
    } else {
      post_author_image_link = post_author_image;
    }
  }

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

<!-- Latest Posts -->
<main class="post blog-post col-lg-12">
  <div class="container">
    <div class="post-single">
      <div class="post-thumbnail text-center">
        <img
          src={post_image_link}
          onerror="this.src="
          alt="..."
          class="img-fluid h-auto" />
      </div>
      <div class="post-details">
        <h1>{post.title}</h1>
        <div
          class="post-footer d-flex align-items-center flex-column flex-sm-row">
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
              <span>
                <b>{post.author}|</b>
              </span>
            </div>
          </a>
          <div class="d-flex align-items-center flex-wrap">
            <div class="date">{format(post.published_at)}</div>
          </div>
          <div class="widget tags d-flex justify-content-between ml-auto mb-0">
            {#if post.tags.length}
              <ul class="list-inline">
                {#each post.tags as tag}
                  <li class="list-inline-item">
                    <a href="{username}/tags/{tag}" class="tag">#{tag}</a>
                  </li>
                {/each}
              </ul>
            {/if}
          </div>
        </div>
        <div class="post-body">
          <p>
            {@html mdtext}
          </p>

        </div>
        <div class="widget tags d-flex justify-content-between">
          {#if post.tags.length}
            <ul class="list-inline">
              {#each post.tags as tag}
                <li class="list-inline-item">
                  <a href="{username}/tags/{tag}" class="tag">#{tag}</a>
                </li>
              {/each}
            </ul>
          {/if}
        </div>

        <div
          class="posts-nav d-flex justify-content-between align-items-stretch
          flex-column flex-md-row">
          {#if post.prev.slug !== undefined}
            <a
              href="{username}/posts/{post.prev.slug}"
              class="prev-post text-left d-flex align-items-center">
              <div class="icon prev">
                <i class="fa fa-angle-left" />
              </div>
              <div class="text">
                <strong class="text-primary">Previous Post</strong>
                <h6>{post.prev.title}</h6>
              </div>
            </a>
          {/if}

          {#if post.next.slug !== undefined}
            <a
              href="{username}/posts/{post.next.slug}"
              class="next-post text-right d-flex align-items-center
              justify-content-end">
              <div class="text">
                <strong class="text-primary">Next Post</strong>
                <h6>{post.next.title}</h6>
              </div>
              <div class="icon next">
                <i class="fa fa-angle-right" />
              </div>
            </a>
          {/if}

        </div>
      </div>
    </div>
  </div>
  {#if metadata.allow_disqus}
    <!-- content here -->
    <div id="disqus_thread" />

    <script>
      // configure discuss
      var disqus_config = function() {
        this.page.url = location.href;
        this.page.identifier = location.pathname; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
      };

      (function() {
        // DON'T EDIT BELOW THIS LINE
        var d = document,
          s = d.createElement("script");
        s.src = "https://threefoldblog.disqus.com/embed.js";
        s.setAttribute("data-timestamp", +new Date());
        (d.head || d.body).appendChild(s);
      })();
    </script>
    <noscript>
      Please enable JavaScript to view the
      <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a>
    </noscript>

    <script id="dsq-count-scr" src="//threefoldblog.disqus.com/count.js" async>

    </script>
  {/if}

</main>
