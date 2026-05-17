# Document AI (Data 360)

## What It Is
Document AI extracts **structured data** from unstructured documents (PDFs, images, scanned forms). It uses LLMs to read a document and pull out specific fields you define into a Data Lake Object — turning a PDF into rows and columns.

## Location in UI
Data Cloud > Process Content > Document AI

---

## Document AI vs. Intelligent Context

| | **Document AI** | **Intelligent Context** |
|--|-----------------|------------------------|
| **Purpose** | Extract structured fields from documents (form → table) | Chunk documents for semantic search/retrieval (document → vector index) |
| **Input** | PDF, JPEG, PNG, JPG (150 DPI+ recommended) | HTML, PDF, TXT (unstructured text) |
| **Output** | Structured Data Lake Object with defined fields (e.g., restaurant_name, tax_id, owner_name) | Chunked + vectorized content in a Search Index for RAG |
| **Use case** | Processing forms, invoices, applications, contracts — extracting specific values | Grounding Agentforce agents with knowledge from documents for Q&A |
| **LLM role** | Reads the document and extracts values into a schema you define | Determines optimal chunking and assists retrieval |
| **Analogy** | OCR + form parsing on steroids | Building a searchable knowledge base |
| **Model used** | Gemini 2.5 Flash (as shown in UI) | Platform default |

**Key distinction:** Intelligent Context asks "what is this document about?" (for search). Document AI asks "what specific values are in this document?" (for data extraction).

---

## Setup Flow (from screenshots)

### Step 1: Create Document Schema Configuration
Two options:
- **From a Source Object** — use files already in an Unstructured Data Model Object (UDMO) that you've already ingested
- **Without a Source Object** — define schema independently for use in programmatic workflows (Flows, Apex)

### Step 2: Configure Document Schema
Three-panel layout:
- **Left panel (Files):** Upload sample documents (PDF, JPEG, PNG, JPG). These are used to train/test extraction.
- **Center panel:** Document preview — shows the uploaded document with extracted fields highlighted
- **Right panel (Outputs):** Define the fields to extract. Three methods:
  - **Create Manually** — you define each field name and type by hand
  - **Using Auto-Extraction** — LLM reads the uploaded doc and suggests fields automatically
  - **Create with Template** — use predefined templates for common document types (invoices, receipts, etc.)

### Step 3: Test & Publish
- Click **Test** to run extraction on uploaded samples and verify accuracy
- **Save Draft** to iterate
- **Publish** when ready for production use

---

## Demo Use Case: Merchant Onboarding Document Processing

### Scenario
When a new restaurant wants to partner with Pronto, they submit a partnership application form (PDF). Today this is manually reviewed and data-entered. With Document AI, the extraction is automated.

### What gets extracted (schema fields)

| Field Name | Type | Description |
|-----------|------|-------------|
| restaurant_name | Text | Name of the restaurant |
| legal_business_name | Text | Legal entity name |
| business_address | Text | Physical address |
| phone_number | Text | Business phone |
| email | Text | Business email |
| tax_id | Text | EIN number |
| business_license | Text | License number |
| owner_name | Text | Primary owner |
| cuisine_type | Text | Type of food served |
| avg_prep_time | Text | Average preparation time |
| operating_hours | Text | Business hours |
| preferred_tier | Text | Basic/Plus/Premium |
| estimated_weekly_orders | Text | Volume estimate |
| delivery_radius | Text | Preferred delivery range |
| health_inspection_score | Number | Latest score |
| offers_catering | Boolean | Catering available |
| signature_date | Date | When application was signed |

### Demo flow
1. Upload a merchant application PDF to Document AI
2. Use **Auto-Extraction** to let the LLM detect fields automatically
3. Show extracted values mapped to the schema
4. Show how this populates a Data Lake Object
5. (Bonus) Wire it to a Flow that auto-creates an Account + Merchant record in Salesforce

### Sample documents created
Located in `document-ai-samples/`:
- `merchant-application-01.pdf` — Sakura Ramen House (Plus tier, Japanese cuisine)
- `merchant-application-02.pdf` — Big Tony's Pizza (Premium tier, 3 locations)
- `merchant-application-03.pdf` — Green Bowl Salads (Basic tier, health food)

### Why this demo works
- Relatable: everyone understands merchant/partner onboarding paperwork
- Shows clear value: manual data entry → automated extraction
- Contrasts well with Intelligent Context: same platform, different purpose (structured extraction vs. semantic search)
- Multi-document: shows consistency across varied applications
- Natural next step: extracted data flows into Salesforce CRM records

---

## Out-of-Box Templates vs Custom

### Out-of-Box (Create with Template)
Pre-built schemas for common document types. Likely includes:
- Invoices (vendor, amount, line items, dates)
- Receipts (merchant, total, items, payment method)
- Contracts (parties, dates, terms)
- Identity documents (name, DOB, ID number)

### Custom (what we're doing)
Define your own schema for domain-specific documents. Best for:
- Industry-specific forms (merchant applications, insurance claims, loan docs)
- Internal documents with unique structures
- Any document type not covered by templates

### Auto-Extraction (Using Auto-Extraction)
Upload a sample document and the LLM proposes a schema automatically. Best starting point when you're not sure what fields exist — let the AI suggest, then refine manually.
