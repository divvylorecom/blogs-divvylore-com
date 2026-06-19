# Divvylore Journal

A NYTimes-inspired blog for Divvylore, built with **Jekyll** and published with
**GitHub Pages**. Articles are plain Markdown files, and a custom plugin turns
configured words and phrases into hyperlinks automatically.

---

## Highlights

- **Write in Markdown** — drop a `.md` file in `_posts/`.
- **Swappable themes** — the NYTimes-style look is one skin; switch to `minimal`
  or `sepia` (or add your own) by changing a single line in `_config.yml`. See
  [Themes](#themes).
- **NYTimes-style reading experience** — serif headlines, a clean single-column
  article, a lead-story grid on the home page, section rails and a sticky
  masthead.
- **Automatic smart links** — mention `MoneyControl`, `SEBI`, `RBI`, `NSE`,
  `mutual funds`, etc., and the build links them to the right destination
  without you pasting a URL. Configured in [`_data/autolinks.yml`](_data/autolinks.yml).
- **SEO, sitemap and RSS** out of the box (`jekyll-seo-tag`, `jekyll-sitemap`,
  `jekyll-feed`).

---

## Project layout

```
blogs-divvylore-com/
├── _config.yml              # Site settings + autolink options
├── Gemfile                  # Ruby dependencies (Jekyll, Nokogiri, plugins)
├── CNAME                    # Custom domain (blogs.divvylore.com)
├── index.html               # Home page (lead grid + latest)
├── about.md                 # Standalone page
├── 404.html
├── _data/
│   ├── autolinks.yml        # term → URL dictionary (the smart-link feature)
│   ├── themes.yml           # registry of selectable themes (label + fonts)
│   └── navigation.yml       # top section menu
├── _layouts/                # default, home, post, page, section
├── _includes/               # head, header, footer, post-card
├── _plugins/
│   └── autolink.rb          # the auto-hyperlink engine
├── _posts/                  # your articles (yyyy-mm-dd-title.md)
├── sections/                # section landing pages
├── assets/
│   ├── css/
│   │   ├── base.css         # shared structure (theme-agnostic)
│   │   └── themes/          # one .css per theme (palette + typography)
│   ├── js/ img/ favicon.svg
└── .github/workflows/jekyll.yml   # build + deploy to GitHub Pages
```

---

## Writing a new article

1. Create a file in `_posts/` named `YYYY-MM-DD-your-title.md`.
2. Add front matter, then write in Markdown:

   ```markdown
   ---
   layout: post
   section: Markets
   title: "Your headline"
   subtitle: "A one-line standfirst."
   author: Your Name
   date: 2026-06-19 09:00:00 +0530
   read_time: "5 min read"
   image: /assets/img/markets.svg     # optional lead image
   image_caption: "Illustration: Divvylore"
   tags: [markets, explainer]
   ---

   Your story here. Mention MoneyControl or the Reserve Bank of India and the
   build links them for you.
   ```

3. `section` should match one of the section pages in `sections/` so the article
   shows up under that menu item.

---

## The smart-link feature

Edit [`_data/autolinks.yml`](_data/autolinks.yml) to add or change links. Each
entry:

```yaml
- term: MoneyControl                 # word/phrase to detect
  url: https://www.moneycontrol.com/ # where it links
  title: MoneyControl — markets & news   # optional tooltip
  match: word            # "word" (default) or "phrase" (match inside words)
  case_sensitive: false  # default false
  limit: 1               # max links per article (0 = unlimited; default from _config.yml)
```

Behaviour and safety:

- The longest phrase wins, so `Reserve Bank of India` beats `India`.
- By default each term is linked **once per article** to keep reading clean
  (change `autolink.limit_per_term` in `_config.yml`, or `limit:` per term).
- The engine never re-links text inside existing links, code blocks, or
  headings.
- Auto-generated links get a `.auto-link` class (subtle dotted underline).

> Because this relies on a custom Ruby plugin, the site is built with Bundler in
> GitHub Actions — **not** the default GitHub Pages gem build (which ignores
> `_plugins/`).

---

## Themes

The look-and-feel is a **swappable skin**. All markup and layout live in shared,
theme-agnostic files; each theme just supplies a palette and typography through
CSS variables.

**Switch theme** — change one line in [`_config.yml`](_config.yml):

```yaml
theme_name: nytimes   # nytimes | minimal | sepia
```

(Config changes need a Jekyll restart, not just a save.)

**Built-in themes**

| key       | feel                                   |
| --------- | -------------------------------------- |
| `nytimes` | NYTimes-style editorial serif (default)|
| `minimal` | modern, clean, sans-serif (Inter)      |
| `sepia`   | warm, low-glare long-read              |

**How it fits together**

- [`assets/css/base.css`](assets/css/base.css) — all structure, layout and
  components, written against CSS variables. You rarely touch this.
- `assets/css/themes/<name>.css` — defines `:root` variables (colours, fonts,
  reading width) plus any small personality overrides.
- [`_data/themes.yml`](_data/themes.yml) — registers each theme's label, CSS
  file and Google Fonts URL.

**Add your own theme**

1. Create `assets/css/themes/<your-theme>.css` and define the `:root` variables
   (copy an existing theme as a starting point).
2. Add an entry to `_data/themes.yml` with its `fonts` URL.
3. Set `theme_name: <your-theme>` in `_config.yml`.

The active theme key is also added as a `theme-<name>` class on `<body>`, so you
can scope further CSS if needed.

---

## Run locally

Requires Ruby 3.x and Bundler.

```powershell
cd blogs-divvylore-com
bundle install
bundle exec jekyll serve --livereload
# open http://127.0.0.1:4000
```

---

## Deploy to GitHub Pages

This folder is its own Git repository, so push it to a GitHub repo and let the
included workflow build and deploy it.

1. Push the contents of `blogs-divvylore-com/` to a GitHub repository.
2. In **Settings → Pages → Build and deployment**, set **Source** to
   **GitHub Actions**.
3. Push to `main`. The workflow at
   [`.github/workflows/jekyll.yml`](.github/workflows/jekyll.yml) builds with
   Bundler (so the custom plugin runs) and deploys `_site/`.

### Custom domain

- `CNAME` is set to `blogs.divvylore.com`. Change it if you use a different
  host, and update `url` in `_config.yml` to match.
- At your DNS provider, point the subdomain to GitHub Pages:
  - `CNAME` record: `blogs` → `<your-github-username>.github.io`
- In **Settings → Pages**, add the same custom domain and enable
  **Enforce HTTPS** once the certificate is issued.

If you publish at `https://<user>.github.io/<repo>/` instead of a custom domain,
the workflow already passes the correct `--baseurl`, so links keep working.
