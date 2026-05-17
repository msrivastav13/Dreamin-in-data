# Data 360 — ContentDocumentLink Data Stream Failure Fix

## Symptom
Creating a Data Stream for `ContentDocumentLink` fails with a generic "retry" error that never resolves.

---

## Root Cause: Salesforce API Query Restriction

ContentDocumentLink has a platform-level query restriction — Salesforce requires ALL SOQL queries on this object to filter by a single Id on either `ContentDocumentId` or `LinkedEntityId` using `=` or `IN`.

Data Cloud's data stream creation tries to run a broader query, which results in a `400 BAD_REQUEST`:

> "Implementation restriction: ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator."

**This is why retries won't help** — the failure isn't transient, it's a query architecture mismatch.

---

## Fixes (in order of likelihood)

### 1. Add "Query Non-Vetoed Files" Permission (Most Common Fix)

This was the confirmed fix in multiple cases:

> "I added one missing permission 'Query Non Vetoed Files' and then stream started working"

**Location:** Setup > Permission Sets > Data Cloud Salesforce Connector > App Permissions > Content > "Query Non Vetoed Files"

### 2. Check Data Cloud Integration User Permissions

The Platform Integration User needs proper object-level access:
- Setup > Users > find the Data Cloud Integration User
- Verify it has the required app permissions and object access

### 3. Verify Salesforce Files Setting

Setup > Salesforce Files > General Settings > "Enable Files to be ingested into Data Cloud" must be checked.

### 4. Environment/Glue Table Issues

Backend provisioning issues sometimes show in Splunk logs as:
> "Unable to find glue params for table with name contentdocumentlink_home__dll"

This indicates a backend issue — may require Salesforce Support.

---

## Reference
- Salesforce Help Article 005227808 — dedicated KB article for this specific issue
- Slack community discussions confirm "Query Non-Vetoed Files" as the primary fix

---

## Key Takeaway for Demo Prep
If the ContentDocumentLink stream fails on retry, don't keep retrying. Go straight to the "Query Non-Vetoed Files" permission. This is a known platform limitation, not a transient error.
