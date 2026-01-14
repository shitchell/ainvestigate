# ainvestigate

AI-assisted terminal debugging. Capture your terminal output and send it to an LLM for analysis.

When something goes wrong in your terminal, just run `ainvestigate` and let AI help you figure out what happened.

## Features

- Captures recent terminal output automatically
- Sends context to an AI assistant (Claude by default)
- Works with tmux scrollback or script(1) session logging
- Configurable AI command (Claude, Gemini, Ollama, etc.)

## Installation

```bash
git clone https://github.com/shitchell/ainvestigate.git
cd ainvestigate
./install.sh
```

You'll be prompted to choose a variant:

### tmux variant
- Uses tmux's scrollback buffer
- Zero overhead (no extra processes or log files)
- Only works inside tmux sessions

### script variant
- Uses `script(1)` to log terminal sessions
- Works in any terminal
- Automatically sets up session recording in your shell

## Usage

```bash
# Capture and send to AI for analysis
ainvestigate

# Include a specific question
ainvestigate "why did this command fail?"

# Capture more/fewer lines (default: 500)
ainvestigate -n 1000

# Dry run - see what would be sent without calling AI
ainvestigate --dry-run

# Pass extra arguments to the AI command
ainvestigate -- --dangerously-skip-permissions
```

## Configuration

Create `~/.ainvestigate.conf`:

```bash
# Use a different AI command
AI_CMD=("gemini-cli" "chat")
# or
AI_CMD=("ollama" "run" "llama3")

# Change default line count
DEFAULT_LINES=1000
```

The config file name is based on the script name, so if you install as `ainvestigate`, it looks for `~/.ainvestigate.conf`. You can also specify a custom config file with `--config-file <path>`.

## How It Works

### tmux variant

When you run `ainvestigate` inside tmux, it captures the scrollback buffer using `tmux capture-pane`, wraps it with metadata (timestamp, working directory, shell), and sends it to your configured AI command.

### script variant

The script variant sets up automatic session logging:

1. `~/.ainvestigate.sh` is sourced from your shell rc file
2. It starts a `script(1)` session that logs all terminal output
3. When you run `ainvestigate`, it reads from that log file
4. Logs are automatically deleted when you exit your shell

The session setup uses an exec-based approach to avoid extra waiting processes.

## Uninstalling

```bash
./uninstall.sh
```

This removes the installed script, session setup file, and config files. You may need to manually remove the sourcing line from your shell rc file.

## Requirements

- Bash 4.0+
- `tmux` (for tmux variant)
- `script` (for script variant, usually pre-installed)
- An AI CLI tool (e.g., `claude`, `gemini-cli`, `ollama`)

## License

MIT
