param(
    [switch]$Json,
    [switch]$Help,
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$Arguments
)

# Show help
if ($Help) {
    Write-Host "Usage: .\create-discovery.ps1 [-Json] -Arguments @('--idea', '<idea>', '--problem', '<problem>', [options])"
    Write-Host "Options:"
    Write-Host "  --idea <text>         Product idea description (required)"
    Write-Host "  --problem <text>      Problem being solved (required)"
    Write-Host "  --audience <text>     Target audience (optional)"
    Write-Host "  --domain <text>       Domain/industry (optional)"
    Write-Host "  --competitors <list>  Comma-separated competitors (optional)"
    Write-Host "  --constraints <text>  Technical/business constraints (optional)"
    Write-Host "  --auto-specify        Auto-run /specify after discovery (optional)"
    exit 0
}

# Combine arguments into single string
$FullArgs = $Arguments -join ' '

if (-not $FullArgs) {
    if ($Json) {
        @{
            error = "Missing arguments"
            usage = ".\create-discovery.ps1 [-Json] -Arguments @('--idea', '<idea>', '--problem', '<problem>', [options])"
        } | ConvertTo-Json
    } else {
        Write-Error "Usage: .\create-discovery.ps1 [-Json] -Arguments @('--idea', '<idea>', '--problem', '<problem>', [options])"
    }
    exit 1
}

# Function to find repository root
function Find-RepoRoot {
    param([string]$StartPath)

    $currentDir = $StartPath
    while ($currentDir -ne [System.IO.Path]::GetPathRoot($currentDir)) {
        if ((Test-Path (Join-Path $currentDir ".git")) -or (Test-Path (Join-Path $currentDir ".specify"))) {
            return $currentDir
        }
        $currentDir = Split-Path $currentDir -Parent
    }
    return $null
}

# Determine repository root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

try {
    $RepoRoot = git rev-parse --show-toplevel 2>$null
    $HasGit = $true
} catch {
    $RepoRoot = Find-RepoRoot $ScriptDir
    if (-not $RepoRoot) {
        if ($Json) {
            @{ error = "Could not determine repository root" } | ConvertTo-Json
        } else {
            Write-Error "Error: Could not determine repository root. Please run this script from within the repository."
        }
        exit 1
    }
    $HasGit = $false
}

# Get project name
$ProjectName = Split-Path $RepoRoot -Leaf

# Create timestamp
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"

# Function to parse discovery arguments
function Parse-DiscoveryArgs {
    param([string]$Args)

    $result = @{
        idea = ""
        problem = ""
        audience = ""
        domain = ""
        competitors = ""
        constraints = ""
        autoSpecify = $false
    }

    # Parse using regex patterns
    if ($Args -match "--idea\s+[`"'](.*?)[`"']") {
        $result.idea = $matches[1]
    } elseif ($Args -match "--idea\s+([^\s--]+)") {
        $result.idea = $matches[1]
    }

    if ($Args -match "--problem\s+[`"'](.*?)[`"']") {
        $result.problem = $matches[1]
    } elseif ($Args -match "--problem\s+([^\s--]+)") {
        $result.problem = $matches[1]
    }

    if ($Args -match "--audience\s+[`"'](.*?)[`"']") {
        $result.audience = $matches[1]
    } elseif ($Args -match "--audience\s+([^\s--]+)") {
        $result.audience = $matches[1]
    }

    if ($Args -match "--domain\s+[`"'](.*?)[`"']") {
        $result.domain = $matches[1]
    } elseif ($Args -match "--domain\s+([^\s--]+)") {
        $result.domain = $matches[1]
    }

    if ($Args -match "--competitors\s+[`"'](.*?)[`"']") {
        $result.competitors = $matches[1]
    } elseif ($Args -match "--competitors\s+([^\s--]+)") {
        $result.competitors = $matches[1]
    }

    if ($Args -match "--constraints\s+[`"'](.*?)[`"']") {
        $result.constraints = $matches[1]
    } elseif ($Args -match "--constraints\s+([^\s--]+)") {
        $result.constraints = $matches[1]
    }

    if ($Args -match "--auto-specify") {
        $result.autoSpecify = $true
    }

    return $result
}

# Parse arguments
$ParsedArgs = Parse-DiscoveryArgs $FullArgs

# Validate required parameters
if (-not $ParsedArgs.idea -or -not $ParsedArgs.problem) {
    if ($Json) {
        @{
            error = "Missing required parameters"
            required = @("--idea", "--problem")
            provided_idea = $ParsedArgs.idea
            provided_problem = $ParsedArgs.problem
        } | ConvertTo-Json
    } else {
        Write-Error "Error: Missing required parameters --idea and --problem"
        Write-Error "Usage: .\create-discovery.ps1 --idea '<idea>' --problem '<problem>' [options]"
    }
    exit 1
}

# Create discovery directory structure
$DiscoveryDir = Join-Path $RepoRoot ".specify" "discovery"
New-Item -ItemType Directory -Path $DiscoveryDir -Force | Out-Null

# Generate discovery file name with timestamp
$DiscoveryTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$DiscoveryFile = Join-Path $DiscoveryDir "discovery_$DiscoveryTimestamp.md"

# Create context directory
$ContextDir = $DiscoveryDir
New-Item -ItemType Directory -Path $ContextDir -Force | Out-Null

# Generate context JSON
$ContextFile = Join-Path $ContextDir "context.json"
$ContextData = @{
    discovery = @{
        timestamp = $Timestamp
        project_name = $ProjectName
        parameters = @{
            idea = $ParsedArgs.idea
            problem = $ParsedArgs.problem
            audience = $ParsedArgs.audience
            domain = $ParsedArgs.domain
            competitors = $ParsedArgs.competitors
            constraints = $ParsedArgs.constraints
            auto_specify = $ParsedArgs.autoSpecify
        }
        files = @{
            discovery_document = $DiscoveryFile
            context_file = $ContextFile
        }
        validation = @{
            required_sections = @(
                "Executive Summary",
                "Problem Definition",
                "Target Users",
                "Solution Scope",
                "Competitive Landscape",
                "Success Metrics",
                "Key Assumptions & Risks",
                "Technical Considerations",
                "Next Steps"
            )
            quality_thresholds = @{
                min_content_length = 1000
                min_mvp_features = 3
                required_metrics = @("north_star", "adoption", "engagement")
            }
        }
    }
}

$ContextData | ConvertTo-Json -Depth 10 | Out-File -FilePath $ContextFile -Encoding UTF8

# Initialize discovery document
$audienceText = if ($ParsedArgs.audience) { $ParsedArgs.audience } else { "Not specified" }
$domainText = if ($ParsedArgs.domain) { $ParsedArgs.domain } else { "Not specified" }
$competitorsText = if ($ParsedArgs.competitors) { $ParsedArgs.competitors } else { "Not specified" }
$constraintsText = if ($ParsedArgs.constraints) { $ParsedArgs.constraints } else { "Not specified" }

$DiscoveryContent = @"
# Discovery: $ProjectName

*Generated: $Timestamp | Version: 1.0.0*

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

### Ready for `/specify`
[AI will create readiness checklist]

### Recommended Refinements
[AI will suggest areas for further refinement]

---
*Use `/specify` to create detailed feature specifications based on this discovery document*

## Document Metadata

**Generated Parameters:**
- Idea: $($ParsedArgs.idea)
- Problem: $($ParsedArgs.problem)
- Audience: $audienceText
- Domain: $domainText
- Competitors: $competitorsText
- Constraints: $constraintsText

**Quality Scores:**
- Clarity: [AI will score]/100
- Completeness: [AI will score]/100
- Actionability: [AI will score]/100

**Validation Status:** [AI will validate]
"@

$DiscoveryContent | Out-File -FilePath $DiscoveryFile -Encoding UTF8

# Output result
if ($Json) {
    @{
        status = "success"
        discovery_dir = $DiscoveryDir
        discovery_file = $DiscoveryFile
        context_file = $ContextFile
        project_name = $ProjectName
        timestamp = $Timestamp
        parameters = @{
            idea = $ParsedArgs.idea
            problem = $ParsedArgs.problem
            audience = $ParsedArgs.audience
            domain = $ParsedArgs.domain
            competitors = $ParsedArgs.competitors
            constraints = $ParsedArgs.constraints
            auto_specify = $ParsedArgs.autoSpecify
        }
        next_steps = @(
            "AI should now generate comprehensive discovery document content",
            "Fill in all template placeholders with specific analysis",
            "Validate document quality and completeness",
            "Report completion with validation results"
        )
    } | ConvertTo-Json -Depth 10
} else {
    Write-Host "Discovery environment prepared successfully!"
    Write-Host "Discovery directory: $DiscoveryDir"
    Write-Host "Discovery file: $DiscoveryFile"
    Write-Host "Context file: $ContextFile"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  Idea: $($ParsedArgs.idea)"
    Write-Host "  Problem: $($ParsedArgs.problem)"
    Write-Host "  Audience: $audienceText"
    Write-Host "  Domain: $domainText"
    Write-Host "  Competitors: $competitorsText"
    Write-Host "  Constraints: $constraintsText"
    Write-Host "  Auto-specify: $($ParsedArgs.autoSpecify)"
}