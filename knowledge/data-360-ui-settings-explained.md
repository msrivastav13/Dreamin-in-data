# Data 360 UI Settings Explained

A breakdown of every configuration screen encountered during setup.

---

## Screen 1: Data Lake Object — Connection & Configuration Details

### Connection Details

| Setting | Purpose |
|---------|---------|
| **Select Connection** | The web connector you previously created (e.g., "Pronto Help Site"). This ties the Data Lake Object to a specific external data source — in our case, the Heroku-hosted FAQ site. |

### Configuration Details

| Setting | Purpose |
|---------|---------|
| **Included Web Pages** | A regular expression that filters which URLs the crawler should ingest. Use `.*\.html` to grab all HTML pages, or be more specific (e.g., `.*ordering.*`) to limit scope. If left blank, all discovered pages from the sitemap are included. |
| **Included Page Element** | A jQuery/CSS selector that tells the crawler which DOM elements to extract text from. Use `.faq-answer, .faq-item summary` to target FAQ content only, or `main` to grab all main content. If blank, the crawler takes all visible text on the page (including nav, footer, etc. which adds noise). |
| **Included Website URL Paths** | Controls how deep the crawler follows links. "Primary path only" means it sticks to the root-level pages listed in the sitemap. Use this for flat sites; switch to "All paths" if your content lives in nested subdirectories. |
| **Remove URL Parameters** | When checked, strips query parameters (?utm_source=..., ?page=2) before deduplication. Prevents the same page from being crawled multiple times with different tracking params. Keep checked unless query params produce genuinely different content. |
| **Ingest data from external domains** | When checked, the crawler follows links to other domains and ingests that content too. Leave unchecked unless you intentionally want content from third-party sites pulled in. |

### Content Filtering Details

| Setting | Purpose |
|---------|---------|
| **Last Update Date** | Only ingests pages modified after this date. Set it to your deployment date (or earlier) to capture all content. Useful for incremental updates — on subsequent crawls, advance this date to only pick up new/changed content. |

---

## Screen 2: Intelligent Context — New Search Configuration

| Setting | Purpose |
|---------|---------|
| **Data Space** | The Data Cloud data space to store this configuration. Use `default` unless you have multiple data spaces for isolation (e.g., dev vs. prod). |
| **Name** | Human-readable label shown in the UI list (e.g., "Pronto Help Center"). Used to find and manage the configuration later. |
| **API Name** | Machine-readable identifier used in metadata, APIs, and when attaching this config to a Search Index programmatically (e.g., "Pronto_Help_Center"). Must be unique, no spaces. |

---

## Screen 3: Intelligent Context — Add Sources (File Upload)

| Setting | Purpose |
|---------|---------|
| **Upload Files** | Upload up to 5 representative sample files (max 10MB each) of your actual content. These are used as a test corpus to experiment with chunking and retrieval settings. |

### Why upload files if the crawler already chunked everything?

Intelligent Context is a **tuning workbench**, not the production pipeline. The purpose is:

1. **Iterate quickly** — test different chunking strategies on a small sample without re-crawling and re-indexing the entire site each time
2. **Preview chunks** — see exactly how your content gets split before committing
3. **Test retrieval** — run sample queries and see which chunks come back
4. **Apply later** — once the config is tuned, apply it to the full Search Index

The production path (Web Connector → Data Stream → Search Index) uses **default chunking settings** and works without Intelligent Context. This screen exists for teams that need finer control.

### Accepted file types
- HTML files (best match for web-crawled content)
- PDF documents
- TXT files
- CSV was **not accepted** in our testing

### What to upload for Pronto
The 5 HTML files from the FAQ site (`index.html`, `ordering.html`, `delivery.html`, `merchants.html`, `account.html`) since they're exactly what the crawler ingested.

---

## Relationship Between These Screens

```
[Web Connector + Sitemap]
        │
        ▼
[Data Lake Object Config]  ← Screen 1 (what to crawl, what to extract)
        │
        ▼
[Data Stream Deploy]       ← triggers the actual crawl
        │
        ▼
[Search Index]             ← auto-chunks with defaults OR uses Intelligent Context config
        ▲
        │
[Intelligent Context]      ← Screens 2 & 3 (optional tuning, applied to Search Index)
```

The key insight: Screens 2 & 3 (Intelligent Context) are **optional**. Screen 1 (Data Lake Object config) plus a deployed Data Stream and Search Index is the minimum viable path.
