# Dev Tools

Windows maintenance and developer utilities — dark-themed WinForms GUI (.NET 9) that wraps a collection of batch scripts for common housekeeping tasks.

![.NET 9](https://img.shields.io/badge/.NET-9.0-512BD4) ![Windows](https://img.shields.io/badge/platform-Windows-0078D4) ![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Tabbed interface** — Maintenance, Docker, Dev, Security, Combos
- **Async execution** — scripts run in background, output streamed in real time
- **Queue system** — queue multiple scripts; they run sequentially, never dropped
- **Auto-logging** — every run saved to `logs/YYYY-MM-DD_HH-mm-ss_scriptname.txt`
- **Queue view** — toggle panel to see running + pending scripts

## Requirements

- Windows 10/11
- [.NET 9 Desktop Runtime](https://dotnet.microsoft.com/download/dotnet/9.0)

## Run

Download `DevTools.exe` from [Releases](../../releases) and place it in the same folder as the `.bat` scripts. Double-click to launch.

> The `.exe` must live alongside the scripts — it resolves paths relative to its own location.

## Build from source

```bash
cd DevToolsApp
dotnet publish -c Release -o ../dist
```

Output: `dist/DevTools.exe`

## Scripts

### Maintenance

| Script | Description |
|--------|-------------|
| `disk_summary.bat` | Disk usage across all drives + top folders by size in `%USERPROFILE%` |
| `clean_temp.bat` | Clears `%TEMP%`, npm cache, Chrome cache |
| `find_large_files.bat` | Top 30 files >100 MB under `C:\Users` |
| `node_modules_cleaner.bat` | Finds and removes all `node_modules` folders |
| `pip_cache_clean.bat` | Clears pip and uv caches |
| `vscode_cleanup.bat` | Removes VS Code cache and log files |
| `git_cleanup.bat` | Runs `git gc` and `git remote prune` across all repos |

### Docker

| Script | Description |
|--------|-------------|
| `docker_prune.bat` | Removes stopped containers and build cache |
| `compact_docker.bat` | Compacts Docker `.vhdx` virtual disks *(requires Admin)* |
| `wsl_memory_reclaim.bat` | Shuts down WSL2 to release RAM |

### Dev

| Script | Description |
|--------|-------------|
| `dev_env_check.bat` | Prints versions of Node, Python, Git, Docker, etc. |
| `port_killer.bat` | Kills the process listening on a given port |
| `network_check.bat` | Local/public IP, DNS, open ports |
| `startup_check.bat` | Lists programs that run on Windows startup |
| `move_to_drive_symlink.bat` | Moves a folder to another drive and leaves a junction in place |

### Security

| Script | Description |
|--------|-------------|
| `security_check.bat` | Checks Defender, Firewall, listening ports, active users, Ollama bind address |
| `secrets_scan.bat` | Scans disk for `.env` files and credential patterns |
| `git_secrets_audit.bat` | Verifies `.gitignore` coverage and scans git history for secrets |

### Combos

Auto-generated on startup by `Program.cs`.

| Script | Runs |
|--------|------|
| `_combo_maint.bat` | clean_temp → node_modules_cleaner → pip → vscode → git_cleanup → docker_prune |
| `_combo_deep.bat` | Everything above + compact_docker *(Admin)* |
| `_combo_audit.bat` | secrets_scan → security_check → git_secrets_audit |

## Configuration

Create a `.env` file next to `DevTools.exe` (excluded from git):

```env
# Usernames considered trusted in security_check [5/6]
TRUSTED_USERS=YourUser,WDAGUtilityAccount

# Path to Docker virtual disks (for compact_docker)
# Default: %LOCALAPPDATA%\Docker\wsl
DOCKER_VHDX_DIR=D:\DockerImages\DockerDesktopWSL
```

## Project structure

```
.
├── DevToolsApp/          # C# WinForms source (.NET 9)
│   ├── Program.cs
│   └── DevToolsApp.csproj
├── *.bat                 # Individual scripts
├── _combo_*.bat          # Auto-generated combo scripts
├── .env                  # Local config — NOT committed
└── logs/                 # Auto-created on first run — NOT committed
```

## License

MIT
