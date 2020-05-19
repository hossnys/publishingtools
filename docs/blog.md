# Blogging system

Here we discuss blog configurations and a typical structure for a blog.



## Blog structure

```
➜  blog_threefold git:(master) tree
.
├── assets
│   └── images
│       ├── 10x_times_power.jpg
│       ├── airbnb_for_internet_capacity.jpg
│       ├── blog_header.jpg
│       ├── centralized_problems.png
│       ├── circular_economy.png
│       ├── escape.jpg
│       ├── ethicaldesign.png
│       ├── ethical_product_design.jpg
│       ├── four_new_sites.png
│       ├── internet_is_growing.jpg
│       ├── mou.jpg
│       ├── myth_big_datacenters_are_efficient.jpg
│       ├── neutral_internet.jpg
│       ├── open_source_technology.jpg
│       ├── our_magical_zero_node.jpg
│       ├── person_woman_apple_hotel.jpg
│       ├── stellar_header.png
│       ├── technology_for_internet.jpg
│       ├── the_need_for_new.jpg
│       ├── threefold_hpe.jpeg
│       ├── threefold_token.jpg
│       ├── token_new_internet.png
│       ├── unbranded.jpg
│       ├── what_can_i_do.jpg
│       └── why_we_do.png
├── metadata.yml
├── pages
│   └── about.md
├── posts
│   ├── 10x_times_power.md
│   ├── airbnb_for_internet_capacity.md
│   ├── do_with_new_edge_cloud.md
│   ├── escape_the_great_hack.md
│   ├── ethical_design_manifesto.md
│   ├── internet_growing_wild.md
│   ├── intro_to_farming.md
│   ├── magical_zero_node.md
│   ├── myth_big_datacenter_are.md
│   ├── need_for_new_neutral_internet.md
│   ├── open_source_technology.md
│   ├── tech_new_internet.md
│   ├── the_need_for_a_new_digital_currency.md
│   ├── threefold_hpe.md
│   ├── threefolds_circular_economy.md
│   ├── threefold_token_intro.md
│   ├── why_threefold_chose_stellar.md
│   ├── why_we_do_what_we_do.md
│   └── you_are_unique.md
└── README.md

```

- assets directory: most likely to contain the images dir to use across the blog
- pages directory: has markdown files that represents pages
- posts directory: has markdown files that represents posts
- metadata.yml: a YAML file describing the blog and it's relevant configurations


## Metadata.yml

```
blog_title: "xmonader weblog"
blog_description: "let there be posts"
blog_logo: logo.svg"
author_name: "ahmed"
author_email: "ahmed@there.com"
author_image_filename: "me.jpg"
posts_dir: "posts"
pages_dir: "pages"
images_dir: "assets/images"
github_username: "xmonader"
posts_per_page: 6
allow_disqus: false

sidebar_links:
  - title: google
    link: https://google.com
  - title: yahoo
    link: https://yahoo.com

sidebar_social_links:
  - title: facebook
    link: https://www.facebook.com/ThreeFoldNetwork/
    class: fab fa-facebook
  - title: instagram
    link: https://instagram.com
    faclass: fab fa-instagram
  - title: twitter
    link: https://instagram.com
    faclass: fab fa-twitter

nav_links:
  - title: about
    page: about.md
  - title: contact us
    page: contactus.md
  - title: foundation link
    link: https://threefold.io

```
Here parameters are self explanatory

### Global section
```
blog_title: "xmonader weblog"
blog_description: "let there be posts"
blog_logo: logo.svg"
author_name: "ahmed"
author_email: "ahmed@there.com"
author_image_filename: "me.jpg"
posts_dir: "posts"
pages_dir: "pages"
images_dir: "assets/images"
github_username: "xmonader"
posts_per_page: 6
allow_disqus: false
allow_navbar: true

```
- blog title: sets the title of blog pages
- blog_description: sets the blog description
- blog_logo: logo used for the blog (needs to exist in images dir)
- author_name: author name to be used across the website
- author_email: author email to be used across the website
- posts_dir: where your markdown files for posts exist (default its `posts`)
- pages_dir: where your markdown files for pages exist (default `pages`)
- images dir: where your images for the blog exist (default `assets/images`)
- posts_per_page: number of posts to show in page
- allow_disqus: to allow disqus plugin
- allow_navbar: to allow navigation links
- allow_footer: to show the footer.

### Sidebar config

```
sidebar_links:
  - title: google
    link: https://google.com
  - title: yahoo
    link: https://yahoo.com
```

Describes what shows up in sidebar links section (think if you want to pinposts for instance.)


```
sidebar_social_links:
  - title: facebook
    link: https://www.facebook.com/ThreeFoldNetwork/
    class: fab fa-facebook
  - title: instagram
    link: https://instagram.com
    faclass: fab fa-instagram
  - title: twitter
    link: https://instagram.com
    faclass: fab fa-twitter

```
lists your relevant social media links

### Navlinks

```
nav_links:
  - title: about
    page: about.md
  - title: contact us
    page: contactus.md
  - title: foundation link
    link: https://threefold.io

```
you can control the links in the navbar using 

## Post structure

```
---
title: "Decentralizing the Internet"
author: Roel
author_image: roel.jpg
tags: capacity, decentralization, farming
published_at: 2019-8-21
post_image: airbnb_for_internet_capacity.jpg
---

more markdown omitted...

```
- title: describes post title
- author: to override the global author name
- author_image: to override the global author image
- tags: to define tags for the post
- published at: the date `YEAR-MONTH-DAY`
- post_image: custom post image



### Development


#### UI 
- UI code exists in `publishingtools/src/static/blog_src/src`
- `build_blog.sh` can be used to rebuild the sapper app.



#### API

code exist in `publishingtools/src/tfwebserver/blogging` and `publishingtools/src/tfwebserver/api/blog.cr`


