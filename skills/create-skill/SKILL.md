---
name: create-skill
description: Create a new generic skill (works on both claude and codex). By default creates in the current project's .agents/skills folder. Use "global skill" to create in ~/.agents/skills.
---

# Create Skill

Create new skills for Claude Code to automate repetitive tasks.

## Skill Locations

| Type              | Location                           | When to Use                                            |
| ----------------- | ---------------------------------- | ------------------------------------------------------ |
| **Project skill** | `.agents/skills/{name}/SKILL.md`   | Default. Project-specific workflows                    |
| **Global skill**  | `~/.agents/skills/{name}/SKILL.md` | When user says "global skill". Cross-project utilities |

## Instructions

### 1. Determine Skill Type

- **Default:** Create in project folder `.agents/skills/`
- **Global:** Only if user explicitly says "global skill", create in `~/.agents/skills/`

### 2. Create Skill Structure

```bash
# Project skill
mkdir -p .agents/skills/{skill-name}

# Global skill
mkdir -p ~/.agents/skills/{skill-name}
```

### 3. For Global Skills Only

After creating a global skill, ask the user:

> "Would you like me to commit this skill to the global agents repo?"

## Skill Best Practices

1. **Name:** Use kebab-case (e.g., `merge-events`, `db-migration`)
2. **Description:** Be specific about when to use the skill
