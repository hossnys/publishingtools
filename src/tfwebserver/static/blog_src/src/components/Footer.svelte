<script>
  import showdown from "showdown";
  import { stores } from "@sapper/app";
  const { preloading, page, session } = stores();
  export let metadata = {};
  let converter = new showdown.Converter({ metadata: true });
  if (metadata.allow_footer === undefined) {
    metadata.allow_footer = true; // handeling all blogs case
  }
</script>

<!-- Page Footer-->
{#if metadata.allow_footer}
  <footer class="main-footer">
    <div class="container">

      <div class="row">
        <div class="col-md-6">
          <p>
            &copy;
            <a href="https://threefold.io">threefold.io</a>
            All rights reserved.
          </p>
        </div>
        <div class="col-md-6">
          <div class="list social text-right">
            <ul>
              <li class="mx-1">
                <a href="https://www.facebook.com/threefold.io" target="_blank">
                  <i class="fab fa-facebook-f fa-1x" />
                </a>
              </li>
              <li class="mx-1">
                <a href="https://twitter.com/threefold_io" target="_blank">
                  <i class="fab fa-twitter fa-1x" style="color:white" />
                </a>
              </li>
              <li class="mx-1">
                <a
                  href="https://www.linkedin.com/company/threefold-foundation/"
                  target="_blank">
                  <i class="fab fa-linkedin-in fa-1x" />
                </a>
              </li>
              <li class="mx-1">
                <a
                  href="https://www.youtube.com/threefoldfoundation"
                  target="_blank">
                  <i class="fab fa-youtube fa-1x" />
                </a>
              </li>
              <li>
                <a href="https://t.me/threefoldnews" target="_blank">
                  <i class="fab fa-telegram-plane fa-1x" />
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </footer>
{/if}
