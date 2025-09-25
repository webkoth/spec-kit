# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Spec Kit is a toolkit for Spec-Driven Development (SDD) that provides templates, scripts, and workflows for structured software development. The main component is the Specify CLI (`specify-cli`), a Python-based command-line tool that bootstraps projects with the Spec Kit framework.

## Development Commands

### Installation and Setup
```bash
# Install the CLI tool directly from git
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Or run without installing
uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>
```

### Basic Usage
```bash
# Initialize a new project
specify init my-project --ai claude

# Initialize in current directory
specify init --here --ai claude

# Check installed tools
specify check
```

### Development Setup
```bash
# Install dependencies (Python 3.11+ required)
uv sync

# Run the CLI during development
python -m specify_cli init --help
```

## Code Architecture

### Core Structure
- `src/specify_cli/__init__.py` - Main CLI application using Typer
- `scripts/bash/` - Bash scripts for various operations
- `scripts/powershell/` - PowerShell equivalents for Windows
- `templates/` - Template files and command definitions
- `templates/commands/` - Slash command definitions for AI agents

### Key Components

#### CLI Application (`src/specify_cli/__init__.py`)
- Built with Typer for command-line interface
- Uses Rich for styled console output
- Supports multiple AI agents (Claude, Gemini, Copilot, Cursor, etc.)
- Downloads templates from GitHub releases
- Handles project initialization and tool checks

#### Template System
- `templates/spec-template.md` - Specification template structure
- `templates/plan-template.md` - Implementation plan template
- `templates/tasks-template.md` - Task breakdown template
- `templates/commands/` - Agent-specific slash command definitions

#### Script System
- Scripts handle feature creation, branch management, and project setup
- Dual support for bash and PowerShell environments
- Git integration for branch management and feature tracking

### AI Agent Integration
The system supports multiple AI coding assistants with agent-specific:
- Command file formats (Markdown for Claude, TOML for others)
- Directory structures (`.claude/commands/`, `.gemini/commands/`, etc.)
- Argument passing conventions (`$ARGUMENTS`, `{ARGS}`, etc.)

## Slash Commands Architecture

When projects are initialized, they get slash commands for structured development:
- `/discovery` - **NEW** Generate Discovery document from product ideas (entry point to pipeline)
- `/constitution` - Create project governing principles
- `/specify` - Define requirements and user stories
- `/clarify` - Clarify underspecified areas
- `/plan` - Create technical implementation plans
- `/tasks` - Generate actionable task lists
- `/analyze` - Cross-artifact consistency analysis
- `/implement` - Execute implementation

Each command maps to scripts in `scripts/bash/` or `scripts/powershell/` and uses templates from `templates/`.

### Discovery Command Details
The `/discovery` command is the new entry point for Spec-Driven Development:
- **Purpose**: Analyze product ideas and create structured foundation
- **Input**: `--idea`, `--problem` (required), plus optional parameters
- **Output**: Comprehensive Discovery document in `.specify/discovery/`
- **Integration**: Can auto-trigger `/specify` with `--auto-specify` flag

## Important Files to Update

### Version Changes
When modifying `src/specify_cli/__init__.py`:
1. Update version in `pyproject.toml`
2. Add entry to `CHANGELOG.md`

### Adding New Agent Support
1. Update `AI_CHOICES` constant in `__init__.py`
2. Add tool check logic if the agent has a CLI
3. Update agent folder security mappings
4. See `AGENTS.md` for detailed integration guide

## Development Guidelines

### Testing New Features
- Test both `--here` and new directory initialization
- Verify git integration works with and without existing repos
- Test across different AI agent selections
- Validate script permissions are set correctly on Unix systems

### Architecture Considerations
- The system is designed to work with or without git repositories
- Branch management is automatic when git is available
- Template extraction handles GitHub's nested ZIP structure
- Scripts must be cross-platform compatible (bash/PowerShell)

## Repository Context

This is a **fork** of the main Spec Kit repository (github/spec-kit). The fork setup:
- **Origin**: `git@github.com:webkoth/spec-kit.git` (your fork)
- **Upstream**: `https://github.com/github/spec-kit.git` (main repository)

### Fork Workflow

#### Syncing with Upstream
```bash
# Fetch latest changes from main repository
git fetch upstream

# Switch to main and update from upstream
git checkout main
git pull upstream main

# Push updated main to your fork
git push origin main
```

#### Creating Features for PR
```bash
# Create feature branch from updated main
git checkout -b feature/my-improvement

# Make your changes and commit
git add .
git commit -m "Add my improvement"

# Push to your fork
git push origin feature/my-improvement

# Create PR from webkoth:feature/my-improvement → github:main
```

#### Working on Local Improvements
```bash
# Create branches for local-only changes
git checkout -b local/my-custom-feature
```

### Branch Patterns
- **Feature branches for PRs**: `feature/descriptive-name`
- **Local improvements**: `local/descriptive-name`
- **Spec-driven features**: `001-feature-name`, `002-next-feature` (as per Spec Kit methodology)

### Development Context
- Feature specifications go in `specs/` directory with matching numbers
- The main branch is `main`
- Templates are released as GitHub release assets for different agent types
- Always sync with upstream before creating PR branches