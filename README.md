# gastown-me-and-my-crew

**Gas Town config preset: manual mode / crew-only.** Keeps the rig/crew/mail/beads
scaffolding; turns off the patrols that burn tokens in the background
(witness, deacon, doctor / compactor / checkpoint dogs, refinery patrol, main-branch
tests).

If you want Gas Town as a workbench instead of a 24/7 swarm, this is for you.

---

## Quick install — give this prompt to your local Claude Code

Open a Claude Code session in any directory (your home is fine) and paste:

> Install the `gastown-me-and-my-crew` preset for me.
>
> 1. Clone `https://github.com/wbern/gastown-me-and-my-crew` into `~/.gt-presets/gastown-me-and-my-crew` (create the parent dir if needed, `git pull` if it already exists).
> 2. Run `./install.sh` from that directory. The script backs up my existing `~/gt/settings/config.json` and `~/gt/mayor/daemon.json` to `.bak.<timestamp>` before overwriting, so it's safe.
> 3. Show me the diff between the backups and the new files so I can see what changed. (If I've already installed before, the script short-circuits and no new backups are made — that's fine, just say so.)
> 4. Tell me to run `gt down && gt up --restore` to apply.
>
> Stop and ask me before doing anything destructive — for example, if `gt` isn't installed, or if `~/gt` doesn't exist, or if the version check warns.

That's it. Claude will handle the clone, run the installer, surface the diff,
and tell you the restart command.

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

Left **on** (these are infrastructure, not autonomy — keep them):

- `heartbeat` — daemon liveness
- `dolt_backup` — backs up the Dolt data plane (beads, mail, identity)
- `jsonl_git_backup` — backs up the JSONL logs to git
- `handler` — handles inbound events
- `wisp_reaper` — reaps stale tmux wisps
- `scheduled_maintenance` — nightly Dolt maintenance window

`stuck-agent-dog` is also listed in `disabled_patrols` at the town level —
it's the same idea (don't auto-wake on idle).

---

## Prerequisites

- macOS or Linux (the install script is `bash`)
- A working Gas Town install — see https://github.com/steveyegge/gastown
- `~/gt` populated by a prior `gt up` (so the script has files to back up)

**Known-good `gt` version:** any `v1.0.1-*` (tested on `v1.0.1-4-g91350080`).
The installer will warn — not block — on other versions. The schema can drift;
if a future `gt` rejects these files, file an issue.

---

## Manual install (no Claude needed)

```bash
git clone https://github.com/wbern/gastown-me-and-my-crew ~/.gt-presets/gastown-me-and-my-crew
cd ~/.gt-presets/gastown-me-and-my-crew
./install.sh
gt down && gt up --restore
```

To revert:

```bash
cd ~/.gt-presets/gastown-me-and-my-crew
./uninstall.sh
gt down && gt up --restore
```

`uninstall.sh` restores the most recent `.bak.<timestamp>` for each file. If
no backup exists (e.g. you deleted them), it leaves the current file alone
and warns.

---

## What's in `config/`

- `settings.config.json` → installed at `~/gt/settings/config.json`
- `mayor.daemon.json` → installed at `~/gt/mayor/daemon.json`

Both are sanitized — no rig names, no account handles. You can read them in
ten seconds.

---

## License

MIT. See [LICENSE](LICENSE).
