# Integrations

Last updated: 2026-09-02
Owner: Partnerships

## Available today

HRIS and payroll: Personio, BambooHR, HiBob, Workday (hire export only, one direction)
Calendar: Google Calendar, Microsoft 365
Communication: Slack, Microsoft Teams
Assessment: TestGorilla, HackerRank
Background checks: Certn, Zinc
Identity: Okta, Microsoft Entra ID, Google Workspace SSO
Job boards: Indeed, StepStone, LinkedIn Jobs, Xing, Homerun, and 40 regional boards

## API

REST API available on Growth and Enterprise. Rate limit is 200 requests per minute on Growth, 1,000 on Enterprise. Webhooks fire on candidate created, stage changed, offer accepted, and requisition approved.

API documentation is public at docs.hirelane.example.

## Integration limits by plan

Core: no integrations except job boards and the career page.
Growth: up to 5 active integrations.
Enterprise: unlimited.

An integration counts as active if it has synced in the last 30 days.

## Not available

There is no native integration with SAP SuccessFactors, Oracle HCM, or Sage. These can be built against the API but are not supported out of the box.

Dutch payroll providers are not currently integrated. Customers in the Netherlands export hires as CSV.
