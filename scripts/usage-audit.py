#!/usr/bin/env python3
"""Mine Claude Code usage: skill invocations, slash commands, user prompts, per-project activity."""
import json, os, glob, re, collections

ROOT = os.path.expanduser('~/.claude/projects')
SCRATCH = os.path.dirname(os.path.abspath(__file__))

skill_use = collections.Counter()
skill_by_proj = collections.defaultdict(collections.Counter)
cmd_use = collections.Counter()
agent_use = collections.Counter()
proj_stats = collections.defaultdict(lambda: {'sessions': 0, 'user_msgs': 0, 'first': None, 'last': None})
prompts = []

def note_ts(p, ts):
    if not ts:
        return
    st = proj_stats[p]
    if not st['first'] or ts < st['first']:
        st['first'] = ts
    if not st['last'] or ts > st['last']:
        st['last'] = ts

for f in glob.glob(ROOT + '/*/*.jsonl'):
    proj = os.path.basename(os.path.dirname(f))
    proj_stats[proj]['sessions'] += 1
    try:
        fh = open(f, 'r', errors='replace')
    except OSError:
        continue
    with fh:
        for line in fh:
            if len(line) > 3_000_000:
                continue
            try:
                rec = json.loads(line)
            except Exception:
                continue
            ts = rec.get('timestamp')
            t = rec.get('type')
            if t == 'assistant':
                msg = rec.get('message') or {}
                content = msg.get('content')
                if not isinstance(content, list):
                    continue
                for c in content:
                    if isinstance(c, dict) and c.get('type') == 'tool_use':
                        nm = c.get('name')
                        inp = c.get('input') or {}
                        if nm == 'Skill':
                            sk = inp.get('skill') or inp.get('command') or '?'
                            skill_use[sk] += 1
                            skill_by_proj[proj][sk] += 1
                            note_ts(proj, ts)
                        elif nm in ('Task', 'Agent'):
                            agent_use[inp.get('subagent_type') or 'general-purpose'] += 1
            elif t == 'user' and not rec.get('isSidechain'):
                msg = rec.get('message') or {}
                content = msg.get('content')
                text = None
                if isinstance(content, str):
                    text = content
                elif isinstance(content, list):
                    parts = [c.get('text', '') for c in content
                             if isinstance(c, dict) and c.get('type') == 'text']
                    text = '\n'.join(p for p in parts if p)
                if not text or not text.strip():
                    continue
                note_ts(proj, ts)
                m = re.search(r'<command-name>\s*(/?[\w.:_-]+)\s*</command-name>', text)
                if m:
                    cmd_use[m.group(1).lstrip('/')] += 1
                    continue
                if rec.get('isMeta'):
                    continue
                head = text[:80]
                if head.startswith('<') and any(k in head for k in
                        ('system-reminder', 'local-command', 'command-name', 'task-notification', 'bash-')):
                    continue
                if 'Caveat: The messages below' in head:
                    continue
                proj_stats[proj]['user_msgs'] += 1
                prompts.append({'p': proj, 'ts': ts, 't': text[:1500]})

# ---- history.jsonl: what the user actually TYPES ----
hist_cmds = collections.Counter()
hist_prompts = []
hp = os.path.expanduser('~/.claude/history.jsonl')
if os.path.exists(hp):
    with open(hp, 'r', errors='replace') as fh:
        for line in fh:
            try:
                rec = json.loads(line)
            except Exception:
                continue
            d = (rec.get('display') or '').strip()
            if not d:
                continue
            if d.startswith('/'):
                hist_cmds[d.split()[0]] += 1
            else:
                hist_prompts.append({'p': rec.get('project', '?'), 'ts': rec.get('timestamp'), 't': d[:1500]})

with open(os.path.join(SCRATCH, 'corpus_transcripts.jsonl'), 'w') as f:
    for p in prompts:
        f.write(json.dumps(p) + '\n')
with open(os.path.join(SCRATCH, 'corpus_history.jsonl'), 'w') as f:
    for p in hist_prompts:
        f.write(json.dumps(p) + '\n')

def fmt_ts(ts):
    return (ts or '?')[:10]

print('== PER-PROJECT ACTIVITY (sessions / user msgs / first..last) ==')
for p, st in sorted(proj_stats.items(), key=lambda kv: -kv[1]['user_msgs']):
    print(f"{st['sessions']:4d} sess {st['user_msgs']:5d} msgs  {fmt_ts(st['first'])}..{fmt_ts(st['last'])}  {p}")

print('\n== SKILL TOOL INVOCATIONS (all time, all projects) ==')
for s, n in skill_use.most_common(80):
    print(f'{n:5d}  {s}')

print('\n== SLASH COMMANDS SEEN IN TRANSCRIPTS ==')
for s, n in cmd_use.most_common(60):
    print(f'{n:5d}  {s}')

print('\n== SLASH COMMANDS TYPED (history.jsonl) ==')
for s, n in hist_cmds.most_common(60):
    print(f'{n:5d}  {s}')

print('\n== AGENT/TASK SUBAGENT TYPES ==')
for s, n in agent_use.most_common(30):
    print(f'{n:5d}  {s}')

print(f'\nTotal captured prompts: transcripts={len(prompts)} history={len(hist_prompts)}')
