#!/usr/bin/env python3
"""Smoke tests for the garage hooks. Run after any pattern change:

    python3 hooks/test_hooks.py

Each case pipes a real PreToolUse payload through the hook and asserts the
block/warn decision. Keep should-block and should-pass cases paired.
"""
import json
import os
import subprocess
import sys

HOOKS = os.path.dirname(os.path.abspath(__file__))


def bash_case(cmd, expect_block):
    payload = json.dumps({"tool_input": {"command": cmd}})
    r = subprocess.run([sys.executable, os.path.join(HOOKS, 'pre-bash.py')],
                       input=payload, capture_output=True, text=True)
    blocked = r.returncode == 2
    ok = blocked == expect_block
    print(f"{'OK ' if ok else 'FAIL'} rc={r.returncode} expect_block={expect_block} :: {cmd}")
    return ok


def guard_case(path, expect_warn):
    payload = json.dumps({"tool_input": {"file_path": path}})
    r = subprocess.run([sys.executable, os.path.join(HOOKS, 'pre-edit-guard.py')],
                       input=payload, capture_output=True, text=True)
    warned = 'systemMessage' in r.stdout
    ok = warned == expect_warn and r.returncode == 0
    print(f"{'OK ' if ok else 'FAIL'} warn={warned} expect={expect_warn} rc={r.returncode} :: {path}")
    return ok


results = []
fork_bomb = ':(){ :|:& };:'
dd_device = 'dd if=/dev/zero of=' + '/dev/s' + 'da'
results += [
    # must block
    bash_case(fork_bomb, True),
    bash_case('rm -rf ~/', True),
    bash_case('git push origin main --force', True),
    bash_case('TRUNCATE TABLE public.users', True),
    bash_case('docker volume prune -f', True),
    bash_case(dd_device, True),
    bash_case('DROP SCHEMA IF EXISTS ledger CASCADE', True),
    bash_case("git commit -m 'safe note' && docker volume prune -f", True),
    # must pass
    bash_case('ls -la', False),
    bash_case('dd if=/dev/zero of=testfile bs=1M count=1', False),
    bash_case('git push --force-with-lease origin main', False),
    bash_case('git push -f origin feature-x', False),
    bash_case("git commit -m 'hooks: docker volume prune and TRUNCATE TABLE notes'", False),
]
results += [
    # must warn
    guard_case('/x/application-prod.properties', True),
    guard_case('/x/.env', True),
    guard_case('/x/secrets.yaml', True),
    # must stay silent
    guard_case('/x/.env.example', False),
    guard_case('/x/app.environment.ts', False),
    guard_case('/x/id_rsa.pub', False),
]

print(f"\n{sum(results)}/{len(results)} hook smoke tests passed")
sys.exit(0 if all(results) else 1)
