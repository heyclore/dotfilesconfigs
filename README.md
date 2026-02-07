# Immutable `/usr` with systemd-sysext (Arch Linux)

This document summarizes an **immutable `/usr`** setup using
`systemd-sysext`, with **selective immutability in `/var`** and safe
handling of `pacman` during development and testing.

---

## Goals

- Prevent accidental system drift
- Make `/usr` image-like and reproducible
- Use `systemd-sysext` as the *only* mutation path for `/usr`
- Fail fast if tools try to mutate the base system
- Keep Arch flexibility without turning it into a full immutable distro

---

## Filesystem Model

- /usr → system image (immutable)
- /etc → configuration (mutable)
- /var → state (mutable, selectively constrained)
- /run → runtime (tmpfs)
- /home → user data


### `/usr`
- Mounted **read-only from boot**
- Never written to directly
- Extended only via `systemd-sysext`
- No `chattr +i` (breaks overlayfs)

### `/etc`
- Writable
- Managed manually
- `.pacnew` / `.pacsave` expected

### `/var`
- Writable by default
- Treated as **state**, not system
- Selected subpaths may be RO or tmpfs

---

## systemd-sysext

- Designed for immutable `/usr`
- Uses **overlayfs**
- Base `/usr` remains untouched
- Extensions provide additive `/usr` trees

### Requirements
- `/usr` must be immutable via **mounts**, not FS flags
- `/run` must be writable
- Extension source directory must be writable
  - e.g. `/run/extensions`

### Non-requirements
- `/usr` does **not** need to be writable
- `/var` does **not** need to be immutable

---

## Pacman Strategy

`pacman` is a **system mutation tool** and is incompatible with an
immutable `/usr` during sysext usage.

### Rules
- Never run `pacman` while sysext is merged
- Build packages, don’t install them
- Extract `/usr` from packages into sysext trees

### Hard Block (Fail-Fast)

To prevent accidental mutation:

- Bind-mount `/var/lib/pacman` to itself
- Remount it **read-only**

Result:
- `pacman` fails immediately
- No DB writes
- No hooks
- No partial state

This lock is **temporary** and reversed when sysext is unmerged.

---

## Recommended `/var` Constraints

| Path | Treatment | Reason |
|-----|----------|--------|
| `/var/lib/pacman` | bind RO | block pacman safely |
| `/var/cache/pacman` | tmpfs / RW | disposable cache |
| `/var/log` | RW / tmpfs | logging |
| `/var/tmp` | tmpfs | transient state |
| `/var/lib/systemd` | RW | systemd state |

Do **not** make all of `/var` immutable.

---

## What This Setup Gives You

- Strong system integrity
- Clear separation of image vs state
- Predictable behavior
- Easy rollback (`sysext unmerge`)
- Fail-fast errors instead of silent corruption

---

## What This Setup Is NOT

- A beginner-friendly Arch setup
- A fully immutable OS
- Compatible with ad-hoc `pacman -S` workflows

---

## Mental Model

- /usr = image (immutable)
- /etc = policy
- /var = state


If `/usr` changes, it was **intentional**.

---

## Summary

This approach provides **most of the safety of an immutable OS** while
retaining **Arch Linux flexibility**, using standard kernel and systemd
features without filesystem hacks.

It is advanced, opinionated, and powerful — by design.

