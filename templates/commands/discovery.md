---
description: Generate a Discovery document to analyze product ideas and create foundation for subsequent spec-kit commands.
scripts:
  sh: scripts/bash/create-discovery.sh --json "{ARGS}"
  ps: scripts/powershell/create-discovery.ps1 -Json "{ARGS}"
---

The user input to you can be provided directly by the agent or as command arguments - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

**Important**: Parse the command arguments to extract key parameters:
- `--idea`: Product idea description (REQUIRED)
- `--problem`: Problem being solved (REQUIRED)
- `--audience`: Target audience (optional)
- `--domain`: Domain/industry (optional)
- `--competitors`: Comma-separated list of competitors (optional)
- `--constraints`: Technical/business constraints (optional)
- `--auto-specify`: Auto-run /specify after discovery (optional flag)

If required parameters are missing, ask the user to provide them before proceeding.

Given the parsed parameters, do this:

1. Run the script `{SCRIPT}` from repo root and parse its JSON output for DISCOVERY_DIR and DISCOVERY_FILE. All file paths must be absolute.
   **IMPORTANT** You must only ever run this script once. The JSON is provided in the terminal as output - always refer to it to get the actual content you're looking for.

2. Load `templates/discovery-template.md` to understand the required document structure.

3. Generate a comprehensive Discovery document using the template structure, filling in all sections based on the provided parameters and AI analysis:
   - Executive Summary: Synthesize problem, solution hypothesis, and value proposition
   - Problem Definition: Deep dive into the core problem, affected users, and impact
   - Target Users: Create primary persona and user journey mapping
   - Solution Scope: Define MVP features, future considerations, and out-of-scope items
   - Competitive Landscape: Analyze competitors and define unique value proposition
   - Success Metrics: Set North Star metric and supporting KPIs
   - Key Assumptions & Risks: Identify critical assumptions and primary risks
   - Technical Considerations: Suggest architecture and integration points
   - Next Steps: Validate readiness for `/specify` and recommend refinements

4. Write the generated Discovery document to DISCOVERY_FILE using the template structure.

5. If `--auto-specify` flag is present, automatically run `/specify` command with the generated discovery context.

6. Report completion with discovery file path, validation results, and next steps.

**Context Integration**:
- If `memory/constitution.md` exists, ensure discovery aligns with established project principles
- Save key context to `.specify/discovery/context.json` for use by subsequent commands
- Generate validation report showing document quality and readiness scores

**Output Quality Requirements**:
- Each section must be specific and actionable
- Focus on MVP scope (3-5 must-have features)
- Include measurable success metrics
- Identify key risks and assumptions to validate
- Maintain concise but complete documentation

Note: The script creates the discovery directory structure and initializes files before AI generation.