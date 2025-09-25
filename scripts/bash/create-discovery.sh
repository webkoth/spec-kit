#!/usr/bin/env bash

set -e

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
ARGS=()

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h)
            echo "Usage: $0 [--json] --idea '<idea>' --problem '<problem>' [options]"
            echo "Options:"
            echo "  --idea <text>         Product idea description (required)"
            echo "  --problem <text>      Problem being solved (required)"
            echo "  --audience <text>     Target audience (optional)"
            echo "  --domain <text>       Domain/industry (optional)"
            echo "  --competitors <list>  Comma-separated competitors (optional)"
            echo "  --constraints <text>  Technical/business constraints (optional)"
            echo "  --auto-specify        Auto-run /specify after discovery (optional)"
            exit 0
            ;;
        *) ARGS+=("$arg") ;;
    esac
done

# Join all arguments back into a single string for parsing
FULL_ARGS="${ARGS[*]}"

if [ -z "$FULL_ARGS" ]; then
    echo "Usage: $0 [--json] --idea '<idea>' --problem '<problem>' [options]" >&2
    exit 1
fi

# Function to find the repository root by searching for existing project markers
find_repo_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -d "$dir/.specify" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Resolve repository root
if git rev-parse --show-toplevel >/dev/null 2>&1; then
    REPO_ROOT=$(git rev-parse --show-toplevel)
    HAS_GIT=true
else
    REPO_ROOT="$(find_repo_root "$SCRIPT_DIR")"
    if [ -z "$REPO_ROOT" ]; then
        echo "Error: Could not determine repository root. Please run this script from within the repository." >&2
        exit 1
    fi
    HAS_GIT=false
fi

# Extract project name from repository
PROJECT_NAME=$(basename "$REPO_ROOT")

# Create timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S UTC')

# Function to parse command line arguments
parse_discovery_args() {
    local args=("$@")

    # Initialize variables
    local idea=""
    local problem=""
    local audience=""
    local domain=""
    local competitors=""
    local constraints=""
    local auto_specify=false

    # Parse arguments
    local i=0
    while [ $i -lt ${#args[@]} ]; do
        case "${args[$i]}" in
            --idea)
                i=$((i + 1))
                idea="${args[$i]}"
                ;;
            --problem)
                i=$((i + 1))
                problem="${args[$i]}"
                ;;
            --audience)
                i=$((i + 1))
                audience="${args[$i]}"
                ;;
            --domain)
                i=$((i + 1))
                domain="${args[$i]}"
                ;;
            --competitors)
                i=$((i + 1))
                competitors="${args[$i]}"
                ;;
            --constraints)
                i=$((i + 1))
                constraints="${args[$i]}"
                ;;
            --auto-specify)
                auto_specify=true
                ;;
        esac
        i=$((i + 1))
    done

    # Validate required parameters
    if [ -z "$idea" ] || [ -z "$problem" ]; then
        if [ "$JSON_MODE" = true ]; then
            echo '{"error": "Missing required parameters", "required": ["--idea", "--problem"], "provided_idea": "'"$idea"'", "provided_problem": "'"$problem"'"}'
        else
            echo "Error: Missing required parameters --idea and --problem" >&2
            echo "Usage: $0 --idea '<idea>' --problem '<problem>' [options]" >&2
        fi
        exit 1
    fi

    # Export parsed values
    export DISCOVERY_IDEA="$idea"
    export DISCOVERY_PROBLEM="$problem"
    export DISCOVERY_AUDIENCE="$audience"
    export DISCOVERY_DOMAIN="$domain"
    export DISCOVERY_COMPETITORS="$competitors"
    export DISCOVERY_CONSTRAINTS="$constraints"
    export DISCOVERY_AUTO_SPECIFY="$auto_specify"
}

# Parse the arguments
parse_discovery_args "${ARGS[@]}"

# Create discovery directory structure
DISCOVERY_DIR="$REPO_ROOT/.specify/discovery"
mkdir -p "$DISCOVERY_DIR"

# Generate discovery file name with timestamp
DISCOVERY_TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
DISCOVERY_FILE="$DISCOVERY_DIR/discovery_${DISCOVERY_TIMESTAMP}.md"

# Create context directory
CONTEXT_DIR="$DISCOVERY_DIR"
mkdir -p "$CONTEXT_DIR"

# Generate context JSON
CONTEXT_FILE="$CONTEXT_DIR/context.json"
cat > "$CONTEXT_FILE" << EOF
{
  "discovery": {
    "timestamp": "$TIMESTAMP",
    "project_name": "$PROJECT_NAME",
    "parameters": {
      "idea": "$DISCOVERY_IDEA",
      "problem": "$DISCOVERY_PROBLEM",
      "audience": "$DISCOVERY_AUDIENCE",
      "domain": "$DISCOVERY_DOMAIN",
      "competitors": "$DISCOVERY_COMPETITORS",
      "constraints": "$DISCOVERY_CONSTRAINTS",
      "auto_specify": $DISCOVERY_AUTO_SPECIFY
    },
    "files": {
      "discovery_document": "$DISCOVERY_FILE",
      "context_file": "$CONTEXT_FILE"
    },
    "validation": {
      "required_sections": [
        "Executive Summary",
        "Problem Definition",
        "Target Users",
        "Solution Scope",
        "Competitive Landscape",
        "Success Metrics",
        "Key Assumptions & Risks",
        "Technical Considerations",
        "Next Steps"
      ],
      "quality_thresholds": {
        "min_content_length": 1000,
        "min_mvp_features": 3,
        "required_metrics": ["north_star", "adoption", "engagement"]
      }
    }
  }
}
EOF

# Initialize discovery document with basic structure
cat > "$DISCOVERY_FILE" << EOF
# Discovery: $PROJECT_NAME

*Generated: $TIMESTAMP | Version: 1.0.0*

## Executive Summary

[AI will generate comprehensive executive summary]

## 1. Problem Definition

### Core Problem
**What:** [AI will define the core problem]
**Who:** [AI will identify who experiences this problem]
**Why:** [AI will explain why this is important]
**Impact:** [AI will assess the impact scale]

### Solution Hypothesis
> "We believe that **[AI will define solution]** for **[AI will define target audience]** will achieve **[AI will define expected result]**.
> We'll know this is true when **[AI will define success metric]**."

## 2. Target Users

### Primary Persona: [AI will create persona name]
- **Role:** [AI will define role]
- **Context:** [AI will define work context]
- **Primary Goal:** [AI will define primary goal]
- **Key Pain Point:** [AI will identify main pain point]
- **JTBD:** [AI will define job-to-be-done]

### User Journey (Current vs Desired)
| Stage | Current State | Desired State | Opportunity |
|-------|--------------|---------------|-------------|
| Discovery | [AI will fill] | [AI will fill] | [AI will fill] |
| Onboarding | [AI will fill] | [AI will fill] | [AI will fill] |
| Daily Use | [AI will fill] | [AI will fill] | [AI will fill] |

## 3. Solution Scope

### MVP Features (Must Have)
[AI will generate 3-5 must-have features with rationale]

### Future Considerations (Nice to Have)
[AI will identify future features with potential value]

### Out of Scope
[AI will define what is NOT being built and why]

## 4. Competitive Landscape

### Key Differentiators
[AI will analyze competitor landscape if competitors provided]

### Unique Value Proposition
**[AI will define unique value proposition]**

## 5. Success Metrics

### North Star Metric
- **Metric:** [AI will define primary metric]
- **Baseline:** [AI will estimate current state]
- **Target (3mo):** [AI will set target]

### Supporting KPIs
- **Adoption:** [AI will define adoption metric]
- **Engagement:** [AI will define engagement metric]
- **Satisfaction:** [AI will define satisfaction metric]

## 6. Key Assumptions & Risks

### Critical Assumptions
[AI will identify key assumptions and validation methods]

### Primary Risks
[AI will identify risks with impact assessment and mitigation strategies]

## 7. Technical Considerations

### Suggested Architecture
- **Type:** [AI will suggest architecture type]
- **Scale:** [AI will estimate expected load]
- **Key Requirements:** [AI will identify key technical requirements]

### Integration Points
[AI will identify necessary integrations]

## Next Steps

### Ready for \`/specify\`
[AI will create readiness checklist]

### Recommended Refinements
[AI will suggest areas for further refinement]

---
*Use \`/specify\` to create detailed feature specifications based on this discovery document*

## Document Metadata

**Generated Parameters:**
- Idea: $DISCOVERY_IDEA
- Problem: $DISCOVERY_PROBLEM
- Audience: ${DISCOVERY_AUDIENCE:-"Not specified"}
- Domain: ${DISCOVERY_DOMAIN:-"Not specified"}
- Competitors: ${DISCOVERY_COMPETITORS:-"Not specified"}
- Constraints: ${DISCOVERY_CONSTRAINTS:-"Not specified"}

**Quality Scores:**
- Clarity: [AI will score]/100
- Completeness: [AI will score]/100
- Actionability: [AI will score]/100

**Validation Status:** [AI will validate]
EOF

# Output JSON for the AI agent
if [ "$JSON_MODE" = true ]; then
    echo "{
        \"status\": \"success\",
        \"discovery_dir\": \"$DISCOVERY_DIR\",
        \"discovery_file\": \"$DISCOVERY_FILE\",
        \"context_file\": \"$CONTEXT_FILE\",
        \"project_name\": \"$PROJECT_NAME\",
        \"timestamp\": \"$TIMESTAMP\",
        \"parameters\": {
            \"idea\": \"$DISCOVERY_IDEA\",
            \"problem\": \"$DISCOVERY_PROBLEM\",
            \"audience\": \"$DISCOVERY_AUDIENCE\",
            \"domain\": \"$DISCOVERY_DOMAIN\",
            \"competitors\": \"$DISCOVERY_COMPETITORS\",
            \"constraints\": \"$DISCOVERY_CONSTRAINTS\",
            \"auto_specify\": $DISCOVERY_AUTO_SPECIFY
        },
        \"next_steps\": [
            \"AI should now generate comprehensive discovery document content\",
            \"Fill in all template placeholders with specific analysis\",
            \"Validate document quality and completeness\",
            \"Report completion with validation results\"
        ]
    }"
else
    echo "Discovery environment prepared successfully!"
    echo "Discovery directory: $DISCOVERY_DIR"
    echo "Discovery file: $DISCOVERY_FILE"
    echo "Context file: $CONTEXT_FILE"
    echo ""
    echo "Parameters:"
    echo "  Idea: $DISCOVERY_IDEA"
    echo "  Problem: $DISCOVERY_PROBLEM"
    echo "  Audience: ${DISCOVERY_AUDIENCE:-"Not specified"}"
    echo "  Domain: ${DISCOVERY_DOMAIN:-"Not specified"}"
    echo "  Competitors: ${DISCOVERY_COMPETITORS:-"Not specified"}"
    echo "  Constraints: ${DISCOVERY_CONSTRAINTS:-"Not specified"}"
    echo "  Auto-specify: $DISCOVERY_AUTO_SPECIFY"
fi