# Onboarding Guide: <service / domain / team>

**Last updated**: <date>
**Owner**: <name>
**Review cadence**: Quarterly

## Welcome
- **What this team/service does**: One paragraph
- **Why it matters**: Business context
- **Your role**: What you'll be working on

## Day 1: Get set up

### Prerequisites
- [ ] Accounts and access: ...
- [ ] Tools to install: ...
- [ ] Repos to clone: ...

### Local development setup
1. Step:
   ```bash
   command
   ```
2. Step:
   ```bash
   command
   ```
3. Verify it works:
   ```bash
   command  # Expected output: ...
   ```

### Troubleshooting setup
| Problem | Solution |
| --- | --- |
| ... | ... |

## Week 1: Understand the system

### Architecture overview
- **Components**: What the major pieces are and how they connect
- **Data flow**: How data moves through the system
- **Key decisions**: Why things are built this way (link to ADRs)
- **Diagram**: <link or inline>

### Key codepaths to read
| What | Where | Why it matters |
| --- | --- | --- |
| Request handling | `src/...` | Core flow everything builds on |
| Data model | `src/models/...` | Understanding the schema |
| ... | ... | ... |

### Environments
| Environment | URL | Purpose | How to deploy |
| --- | --- | --- | --- |
| Local | localhost:... | Development | `npm run dev` |
| Staging | ... | Testing | ... |
| Production | ... | Users | ... |

## Month 1: Go deeper

### Domain concepts
| Term | What it means | Where it lives in code |
| --- | --- | --- |
| ... | ... | ... |

### Common patterns
- **How we handle X**: ...
- **Why we don't do Y**: ...
- **When to use Z vs W**: ...

### Things I wish I'd known earlier
- ...
- ...
- ...

### Historical context (tribal knowledge)
- Why <thing> is the way it is:
- What we tried before and why it didn't work:
- Plans for the future:

## People directory
| Area | Who to ask | Contact |
| --- | --- | --- |
| Architecture decisions | ... | ... |
| Frontend | ... | ... |
| Backend / API | ... | ... |
| Infrastructure / DevOps | ... | ... |
| Product questions | ... | ... |
| Emergency / on-call | ... | ... |

## Your first task
A guided exercise to make your first contribution:

1. **Goal**: <what you'll accomplish>
2. **Steps**:
   - ...
3. **Expected outcome**: <what success looks like>
4. **Submit**: Create a PR and tag <reviewer>

## Key resources
| Resource | Link | When to use it |
| --- | --- | --- |
| Design docs | ... | Understanding technical decisions |
| Runbooks | ... | Operational procedures |
| Dashboards | ... | Monitoring service health |
| Team channel | ... | Questions and discussions |
| Sprint board | ... | Current work and priorities |
