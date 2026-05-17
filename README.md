# Unlock Enterprise Data with Salesforce Data 360 and Agentforce

Demo assets and code for the **Data Dreamin' 2026** conference talk.

> Turn scattered enterprise documents — PDFs, invoices, images, and tables — into knowledge your AI agents can actually use.

This session covers three capabilities of the Salesforce Data 360 platform:

1. **Document AI** — Extract structured data from unstructured documents (PDFs, images, scanned forms)
2. **Intelligent Context** — Tune how documents are chunked and retrieved for semantic search
3. **RAG Pipeline with Agentforce** — Power smarter agent responses by grounding them with enterprise data

---

## Demo Scenario: Pronto Food Delivery

The demo uses **Pronto**, a fictional food delivery platform (think DoorDash/Uber Eats). Two personas drive the demos:

| Persona | Problem | Data 360 Solution |
|---------|---------|-------------------|
| **Operations team** | Manually entering data from merchant application PDFs | Document AI auto-extracts fields into structured records |
| **Customer support** | Agents can't answer multi-part customer questions | RAG pipeline retrieves FAQ content and grounds Agentforce responses |

---

## What's in This Repo

```
├── force-app/                  # Salesforce metadata
│   ├── aiAuthoringBundles/     #   Agentforce agent (Pronto Help Agent)
│   ├── classes/                #   Apex (DocumentAIService)
│   ├── flows/                  #   Flows (Route Merchant to Queue)
│   └── ...                     #   Bots, permission sets, objects
│
├── scripts/
│   ├── document-ai/            # Shell & Python scripts for Document AI extraction
│   └── apex/                   # Anonymous Apex scripts for demo setup
│
├── document-ai-samples/        # Sample PDFs and images for extraction demos
│
├── knowledge/                  # Session knowledge base and learnings
│
└── website/                    # Pronto FAQ site (Node.js/Express → Heroku)
    ├── public/                 #   Static HTML/CSS/JS (5 FAQ pages)
    └── data/                   #   CSV data backing the FAQs
```

---

## Demo 1: Document AI — Structured Extraction from PDFs

Extract specific fields (restaurant name, tax ID, operating hours, etc.) from merchant partnership applications.

### How it works

1. Upload a merchant application PDF to the Document AI `extract-data` API
2. The LLM (Gemini 2.5 Flash) reads the document and pulls values into a schema you define
3. Extracted data populates a Data Lake Object — or returns immediately via API

### Try it yourself

Run the shell script against your org:

```bash
# Set your org credentials
export INSTANCE_URL="https://your-instance.my.salesforce.com"
export ACCESS_TOKEN="$(sf org display --json | jq -r '.result.accessToken')"

# Extract fields from a sample merchant application
./scripts/document-ai/extract-merchant-application.sh
```

Or use the Apex version in Developer Console:

```
scripts/apex/document-ai-extract.apex
```

### Sample documents

Located in `document-ai-samples/`:

| File | Description |
|------|-------------|
| `merchant-application-01.pdf` | Sakura Ramen House (Plus tier, Japanese cuisine) |
| `merchant-application-02.pdf` | Big Tony's Pizza (Premium tier, 3 locations) |
| `merchant-application-03.pdf` | Green Bowl Salads (Basic tier, health food) |
| `sakura-ramen-menu.png` | Image extraction demo (menu card) |

### API Reference

```
POST /services/data/v65.0/ssot/document-processing/actions/extract-data
POST /services/data/v65.0/ssot/document-processing/actions/generate-schema
```

- `generate-schema` — auto-generates a JSON Schema from your document (no manual authoring needed)
- `extract-data` — extracts values using a schema you provide
- Supported models: `VertexAIGemini25Flash`, `OpenAIGPT4Omni`

---

## Demo 2: Intelligent Context — Tuning Retrieval

Intelligent Context lets you experiment with how documents are chunked and retrieved before applying settings to a production Search Index.

### When to use it

- Complex documents where default chunking produces poor retrieval results
- When you need to control chunk size or overlap
- When you want to test retrieval quality before full indexing

### Setup path (for the demo)

For the Pronto FAQ site, default chunking works well because the HTML is well-structured. Intelligent Context is demoed as the tool you'd reach for with more complex documents (long PDFs, mixed formats).

---

## Demo 3: RAG Pipeline — Grounding Agentforce with Web Content

The full pipeline that powers the Pronto Help Agent:

```
Pronto FAQ Website → Web Connector (sitemap crawl) → Data Lake Object
    → Auto-chunking → Search Index → Prompt Template → Agentforce Agent
```

### Web Connector Setup

1. Create a Web Connector connection pointing to the sitemap:
   `https://pronto-help-center-327a6109e2e3.herokuapp.com/sitemap.xml`
2. Configure a Data Lake Object with page filter (`.*\.html`) and content selector
3. Deploy the Data Stream — the crawler ingests all FAQ pages
4. Create a Search Index — the platform chunks and vectorizes automatically

### The Agent

The **Pronto Help Agent** answers customer questions grounded in crawled FAQ content. Example:

> "I'm a Pronto+ member. My order was missing two items and arrived 40 minutes late. What can I get back?"

The agent retrieves chunks from multiple FAQ sections (refunds, delivery, Pronto+) and synthesizes a personalized answer.

---

## Prerequisites

- Salesforce org with Data Cloud (Data 360) enabled
- Agentforce enabled
- Salesforce CLI (`sf`) installed
- Node.js 18+ (for the FAQ website)

## Getting Started

### 1. Clone and deploy metadata

```bash
git clone https://github.com/msrivastav13/Dreamin-in-data.git
cd Dreamin-in-data
sf org login web -a my-org
sf project deploy start
```

### 2. Set up demo data

```bash
# Insert merchant application records
sf apex run -f scripts/apex/insert-merchant-applications.apex

# Attach sample PDFs to the records
sf apex run -f scripts/apex/setup-merchant-applications-with-files.apex
```

### 3. Run the FAQ website locally

```bash
cd website
npm install
npm start
# Opens at http://localhost:3000
```

---

## Resources

- [Data 360 Documentation](https://help.salesforce.com/s/articleView?id=sf.c360_a_data_cloud.htm)
- [Document AI API Reference](https://developer.salesforce.com/docs/data/connectapi/references/spec?meta=extractDocumentAIConfigData)
- [Agentforce Developer Guide](https://developer.salesforce.com/docs/einstein/genai/guide/agentforce.html)
- [Web Connector Setup Guide](https://help.salesforce.com/s/articleView?id=sf.c360_a_web_connector.htm)

---

## License

This project is provided as demo material for educational purposes at Data Dreamin' 2026.
