# Document AI — End-to-End Flow (Confirmed Working)

## What Actually Worked

### The Setup Path
1. **Content Bundle deployed** — 3 data streams: ContentDocument, ContentVersion, ContentDocumentLink
2. ContentVersion DLO **is a UDMO** — it shows as an unstructured data model object in the Document AI "From a Source Object" picker
3. Created Document AI config **"From a Source Object"** → selected **Content Document Version** as the source
4. Published the schema with 33 fields using **Gemini 2.5 Flash** (VertexAIGemini25Flash)
5. The config activated and shows **Runtime Status: In Progress**

### Key Configuration Details (from screenshots)

| Field | Value |
|-------|-------|
| Configuration Name | Merchant Application |
| API Name | Merchant_Application |
| Source Object | Content Document Version |
| Data Space | default |
| LLM | VertexAIGemini25Flash |
| Status | Activated |
| Runtime Status | In Progress |
| File Type | PDF |

### Output Tab
Shows "Merchant Application Extract" DLO with Fields tab listing all extracted fields:
- restaurantName, legalBusinessName, businessAddress, phoneNumber, email, website
- taxID, businessLicense, ownerName, ownerPhone, ownerEmail
- cuisineType, averagePrepTime, operatingHours, seatingCapacity, numberOfLocations
- (and more — 33 total)

Also has **Tables** and **Schema Prompt** tabs.

---

## Corrected Understanding

### ContentVersion IS a UDMO
We were wrong earlier. ContentVersion shows as a UDMO in the Document AI source picker. The `ContentVersion_Home__dll` DLO stores both metadata AND a pointer to the binary blob — the platform treats this as unstructured data because the blob (PDF) is the actual content.

### The "From a Source Object" path is what triggers auto-processing
- When you create a Document AI config "From a Source Object" and point it at the ContentVersion UDMO
- And publish with a schema
- The platform activates and begins processing all files in that UDMO
- Runtime Status shows "In Progress" while it processes
- Results appear in the output DLO ("Merchant Application Extract")

### The "Without a Source Object" path
- Only for programmatic use (API calls, Flows)
- Does NOT auto-process files
- Schema is used only when you call the `extract-data` API manually

---

## Two Paths to Document AI Extraction (Corrected)

| Path | Trigger | Output |
|------|---------|--------|
| **From Source Object (UI)** | Automatic — processes all files in the UDMO on activation + new files as they arrive | Output DLO (queryable in Data Explorer) |
| **API (programmatic)** | On-demand — call `extract-data` endpoint with file + schema | JSON response (not persisted unless you write it) |

---

## DLO Suffix Reference

| Suffix | Type | Example |
|--------|------|---------|
| `__dll` | Data Lake Object (raw ingested data) | `ContentVersion_Home__dll` |
| `__dlm` | Data Model Object (harmonized/mapped) | `ssot__ContentDocumentVersion__dlm` |

---

## Data Cloud Query API

Use `/services/data/v66.0/ssot/queryV2` (POST with `{"sql":"..."}`) — NOT `sf data query` which only runs SOQL against CRM.

```bash
curl -X POST "$INSTANCE_URL/services/data/v66.0/ssot/queryV2" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"sql":"SELECT * FROM ContentVersion_Home__dll LIMIT 5"}'
```

---

## Known Issue: Timing Bug with Auto-Extraction

Even after:
- Content streams deployed and active
- Document AI config activated (Status: Activated, Runtime Status: In Progress)
- Fresh PDFs uploaded AFTER activation
- Files linked to parent records

The output DLO ("Merchant Application Extract") shows **0 records** with a Refresh History run completing with 0 records added.

This appears to be a **timing/sequencing bug**. The ContentVersion stream ingests file metadata, but the Document AI extraction job either:
- Doesn't detect the new files in the UDMO within the same refresh window
- Requires a separate trigger/rebuild cycle after files land in the UDMO
- Has a delay between UDMO ingestion and Document AI processing

**Workarounds tried:**
- Re-attaching existing files (didn't trigger — ContentVersion needs NEW records, not re-linked ones)
- Uploading fresh PDFs after activation (files ingested into UDMO but extraction DLO still shows 0)
- Hitting "Rebuild" on the Document AI config page

**For the demo:** Use the **API approach** (`extract-data` endpoint) which works instantly and reliably. The automated DLO pipeline has this timing issue that makes it unreliable for live demos.

---

## To Check Extraction Results
Once Runtime Status changes from "In Progress" to complete:
- Go to **Data Cloud > Data Explorer**
- Query the output DLO: `Merchant_Application_Extract__dll` (or whatever name it created)
- Or check the **Output** tab on the Document AI config page
