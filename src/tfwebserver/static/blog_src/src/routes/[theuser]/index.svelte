<script context="module">
  export async function preload({ params }) {
    let theuser = params.theuser;
    return this.redirect(302, `${theuser}/posts?page=1`);
  }
</script>
