# Intelligent Context (Data 360)

## What It Is
Intelligent Context is a pre-configuration/tuning tool in Data Cloud's Process Content section. It lets you experiment with how content gets chunked and retrieved before applying settings to a full search index.

## Location in UI
Data Cloud > Process Content > Intelligent Context

## Setup Flow
1. Click "New Configuration"
2. Enter Data Space (`default`), Name, and API Name
3. Upload sample source files (up to 5 files, 10MB each)
4. Test retrieval queries against the sample
5. Once satisfied, apply the configuration to your Search Index

## Accepted File Types
- HTML, PDF, TXT (unstructured documents)
- CSV was NOT accepted in our testing
- HTML files from the FAQ site are the best fit

## Relationship to Search Indexes
- Intelligent Context is OPTIONAL — the web connector pipeline works without it
- Default chunking happens automatically when you create a Search Index
- Intelligent Context lets you CUSTOMIZE chunking (chunk size, overlap, metadata extraction)
- Most useful for complex documents (long PDFs, mixed formats) where defaults produce poor results

## Two Paths to Grounding

### Path A: Direct (what we used)
Web Connector → auto-chunk → Search Index → works out of the box

### Path B: Tuned with Intelligent Context
Upload sample → tune chunking config → apply config to Search Index → better retrieval for complex content

## When to Use Intelligent Context
- Complex unstructured documents where default chunking is poor
- When you need to control chunk size or overlap
- When you want to test retrieval quality before full indexing
- NOT needed for well-structured HTML FAQ pages (defaults work fine)
