# gastown-me-and-my-crew

**Gas Town config preset: manual mode / crew-only.** Keeps the rig/crew/mail/beads
scaffolding; turns off the patrols that burn tokens in the background
(witness, deacon, doctor / compactor / checkpoint dogs, refinery patrol, main-branch
tests).

If you want Gas Town as a workbench instead of a 24/7 swarm, this is for you.

The whole thing is two JSON files and a recipe. There is no installer.

---

## Install — give this prompt to your local Claude Code

Open a Claude Code session anywhere and paste:

> Install the `gastown-me-and-my-crew` preset for me.
>
> 1. Clone `https://github.com/wbern/gastown-me-and-my-crew` to `~/.gt-presets/gastown-me-and-my-crew` (`git pull` if it already exists).
> 2. Run `gt version`. If it isn't `v1.0.1-*`, tell me before going further — I'll decide whether to proceed.
> 3. Diff `~/gt/settings/config.json` against `config/settings.config.json`, and `~/gt/mayor/daemon.json` against `config/mayor.daemon.json`. Show me both diffs.
> 4. If I approve, copy each destination file to `<dest>.bak.$(date +%Y%m%d-%H%M%S)` first, then overwrite with the preset version.
> 5. Tell me to run `gt down && gt up --restore` to apply.
>
> Stop and ask before doing anything destructive.

Claude does the clone, the version check, the diff, the timestamped backup,
and the copy — pausing for your approval at the diff step.

---

## Install — manually (four commands)

```bash
git clone https://github.com/wbern/gastown-me-and-my-crew ~/.gt-presets/gmamc
diff ~/gt/settings/config.json ~/.gt-presets/gmamc/config/settings.config.json
diff ~/gt/mayor/daemon.json    ~/.gt-presets/gmamc/config/mayor.daemon.json
# Happy with the diffs? Back up + copy each, then: gt down && gt up --restore
```

Backup + copy for completeness:

```bash
TS=$(date +%Y%m%d-%H%M%S)
cp ~/gt/settings/config.json ~/gt/settings/config.json.bak.$TS
cp ~/gt/mayor/daemon.json    ~/gt/mayor/daemon.json.bak.$TS
cp ~/.gt-presets/gmamc/config/settings.config.json ~/gt/settings/config.json
cp ~/.gt-presets/gmamc/config/mayor.daemon.json    ~/gt/mayor/daemon.json
gt down && gt up --restore
```

---

## What it disables (and why)

All of these are flipped from the Gas Town defaults to `"enabled": false`:

| Patrol             | Default behaviour                                        | Why off |
|--------------------|----------------------------------------------------------|---------|
| `witness`          | Wakes per-rig agents on a timer to audit polecat/crew    | Tokens; you can audit on demand |
| `deacon`           | Wakes the Deacon on a timer to run housekeeping          | Tokens; trigger manually if needed |
| `doctor_dog`       | Periodic health checks that can spawn the Doctor         | Tokens; `gt doctor` works on demand |
| `compactor_dog`    | Periodic context-compaction sweeps                       | Tokens; trigger from inside a session |
| `checkpoint_dog`   | Periodic checkpoint snapshots                            | Tokens; not needed for manual mode |
| `refinery`         | Wakes Refinery agents to push merge-request beads forward| Tokens; finish PRs by hand |
| `main_branch_test` | Periodic main-branch test runs                           | Tokens + CI noise |

Left **on** (infrastructure, not autonomy — keep them):

- `heartbeat` — daemon liveness
- `dolt_backup` — backs up the Dolt data plane (beads, mail, identity)
- `jsonl_git_backup` — backs up the JSONL logs to git
- `handler` — handles inbound events
- `wisp_reaper` — reaps stale tmux wisps
- `scheduled_maintenance` — nightly Dolt maintenance window

`stuck-agent-dog` is also listed in `disabled_patrols` at the town level —
same idea (don't auto-wake on idle).

---

## Prerequisites

- A working Gas Town install — see https://github.com/steveyegge/gastown
- `~/gt` populated by a prior `gt up` (so there's something to diff against)

**Known-good `gt` version:** any `v1.0.1-*` (tested on `v1.0.1-4-g91350080`).
Schemas can drift on either side of that range; if a future `gt` rejects these
files, file an issue.

---

## What's in `config/`

- `settings.config.json` → `~/gt/settings/config.json`
- `mayor.daemon.json` → `~/gt/mayor/daemon.json`

Both are sanitized — no rig names, no account handles. You can read them in
ten seconds.

---

## Uninstall

Restore the most recent `.bak.<timestamp>` next to each file, or
`git checkout` if you keep `~/gt` under version control. Then
`gt down && gt up --restore`.

---

## License

MIT. See [LICENSE](LICENSE).
