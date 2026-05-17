# Pronto Demo Overview

## What is Pronto
Pronto is a fictional food delivery platform (like DoorDash/Uber Eats) used to demonstrate Data 360 capabilities.

## Demo Capabilities Being Shown
1. **Intelligent Context** — grounding Agentforce agents with unstructured FAQ data crawled from the web
2. **Document AI** — (TBD)

## Architecture

### FAQ Website
- Deployed to Heroku: `https://pronto-help-center-327a6109e2e3.herokuapp.com/`
- 5 pages: Home, Ordering, Delivery, Merchants, Account & Payments
- ~50+ FAQ entries covering all aspects of the platform
- Styled after Uber Eats / DoorDash help centers (card-based, accordion FAQs)
- Node.js/Express serving static HTML from `website/public/`

### Data 360 Pipeline
- Web Connector uses sitemap.xml to discover pages
- Data Lake Object: `Pronto_Help_Center_FAQs`
- Automatic chunking and Search Index creation
- Intelligent Context available for tuning (optional)

## Best Demo Business Case: Customer Support Agent
A customer asks a compound question like:
> "I'm a Pronto+ member. My order was missing two items and arrived 40 minutes late. What can I get back?"

The agent retrieves chunks from multiple FAQ sections (refunds, delivery, Pronto+) and synthesizes a single personalized answer — demonstrating multi-chunk retrieval and intelligent grounding.

## Project Structure
```
Dreamin-in-data/
├── force-app/          # Salesforce DX metadata (agents, flows, etc.)
├── website/            # Pronto FAQ site (deployed to Heroku)
│   ├── public/         # Static HTML/CSS/JS
│   ├── data/           # Sample data files
│   ├── server.js       # Express server
│   └── package.json
└── knowledge/          # What we've learned (this folder)
```
