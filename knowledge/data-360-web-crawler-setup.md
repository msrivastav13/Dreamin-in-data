# Data 360 Web Crawler Setup

## Overview
Data 360 (formerly Data Cloud) can crawl external websites and ingest content as unstructured data for use with Agentforce agents.

## Setup Steps

### 1. Create a Web Connector Connection
- Provide the sitemap URL (XML format, Gzip also supported)
- Our sitemap: `https://pronto-help-center-327a6109e2e3.herokuapp.com/sitemap.xml`

### 2. Configure Data Lake Object
- Select the connection (e.g., "Pronto Help Site")
- **Included Web Pages**: regex to filter pages (e.g., `.*\.html`)
- **Included Page Element**: jQuery selector to target specific content (e.g., `.faq-answer, .faq-item summary` or `main` for all content)
- **Included Website URL Paths**: "Primary path only" works for flat sites
- **Remove URL Parameters**: keep checked to avoid duplicate crawls
- **Ingest data from external domains**: leave unchecked unless you link to external content
- **Last Update Date**: set to deployment date so it picks up all content
- Name the Data Lake Object descriptively (e.g., `Pronto_Help_Center_FAQs`)

### 3. Deploy the Data Stream
- After creating the Data Lake Object, create a Data Stream from it
- Click Deploy — the crawler won't run until the stream is active
- Check Data Stream > Jobs to verify rows were ingested

### 4. Create a Search Index
- Chunks only appear once a Search Index is created targeting the Data Lake Object
- The platform automatically chunks the HTML content and vectorizes it
- Verify chunks appear in the search index tables

## Key Learnings
- The web connector needs a deployed/accessible website with a valid XML sitemap
- The platform handles chunking automatically with default settings
- No need to manually chunk or pre-process content
- Well-structured HTML (headings, lists, details/summary) produces good chunks
