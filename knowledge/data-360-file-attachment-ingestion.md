# Data 360 — File Attachment Ingestion from Salesforce

## Overview
Ingest content documents (file attachments on standard/custom Salesforce objects) into Data 360. Data 360 chunks all relevant content and turns them into searchable vectors for generative AI, analytics, and automation apps.

---

## Required Permissions

| Permission | Location |
|-----------|----------|
| Data 360 Architect permission set | Permission Sets |
| Query Non Vetoed Files | Setup > Permission Sets > Data Cloud Salesforce Connector > App Permissions > Content |
| Enable Files ingestion | Setup > Salesforce Files > General Settings > Salesforce Files Settings > "Enable Files to be ingested into Data Cloud" |
| SSOT version 1.68+ | Setup > Installed Packages |
| Knowledge attachment ingestion | Setup > Permission Sets > Data Cloud Salesforce Connector > App Permissions > "Allow View Knowledge" |

**Tip:** If you can't locate the Content section, search "Manage Content Permission" in the search bar.

---

## How File Attachment Ingestion Works

Data 360 uses three Data Model Objects (DMOs):

| DMO | Purpose |
|-----|---------|
| **ContentDocument** | Document uploaded to a library in Salesforce CRM |
| **ContentVersion** | Specific version of a document in Salesforce CRM |
| **ContentDocumentLink** | Link to entities the file is shared with (users, groups, records, libraries) |

### Important Behavior Differences

> **ContentVersion data stream behaves differently from other CRM content objects.**
> - ContentDocument and ContentDocumentLink (structured data) ingest records across ALL file attachments during initial ingestion.
> - ContentVersion (unstructured file content) ingests ONLY file versions created or updated AFTER you create the data stream.
> - File attachment ingestion does NOT support full refresh or total replacement for ContentVersion.

---

## Ingestion Scenarios

| Scenario | Steps |
|----------|-------|
| **New setup (no existing ingestion)** | Create 3 content data streams: ContentDocument, ContentDocumentLink, ContentDocumentVersion. Then attach files — Data 360 auto-ingests them. |
| **Existing objects with file attachments** | Create the 3 data streams, then **re-attach** files to existing objects to trigger ingestion. |
| **Existing content data streams (pre-March 2025)** | Delete old streams, create 3 new ones. Then re-add or create new file attachments. |

---

## Setup Steps

### Step 1: Install the Content Bundle
- Deploys file attachment Data Lake Objects (DLO), Data Model Objects (DMO), and Data Streams
- After deployment, verify Data Lake Objects page shows: `ContentDocument`, `ContentVersion`, `ContentDocumentLink`

### Step 2: Upload Files in Salesforce CRM
- Attach files to a Salesforce object (e.g., `Merchant_Application__c`)
- In our case: 3 merchant application PDFs already linked via ContentDocumentLink

### Step 3: Create Object Data Stream
- After deploying content data streams, create a data stream to ingest the associated Salesforce object (e.g., `Merchant_Application__c`)
- Then create a vector search index configuration that includes file attachments

> **Note:** Even without an object-specific data stream, the ContentVersion DMO will still ingest file attachments from ALL Salesforce objects after the 3 content streams exist.

---

## Configure Object Relationships (Critical)

After creating the 3 data streams:

### 1. Disable default ContentDocument relationship
- Go to **Data Model** tab
- Search for **ContentDocument DMO** > Relationships
- If this relationship exists, **disable it**:

| Setting | Value |
|---------|-------|
| Object | ContentDocument |
| Field | ContentDocumentId |
| Related Object | ContentDocumentVersion |
| Related Field | ContentDocumentVersionId |

### 2. Create ContentDocumentRelationship → Your Object relationship
- In Data Model, search for **ContentDocumentRelationship DMO** > Relationships
- Ensure a relationship exists to your custom object DMO. If not, create it:

| Setting | Value |
|---------|-------|
| Object | ContentDocumentRelationship |
| Field | Related Item |
| Cardinality | ManyToOne |
| Related Object DMO | Merchant_Application__c DMO |
| Related Field | Primary key (Merchant Application Id) |

---

## For Our Pronto Demo

| Step | Action |
|------|--------|
| 1 | Enable file ingestion in Setup > Salesforce Files > General Settings |
| 2 | Assign "Query Non Vetoed Files" permission |
| 3 | Install/deploy the Content Bundle (creates 3 data streams) |
| 4 | Verify ContentDocument, ContentVersion, ContentDocumentLink DLOs appear |
| 5 | Re-attach PDFs to Merchant Application records (or re-upload) to trigger ingestion since ContentVersion only picks up NEW files after stream creation |
| 6 | Create Merchant_Application__c data stream |
| 7 | Configure relationships: ContentDocumentRelationship → Merchant_Application__c |
| 8 | Create Search Index with file attachments enabled |
| 9 | Connect Document AI schema (`Merchant_Application`) to the ContentVersion UDMO |

---

## Supported File Formats
See Salesforce docs: "Unstructured Data File Formats and Connectors" for full list. For our demo, PDF is supported.
