# Me and My Crew

![Me and My Crew](assets/crew.png)

*We ride in Gas Town. The dogs don't bark, the witnesses don't watch.*

---

[Gas Town](https://github.com/steveyegge/gastown) is an atmospheric way to
work with many Claude Code agents at once — rigs, crews, a Mayor you can talk
to, mail and nudges between agents, all wired through tmux. Out of the box
it's designed to run unattended: a swarm of background patrols keeps itself
coordinated while you sleep.

This repo is the config that turns it into a workbench instead. You keep all
the conveniences — Mayor, rigs, crew, comms — and turn off the patrols that
burn tokens watching nothing happen. **Manual mode / crew-only.**

The whole thing is two JSON files and a recipe. There is no installer.

---

## Why this exists

People keep asking how I actually work with agents. The honest answer is: I use
Gas Town, but with most of the autonomy turned off. This repo is that exact
config.

What I keep from Gas Town:

- **The Mayor.** Having one agent I can talk to about meta-tasks ("what's the
  crew up to?", "spin up a new rig for X") is a real workflow upgrade over
  juggling raw `claude` sessions.
- **The CLAUDE.md** that ships with `gt`. Solid baseline, didn't want to
  re-derive it.
- **Rigs and crew.** Multiple Claude Code sessions, each with its own identity
  and beads/mail, that I can switch between in a single keystroke.
- **Same branch, different working trees.** Two crew mates can work the same
  branch in parallel and each keeps their own dirty state — no stepping on
  each other.
- **Mail and nudges between agents.** Persistent mail when a message needs to
  survive a session restart, lightweight nudges when it doesn't. Coordinating
  two or three crew mates by hand would be miserable; this makes it
  effortless.
- **tmux, basically for free.** Gas Town wires up tmux around all of this. If
  you live in tmux already, it's one less thing to set up (and pairs nicely
  with [tmux-explode](https://github.com/wbern/tmux-explode) for fanning panes
  out).

What I turn off:

Gas Town ships a small army of background agents — witnesses, deacons, dogs,
refineries — that wake on timers to audit each other, escalate stuck work,
keep the swarm honest. That design made sense when models were weaker and the
target was "leave it running overnight, come back to merged PRs." Plenty of
people want that today. I don't — at least not yet.

I'm still human-in-the-loop. I'll stop being human-in-the-loop when an agent
can run for half a day unattended and produce work I'd put my name on. Until
then, those background patrols are mostly burning tokens watching me not
screw up.

So this preset is the Gas Town I actually use: the parts that make my day
better, none of the parts that assume I'm asleep.

---

## Install — give this prompt to your local Claude Code

Open a Claude Code session anywhere and paste:

> Install the `gastown-me-and-my-crew` preset for me.
>
> 1. Clone `https://github.com/wbern/gastown-me-and-my-crew` to `~/.gt-presets/gastown-me-and-my-crew` (`git pull` if it already exists).
> 2. Run `gt version`. If it isn't `v1.0.1-*`, tell me before going further — I'll decide whether to proceed.
> 3. Diff `~/gt/settings/config.json` against `config/settings.config.json`, and `~/gt/mayor/daemon.json` against `config/mayor.daemon.json`. Show me both diffs.
> 4. If I approve, copy each destination file to `<dest>.bak.$(date +%Y%m%d-%H%M%S)` first, then overwrite with the preset version.
> 5. Tell me to run `gt down && gt up --restore`, then `gt status` to confirm the daemon came up clean (malformed configs surface here).
>
> Stop and ask before doing anything destructive.

Claude does the clone, the version check, the diff, the timestamped backup,
and the copy — pausing for your approval at the diff step.

---

## Install — manually

```bash
# 1. Clone
git clone https://github.com/wbern/gastown-me-and-my-crew ~/.gt-presets/gastown-me-and-my-crew

# 2. Diff — review before changing anything
diff ~/gt/settings/config.json ~/.gt-presets/gastown-me-and-my-crew/config/settings.config.json
diff ~/gt/mayor/daemon.json    ~/.gt-presets/gastown-me-and-my-crew/config/mayor.daemon.json

# 3. Happy with the diffs? Back up the existing files
TS=$(date +%Y%m%d-%H%M%S)
cp ~/gt/settings/config.json ~/gt/settings/config.json.bak.$TS
cp ~/gt/mayor/daemon.json    ~/gt/mayor/daemon.json.bak.$TS

# 4. Overwrite with the preset
cp ~/.gt-presets/gastown-me-and-my-crew/config/settings.config.json ~/gt/settings/config.json
cp ~/.gt-presets/gastown-me-and-my-crew/config/mayor.daemon.json    ~/gt/mayor/daemon.json

# 5. Apply, then verify the daemon came up clean
gt down && gt up --restore
gt status
```

---

## What it disables (and why)

*Last verified against `gt v1.0.1-4-g91350080` on 2026-05-11. If the JSON
diverges from this table, the JSON is authoritative.*

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

`main_branch_test` is disabled in both layers (town `disabled_patrols` *and*
per-patrol `enabled: false`). Belt and suspenders — town-level is
authoritative on current `gt`, the per-patrol flag covers older builds that
don't read `disabled_patrols`.

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

If you've installed the preset more than once, the most recent backup is
the *previous preset version*, not your original config. To get back to
pre-preset state, restore the **oldest** `.bak.<timestamp>`. List them with
`ls -lt ~/gt/settings/config.json.bak.*` (oldest at the bottom).

---

## License

MIT. See [LICENSE](LICENSE).
