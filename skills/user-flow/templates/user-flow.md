# User Flow: <feature / user goal>

## Overview
- **User goal**: What the user is trying to accomplish
- **Primary persona**: Who is the typical user for this flow
- **Entry points**: How users arrive at this flow

## Flow diagram (text)
```
[Entry Point] → [Step 1] → [Decision?] → Yes → [Step 2a] → [Success]
                                        → No  → [Step 2b] → [Alternate path]
                           → [Error]    → [Recovery] → [Retry Step 1]
```

## Detailed steps

### Step 1: <action>
- **User sees**: What's on screen
- **User does**: What action they take
- **System responds**: What happens next
- **States**:
  - Loading:
  - Empty:
  - Error:
  - Success:
- **Edge cases**:
  - ...
- **Accessibility notes**:
  - ...

### Step 2: <action>
_(repeat structure)_

## Decision points
| Decision | Info user needs | Default | Undo possible? |
| --- | --- | --- | --- |
| ... | ... | ... | ... |

## Error states and recovery
| Error | User sees | Recovery path | Data preserved? |
| --- | --- | --- | --- |
| Network failure | ... | Retry button, draft saved | Yes |
| Permission denied | ... | ... | ... |
| Validation error | ... | Inline errors, fix and resubmit | Yes |
| Session expired | ... | ... | ... |

## Edge cases
- Concurrent edits:
- Slow connection:
- Interrupted flow (user leaves and returns):
- Deep link entry (skipping earlier steps):
- Permission changes mid-flow:

## Accessibility checklist
- [ ] All steps reachable via keyboard
- [ ] Screen reader announces state changes
- [ ] Error messages associated with form fields
- [ ] Focus management on step transitions
- [ ] Sufficient color contrast and non-color indicators

## Open questions
- ...
