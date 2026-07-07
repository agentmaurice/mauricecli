# MauriceCLI

**Command-line interface for AgentMaurice**

MauriceCLI is a powerful command-line tool for interacting with AgentMaurice from your terminal. Chat with AI, manage files, analyze documents, run tasks, and control your AgentMaurice deployment—all without leaving the command line.

## Features

### 💬 **Interactive Chat**
- Real-time chat sessions with AgentMaurice
- Beautiful terminal UI with syntax highlighting
- Stream responses as they're generated
- Conversation history and context management
- Batch mode for scripting and automation

### 📁 **File Management**
- Upload files to AgentMaurice storage
- Download files from deployments
- List and search files
- Organize files with tags and metadata

### 🔍 **Document Analysis**
- Analyze documents with AI
- Extract insights from PDFs, code, and text
- Generate summaries and reports
- Index documents for semantic search

### ✅ **Task Management**
- Create and manage tasks
- Track task execution status
- View task history and results
- Automate workflows with task templates

### 🏢 **Space & Project Management**
- Create and manage spaces
- Configure space settings
- Manage team members and permissions
- Project organization and collaboration

### 🔐 **Authentication**
- API key authentication
- Firebase authentication (Google, GitHub, etc.)
- Session management
- Multi-deployment support

### 🛠️ **Developer Tools**
- Export conversation history
- Debug mode with request/response tracing
- Configuration management
- Scripting and automation support

## Installation

### Secure Installer

Installers read the AgentMaurice update manifest, verify SHA256 and Minisign
signatures, then install the canonical `maurice` binary.

**Linux / macOS**
```bash
curl -fsSL https://github.com/agentmaurice/mauricecli/releases/latest/download/install_mauricecli.sh | bash
```

**Windows**
```powershell
iwr https://github.com/agentmaurice/mauricecli/releases/latest/download/install_mauricecli.ps1 -OutFile install_mauricecli.ps1
.\install_mauricecli.ps1
```

### Build from Source

```bash
git clone https://github.com/agentmaurice/chatserver.git
cd chatserver
go build -o maurice ./cmd/mauricecli
```

## Quick Start

### 1. Login

#### Option A: API Key Authentication

```bash
# Set API URL and authenticate
maurice login --api https://your-maurice-instance.com

# You'll be prompted for your API key
# Get your API key from: https://your-maurice-instance.com/settings/api-keys
```

#### Option B: Firebase Authentication

```bash
# Login with Firebase (Google, GitHub, etc.)
maurice firebase-login --api https://your-maurice-instance.com
```

### 2. Verify Connection

```bash
# Check authentication status
maurice whoami

# Test API connectivity
maurice ping
```

### 3. Start Chatting

```bash
# Start interactive chat session
maurice chat

# Send a single message
maurice chat send "What's the weather like today?"

# Chat in a specific space
maurice chat --space my-project
```

## Commands

### Authentication

#### `maurice login`
Authenticate with an API key.

```bash
# Interactive login
maurice login

# Specify API URL
maurice login --api https://api.maurice.ai

# Non-interactive (for scripts)
echo "your-api-key" | maurice login --api https://api.maurice.ai
```

#### `maurice firebase-login`
Authenticate with Firebase (Google, GitHub, email/password).

```bash
maurice firebase-login --api https://api.maurice.ai
```

#### `maurice whoami`
Display current authentication status.

```bash
maurice whoami

# Output:
# Authenticated as: user@example.com
# Organization: Acme Corp
# Deployment: prod-deployment-001
# API: https://api.maurice.ai
```

### Chat

#### `maurice chat`
Start an interactive chat session.

```bash
# Interactive mode
maurice chat

# Send single message
maurice chat send "Explain quantum computing"

# Chat in specific space
maurice chat --space research-project

# Chat with specific deployment
maurice chat --deployment prod-001

# Batch mode (read from file)
maurice chat --batch questions.txt

# Export conversation
maurice chat --export conversation.json
```

**Interactive Mode Shortcuts:**
- `Ctrl+C` - Exit
- `Ctrl+D` - New conversation
- `/help` - Show help
- `/clear` - Clear screen
- `/export <file>` - Export conversation

### Spaces

#### `maurice spaces list`
List all accessible spaces.

```bash
maurice spaces list

# With filtering
maurice spaces list --filter "project"
```

#### `maurice spaces create`
Create a new space.

```bash
maurice spaces create --name "My Project" --description "Project workspace"
```

#### `maurice spaces info`
Get information about a space.

```bash
maurice spaces info <space-id>
```

#### `maurice use`
Set the default space for subsequent commands.

```bash
# Set default space
maurice use space <space-id>

# Set default deployment
maurice use deployment <deployment-id>

# Show current context
maurice use
```

### Files

#### `maurice files upload`
Upload files to AgentMaurice storage.

```bash
# Upload single file
maurice files upload document.pdf

# Upload multiple files
maurice files upload *.txt report.pdf

# Upload with custom name
maurice files upload local.txt --name remote.txt

# Upload to specific space
maurice files upload data.csv --space analytics
```

#### `maurice files download`
Download files from storage.

```bash
# Download by file ID
maurice files download <file-id>

# Download to specific location
maurice files download <file-id> --output /path/to/save.pdf

# Download all files in space
maurice files download --space project-name --all
```

#### `maurice files list`
List files in storage.

```bash
# List all files
maurice files list

# List files in specific space
maurice files list --space project-name

# Search files
maurice files list --search "report"

# Filter by type
maurice files list --type pdf
```

#### `maurice files delete`
Delete files from storage.

```bash
maurice files delete <file-id>

# Delete multiple files
maurice files delete <file-id-1> <file-id-2>
```

### Document Analysis

#### `maurice analyze`
Analyze documents with AI.

```bash
# Analyze a file
maurice analyze document.pdf

# Analyze with specific prompt
maurice analyze code.py --prompt "Find security vulnerabilities"

# Analyze multiple files
maurice analyze *.md --prompt "Summarize these docs"

# Output to file
maurice analyze report.pdf --output analysis.txt
```

### Tasks

#### `maurice tasks list`
List tasks.

```bash
# List all tasks
maurice tasks list

# List pending tasks
maurice tasks list --status pending

# List tasks in space
maurice tasks list --space project-name
```

#### `maurice tasks create`
Create a new task.

```bash
maurice tasks create --name "Process Data" --description "Analyze customer data"

# With specific execution time
maurice tasks create --name "Daily Report" --schedule "0 9 * * *"
```

#### `maurice tasks status`
Get task status and results.

```bash
maurice tasks status <task-id>

# Watch task until completion
maurice tasks status <task-id> --watch
```

#### `maurice tasks delete`
Delete a task.

```bash
maurice tasks delete <task-id>
```

### Export

#### `maurice export`
Export conversation history and data.

```bash
# Export chat history
maurice export chat --output conversations.json

# Export from specific space
maurice export chat --space project-name --output project-chats.json

# Export files list
maurice export files --output files.json

# Export tasks
maurice export tasks --output tasks.json
```

### Configuration

#### `maurice alias`
Create command aliases for frequent operations.

```bash
# Create alias
maurice alias create ask "chat send"

# Use alias
maurice ask "What is the capital of France?"

# List aliases
maurice alias list

# Delete alias
maurice alias delete ask
```

### Testing & Development

#### `maurice test`
Test API connectivity and authentication.

```bash
# Run connection tests
maurice test

# Test specific endpoint
maurice test --endpoint /api/v1/health

# Verbose output
maurice test --verbose
```

#### `maurice ping`
Ping the API server.

```bash
maurice ping

# Output:
# Pong! Response time: 45ms
# Server: AgentMaurice v2.1.0
# Status: Healthy
```

## Configuration

### Configuration File

MauriceCLI stores configuration in `~/.maurice/config.yaml`:

```yaml
api:
  base_url: "https://api.maurice.ai"
  api_key: "sk-abc123..."

storage:
  base_url: "https://storage.maurice.ai"

current_deployment: "prod-deployment-001"
current_space: "default-space"

defaults:
  chat_model: "claude-3-5-sonnet"
  temperature: 0.7
  max_tokens: 4096
```

### Environment Variables

Override configuration with environment variables:

```bash
export MAURICE_API="https://api.maurice.ai"
export MAURICE_API_KEY="your-api-key"
export MAURICE_STORAGE="https://storage.maurice.ai"
export MAURICE_DEBUG="true"
```

### Global Flags

All commands support these global flags:

```bash
--api string        API base URL
--storage string    Storage base URL
--config string     Config file path (default: ~/.maurice/config.yaml)
--debug            Enable debug mode with request tracing
```

## Usage Examples

### Interactive Chat Session

```bash
maurice chat
```

```
╔══════════════════════════════════════════════════════════════╗
║              AgentMaurice Interactive Chat                   ║
╚══════════════════════════════════════════════════════════════╝

Space: research-project
Model: claude-3-5-sonnet-20250929

You: Explain the theory of relativity in simple terms

Maurice: The theory of relativity, developed by Albert Einstein,
consists of two main parts:

1. Special Relativity (1905):
   - Time and space are relative, not absolute
   - The speed of light is constant for all observers
   - Time dilates and length contracts at high speeds

2. General Relativity (1915):
   - Gravity is not a force, but curvature of spacetime
   - Massive objects bend the fabric of spacetime
   - This explains planetary orbits and black holes

Key insight: Space and time are intertwined as "spacetime,"
and this fabric can be warped by mass and energy.

You: /export relativity-explanation.md

✓ Conversation exported to relativity-explanation.md
```

### Batch Processing

Create a file `questions.txt`:
```
What is machine learning?
Explain neural networks.
What are the applications of AI in healthcare?
```

Run batch processing:
```bash
maurice chat --batch questions.txt --export answers.json
```

### File Upload and Analysis

```bash
# Upload quarterly reports
maurice files upload Q1-report.pdf Q2-report.pdf Q3-report.pdf --space finance

# Analyze them
maurice analyze Q1-report.pdf Q2-report.pdf Q3-report.pdf \
  --prompt "Compare revenue trends across quarters and identify growth opportunities" \
  --output analysis-report.md
```

### Automated Daily Reports

Create a script `daily-report.sh`:

```bash
#!/bin/bash
DATE=$(date +%Y-%m-%d)

# Create task for daily analysis
maurice tasks create \
  --name "Daily Analytics Report - $DATE" \
  --description "Analyze yesterday's data and generate insights" \
  --space analytics

# Export task results when complete
sleep 60  # Wait for task completion
maurice tasks status <task-id> --output "reports/daily-$DATE.json"
```

### Multi-Space Workflow

```bash
# Work in development space
maurice use space dev-workspace

maurice chat send "Test the new feature"
maurice files upload test-results.csv

# Switch to production
maurice use space production

maurice chat send "Deploy version 2.0"
maurice tasks list --status running
```

### CI/CD Integration

```yaml
# .gitlab-ci.yml
test_with_maurice:
  script:
    - export MAURICE_API_KEY="${CI_MAURICE_API_KEY}"
    - maurice login --api https://api.maurice.ai
    - maurice files upload test-results.xml coverage-report.html
    - maurice chat send "Analyze test results and suggest improvements" --export analysis.txt
    - cat analysis.txt
```

## Scripting & Automation

### JSON Output

Most commands support `--output json` for machine-readable output:

```bash
# Get spaces as JSON
maurice spaces list --output json | jq '.[] | select(.name | contains("prod"))'

# Get file list as JSON
maurice files list --output json | jq '.[].id'

# Export chat to JSON
maurice chat send "Analyze this data" --export - | jq '.messages'
```

### Exit Codes

MauriceCLI uses standard exit codes:
- `0` - Success
- `1` - General error
- `2` - Authentication error
- `3` - API error
- `4` - File not found

Use in scripts:
```bash
if maurice ping; then
  echo "API is healthy"
  maurice chat send "Run daily tasks"
else
  echo "API is down, sending alert..."
  send_alert
fi
```

### Environment-based Configuration

```bash
# Development
export MAURICE_API="http://localhost:5000"
export MAURICE_DEBUG="true"
maurice chat send "Test feature"

# Production
export MAURICE_API="https://api.maurice.ai"
export MAURICE_DEBUG="false"
maurice chat send "Process production data"
```

## Troubleshooting

### Connection Issues

```bash
# Test API connectivity
maurice ping

# Enable debug mode
maurice --debug ping

# Test with verbose output
maurice test --verbose
```

### Authentication Problems

```bash
# Check authentication status
maurice whoami

# Re-authenticate
maurice login --api https://api.maurice.ai

# Clear cached credentials
rm ~/.maurice/config.yaml
maurice login
```

### File Upload Failures

```bash
# Check file size (max 100MB typically)
ls -lh large-file.pdf

# Upload with debug output
maurice --debug files upload large-file.pdf

# Check storage server connectivity
maurice --storage https://storage.maurice.ai test
```

### Common Error Messages

**"Authentication failed: invalid API key"**
```bash
# Verify API key
maurice whoami

# Re-login with correct key
maurice login
```

**"Space not found"**
```bash
# List available spaces
maurice spaces list

# Use correct space ID
maurice use space <correct-space-id>
```

**"Rate limit exceeded"**
```bash
# Wait before retrying (typically 60 seconds)
# Or upgrade your plan for higher rate limits
```

## Advanced Features

### Custom Prompts

Create prompt templates in `~/.maurice/prompts/`:

```yaml
# ~/.maurice/prompts/code-review.yaml
name: "Code Review"
prompt: |
  Review the following code for:
  1. Security vulnerabilities
  2. Performance issues
  3. Code style and best practices
  4. Potential bugs

  Code:
  {{content}}
```

Use:
```bash
maurice analyze src/app.py --prompt-template code-review
```

### Pipeline Integration

```bash
# Use with pipes
cat data.csv | maurice chat send "Analyze this data" --stdin

# Process output
maurice chat send "Generate test data" | jq '.response' > test-data.json

# Chain commands
maurice files list --output json | \
  jq -r '.[].id' | \
  xargs -I {} maurice files download {}
```

### Watch Mode

```bash
# Watch task until completion
maurice tasks status <task-id> --watch

# Auto-refresh chat
maurice chat --watch --space monitoring
```

## Security Best Practices

1. **Protect API Keys**: Never commit API keys to version control
   ```bash
   # Use environment variables
   export MAURICE_API_KEY="$(cat ~/.maurice/api-key.secret)"
   ```

2. **Use Read-only Keys**: Create separate API keys with limited permissions for automation
   ```bash
   # Create read-only key in dashboard for CI/CD
   ```

3. **Enable Debug Only When Needed**: Debug mode logs requests/responses
   ```bash
   # Production: disable debug
   maurice --debug=false chat send "sensitive data"
   ```

4. **Audit Logs**: Review command history regularly
   ```bash
   history | grep maurice
   ```

5. **Secure Config File**: Set proper permissions
   ```bash
   chmod 600 ~/.maurice/config.yaml
   ```

## Performance Tips

1. **Batch Operations**: Upload multiple files at once
   ```bash
   maurice files upload *.pdf  # Better than individual uploads
   ```

2. **Use Filters**: Reduce API calls with server-side filtering
   ```bash
   maurice files list --space project --type pdf  # Faster than client-side filtering
   ```

3. **Persistent Sessions**: Reuse spaces and deployments
   ```bash
   maurice use space project
   # All subsequent commands use this space
   ```

4. **Local Caching**: Cache file lists locally
   ```bash
   maurice files list --output json > files-cache.json
   ```

## Updating

```bash
# Check and install explicitly
maurice update check
maurice update install --yes
```

## Shell Completion

### Bash

```bash
# Generate completion script
maurice completion bash > ~/.maurice/completion.bash

# Add to .bashrc
echo "source ~/.maurice/completion.bash" >> ~/.bashrc
source ~/.bashrc
```

### Zsh

```bash
# Generate completion script
maurice completion zsh > ~/.maurice/completion.zsh

# Add to .zshrc
echo "source ~/.maurice/completion.zsh" >> ~/.zshrc
source ~/.zshrc
```

### Fish

```bash
maurice completion fish > ~/.config/fish/completions/maurice.fish
```

## Contributing

MauriceCLI is part of the [AgentMaurice chatserver repository](https://github.com/agentmaurice/chatserver).

To contribute:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `go test ./mauricecli/...`
5. Submit a pull request

## License

[MIT License](LICENSE)

## Support

- **Documentation**: https://docs.agentmaurice.ai
- **Issues**: https://github.com/agentmaurice/chatserver/issues
- **Discussions**: https://github.com/agentmaurice/chatserver/discussions
- **Discord**: https://discord.gg/agentmaurice

## Credits

Built with:
- [Cobra](https://cobra.dev) - CLI framework
- [Viper](https://github.com/spf13/viper) - Configuration management
- [Bubble Tea](https://github.com/charmbracelet/bubbletea) - Terminal UI
- [LiveKit SDK](https://livekit.io) - Real-time communication
