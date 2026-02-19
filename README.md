# nix-sandbox

A Bubblewrap-based launcher for sandboxing arbitrary CLI tools with Nix-provided dependencies.

Tools run in an isolated runtime and only see the current working directory and other carefully mounted directories.
You can use it for many workflows; a common use case is running coding agents like OpenCode and Codex.

## Features

- Mounts your current working directory into the sandbox at the same absolute path.
- Runs commands from that mounted project path by default (or a subpath via `-C`).
- Mounts nested `.git` metadata read-only by default (disable with `--no-git-ro`).
- Supports ad-hoc tooling via `--pkgs` using `nix shell`.
- Supports offline mode with `--no-net`.
- Runs with a minimal environment and explicit bind mounts.

## Requirements

- `nix` (with `nix-command` + `flakes` available)
- `bubblewrap` (`bwrap`) on host
- `direnv` (optional, for auto-loading dev shell)

## Quick start

From this repo:

```bash
./nix-sandbox opencode --version
./nix-sandbox codex --version
./nix-sandbox python3 -c "import yaml; print('ok')"
```

Use ad-hoc packages:

```bash
./nix-sandbox --pkgs "git ripgrep fd" bash -lc "rg --version"
```

## Install via flake

Install the launcher from a flake reference:

```bash
nix profile install github:fabian-thomas/nix-sandbox
```

Run directly without installing:

```bash
nix run github:fabian-thomas/nix-sandbox -- opencode
```

## Recommended aliases

Use aliases like these for daily use:

```bash
alias opencode='nix-sandbox opencode'
alias codex='nix-sandbox codex'
```

## Custom environment (shell.nix)

By default, `nix-sandbox` uses the bundled `shell.nix`. To use your own shell, set `NIX_SHELL_FILE`:

```bash
NIX_SHELL_FILE="path/to/your/environment.nix" ./nix-sandbox -- python3
```

> [!NOTE]
> `nix-sandbox` mounts the entire parent directory of `NIX_SHELL_FILE` read-only into the sandbox so Nix can load that file.

If you only need ad-hoc tools and no shell file, use `--pkgs`.

## Known problems

On systems with restricted unprivileged user namespaces, `nix-sandbox` may fail with:

```text
bwrap: setting up uid map: Permission denied
```

This means `bwrap` was blocked from creating the user namespace it needs to start the sandbox.
The setting `kernel.apparmor_restrict_unprivileged_userns` controls this restriction.
Setting it to `0` relaxes the restriction and allows `nix-sandbox` to start.
Review the security implications carefully.

Temporary setting:
```bash
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
```

Permanent setting:
Add `kernel.apparmor_restrict_unprivileged_userns=0` to a file in `/etc/sysctl.d/`, then run `sudo sysctl --system`.
