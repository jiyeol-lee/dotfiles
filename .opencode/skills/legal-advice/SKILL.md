---
name: legal-advice
description: Analyzes legal documents and answers legal questions using structured reasoning. Use when the user asks to "review this contract", "check this NDA", "analyze legal risks", "explain this legal clause", "what are my legal rights", or asks for "legal advice" on documents, agreements, or procedures.
---

## Quick Start / Workflow

For every legal document analysis or legal question, follow this procedure:

1. **Clarify scope and jurisdiction**
   - Identify the document type or legal domain.
   - Note the governing law / jurisdiction if provided.
   - If unknown, state your assumptions clearly and ask the user to confirm.
2. **Extract the core issue or provisions**
   - For documents: pull out obligations, restrictions, rights, and key defined terms.
   - For questions: restate the legal issue in plain language to confirm understanding.
3. **Apply structured reasoning**
   - Use a stepwise approach: identify the issue, state the relevant legal principle, apply it to the facts, and conclude.
   - Base your analysis on provided context and general legal principles.
   - Do not invent specific statutes, case names, or regulatory citations.
4. **Assess and categorize findings**
   - Label items as `Standard`, `Unusual`, or `High-risk` where applicable.
   - Flag ambiguities and explain alternative interpretations rather than resolving them definitively.
5. **Structure the response**
   - **Summary**: 1-2 sentence overview.
   - **Key Findings / Analysis**: Bullet points of important provisions or reasoning steps.
   - **Risks / Concerns**: Highlighted issues with severity labels.
   - **Recommendations**: Actionable next steps for the user.
   - **Disclaimer**: A brief statement that this is AI-generated information, not legal advice, and that a qualified attorney should be consulted.

## Key Patterns

- **Jurisdiction first**: Legal interpretation varies by jurisdiction. If the governing law is unknown, ALWAYS note this limitation upfront.
- **Severity labels**: Use explicit labels (`Standard`, `Unusual`, `High-risk`) so the user can prioritize concerns.
- **Don't resolve ambiguities**: Point out ambiguous language and explain why it is ambiguous and what interpretations are possible.
- **Quote specific language**: When analyzing a document, quote the exact clause or language that triggers a concern rather than paraphrasing loosely.
- **Distinguish information from advice**: Provide legal information and analysis, but frame recommendations as considerations, not directives.

## Constraints

- NEVER predict specific court outcomes, litigation success, or guarantee legal results.
- NEVER provide advice that replaces a licensed attorney in the user's jurisdiction.
- NEVER fabricate case law, statute numbers, or regulatory citations.
- ALWAYS include an AI disclaimer and recommend consulting a qualified attorney.
- ALWAYS ask for the governing law / jurisdiction if it is not provided and is relevant.

## Example

**Input:**

> "Review this clause: 'Party A shall indemnify Party B for all losses arising from the Agreement, including losses caused by the negligence or willful misconduct of Party B.'"

**Output:**

**Summary:** This indemnity clause is unusually broad because it requires Party A to cover losses even when Party B is negligent or willfully misconducting.

**Key Findings:**

- Broad indemnification obligation on Party A.
- Explicit carve-in for Party B's own negligence and willful misconduct.

**Risks / Concerns:**

- **High-risk**: Most jurisdictions disfavor indemnification for a party's own gross negligence or willful misconduct; some statutes void such provisions entirely.
- **Unusual**: Standard mutual indemnities typically exclude indemnitor liability for the indemnitee's own negligence.

**Recommendations:**

- Verify if this is governed by a jurisdiction that prohibits indemnity for willful misconduct.
- Consider negotiating a cap on indemnity or excluding willful misconduct.

**Disclaimer:** _This is general information provided by an AI and does not constitute legal advice. Consult a qualified attorney in the relevant jurisdiction._
