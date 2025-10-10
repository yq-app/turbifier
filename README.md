# Turbifier - Email Verification Tool

Fast and reliable email verification for Turbify mail accounts. Verify bulk email lists with automated captcha solving and duplicate tracking.

---

## Installation

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/yq-app/turbifier/main/scripts/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/yq-app/turbifier/main/scripts/install.ps1 | iex
```

### Manual Installation

Download the binary for your system from [releases](https://github.com/yq-app/turbifier/releases/latest), then:

**Linux/macOS:**
```bash
chmod +x tubifier-*
sudo mv tubifier-* /usr/local/bin/tubifier
```

**Windows:**
Move the `.exe` file to a folder in your PATH.

---

## Quick Start

### 1. Initialize

```bash
tubifier init
```

Creates `config.toml` in your current directory.

### 2. Add Captcha API Key

Edit `config.toml`:

```toml
[captchaSolver.NextCaptcha]
enabled = true
apiKey = "your-api-key-here"
```

Get API keys from:
- NextCaptcha: https://nextcaptcha.com (recommended)
- 2captcha: https://2captcha.com
- Anti-captcha: https://anti-captcha.com

### 3. Login

```bash
tubifier login <your-access-token>
```

Set up your PIN and security questions when prompted.

### 4. Prepare Email List

Create `emails.txt` with one email per line:

```
user1@example.com
user2@domain.com
user3@mail.com
```

### 5. Start Verification

```bash
tubifier start
```

---

## Configuration

Edit `config.toml` to customize behavior:

### Files

```toml
outputFile = "./turby-sorted.txt"  # Valid emails saved here
failedFilePath = "./failed.txt"    # Invalid emails (optional)
leadsPath = "./emails.txt"         # Your email list
```

### Timing

```toml
delayInBetween = 2      # Seconds between each email (2-5 recommended)
pausing = true          # Enable batch pausing
pauseAfterTask = 500    # Pause after this many emails
pauseTime = 10          # Pause duration (seconds)
```

### Options

```toml
allowDuplicate = false              # Skip already-checked emails
maximumError = 20                   # Max errors before pausing
stopIfMaximumErrorReached = false   # Stop on max errors (false = pause & retry)
```

---

## Commands

### Verification

```bash
tubifier start          # Verify all emails
tubifier start 100      # Verify first 100 emails only
```

### Authentication

```bash
tubifier login <token>          # Login and setup
tubifier logout                 # Logout current device
tubifier auth pin               # Change PIN
tubifier auth reset-pin <token> # Reset PIN (requires security questions)
tubifier auth list              # View all devices
```

### Security Questions

```bash
tubifier auth security-questions        # View questions
tubifier auth add-security              # Add question (max 3)
tubifier auth update-security <number>  # Update question
tubifier auth remove-security <number>  # Remove question
```

### Configuration

```bash
tubifier init                           # Create config file
tubifier config set --output <path>     # Set output file
tubifier config set --leads <path>      # Set email list path
tubifier config enable-api --nextcaptcha <key>  # Set API key
```

### Duplicates

```bash
tubifier count-duplicate        # View stats
tubifier clear -c               # Clear current project
tubifier clear -p <name>        # Clear specific project
```

---

## Understanding Progress

During verification, you'll see real-time progress:

```
Current Email: user@example.com
Status: Bypassing captcha
Progress: 45 / 100 (45.0%)

┌─ Statistics
│  ✓ Valid: 30
│  ✗ Invalid: 12
│  ⚠ Errors: 3
│  ◷ Checked: 42
└─ Elapsed: 2m15s
```

**Status Colors:**
- Yellow = Processing
- Green = Success
- Red = Failed

### Final Results

```
Metric          │ Count │ Details
────────────────┼───────┼──────────────────────
Total Emails    │ 100   │ Emails loaded
✓ Valid         │ 75    │ 75.0% success rate
✗ Invalid       │ 20    │ Failed verification
⚠ Errors        │ 5     │ HTTP/Captcha errors
◷ Checked       │ 95    │ Successfully processed
⏱ Duration      │ 5m30s │ Total time elapsed
```

---

## Device Management

**Maximum 3 active devices per account.**

### When device limit is reached:
- Inactive devices (30+ days) are auto-removed
- 3-day wait required after auto-removal
- Manual logout: View devices with `tubifier auth list`

### Logout Cooldowns:
- 30+ days usage: 3-day cooldown
- <30 days usage: 14-day cooldown

---

## Troubleshooting

**"Not authenticated"**
→ Run `tubifier login <token>`

**"No captcha solvers configured"**
→ Add API key in `config.toml`

**"Maximum errors reached"**
→ Check captcha balance, increase `delayInBetween`, check internet

**"Device limit reached"**
→ Run `tubifier auth list` and logout from old devices

**Verification too slow**
→ Reduce `delayInBetween` (min 2 seconds), disable `pausing`

**High error rate**
→ Increase `delayInBetween`, enable `adaptiveRateLimiting`

---

## Best Practices

1. Test with 10-20 emails first
2. Keep delay at 2-5 seconds
3. Enable duplicate tracking
4. Save failed emails to separate file
5. Monitor error counts
6. Use batch pausing for large lists
7. Never share your access token
8. Set up 2-3 security questions
9. Backup results regularly
10. Clear old duplicate data periodically

---

## Getting Help

```bash
tubifier --help              # General help
tubifier <command> --help    # Command help
```

---

## License

Copyright © 2024 Turbifier Team. All rights reserved.
