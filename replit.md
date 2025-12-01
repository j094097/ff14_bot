# Discord Bot Project

## Overview
This is a Discord bot written in Ruby using the discordrb library. The bot responds to messages in Discord channels with simple commands.

**Current State:** Fully functional and running
**Language:** Ruby 3.2
**Main Dependencies:** discordrb gem

## Purpose
A simple Discord bot that responds to "Ping!" messages with "Pong!" in Discord channels.

## Recent Changes
- **2024-12-01:** Project imported and configured for Replit environment
  - Fixed syntax error: Changed `os.environ` (Python) to `ENV` (Ruby)
  - Installed Ruby 3.2 and all gem dependencies via Bundler
  - Created .gitignore for Ruby projects
  - Configured workflow to run the bot
  - Bot successfully connected to Discord gateway

## Project Architecture

### File Structure
```
.
├── bot.rb           # Main bot script
├── Gemfile          # Ruby gem dependencies
├── Gemfile.lock     # Locked dependency versions
└── .gitignore       # Git ignore rules for Ruby
```

### How It Works
1. **bot.rb** - Main application file that:
   - Loads the discordrb library
   - Reads DISCORD_TOKEN from environment secrets
   - Creates a bot instance
   - Sets up message event handler for "Ping!" → "Pong!" responses
   - Runs the bot

### Dependencies
- **discordrb (3.7.1)** - Discord API library for Ruby
- Bundler 2.7.2 for dependency management

### Environment Configuration
- **DISCORD_TOKEN** (Secret) - Discord bot authentication token obtained from Discord Developer Portal

## Running the Bot
The bot runs automatically via the "Discord Bot" workflow with the command:
```bash
bundle exec ruby bot.rb
```

## Notes
- Voice support is not available (libsodium not installed) but text commands work perfectly
- The bot uses Discord Gateway Protocol version 9
- Bot token is securely stored in Replit Secrets
