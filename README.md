# Claude API Wrapper for CFML

A ColdFusion component (CFC) wrapper for the Anthropic Claude API, written in CFScript with proper abstraction and error handling.

## Features

- Clean CFScript-based API wrapper
- Environment variable support for API keys
- Proper error handling and structured responses
- Abstracted HTTP requests for maintainability
- Support for both single messages and multi-turn conversations
- Built-in support for all current Claude models

## Installation

1. Clone this repository
2. Copy the `claude-cfml` folder to your CFML application
3. Set up your API key (see Configuration section)

## Configuration

### API Key Setup

The component supports multiple ways to provide your Anthropic API key (in order of priority):

1. **Manual parameter** - Pass directly to `init(apiKey)`
2. **Environment variable** - Set `ANTHROPIC_API_KEY` 
3. **Java system property** - Set `anthropic.api.key`

### Environment Variables

Copy `.env.example` to `.env` and add your API key:

```bash
cp .env.example .env
# Edit .env and add your actual API key
```

## Usage

### Basic Setup

```cfm
// Initialize the API wrapper
claudeAPI = createObject("component", "claude-cfml.ClaudeAPI").init();

// Or with manual API key
claudeAPI = createObject("component", "claude-cfml.ClaudeAPI").init("your-api-key");
```

### Send a Simple Message

```cfm
result = claudeAPI.sendMessage("Hello, how are you today?");

if (result.success) {
    writeOutput(result.response);
} else {
    writeOutput("Error: " & result.error);
}
```

### Send Message with Options

```cfm
result = claudeAPI.sendMessage(
    message = "Explain quantum computing",
    model = "claude-3-5-sonnet-20241022",
    maxTokens = 2048,
    temperature = 0.7,
    systemPrompt = "You are a helpful physics teacher"
);
```

### Multi-turn Conversation

```cfm
messages = [
    {"role": "user", "content": "What is the capital of France?"},
    {"role": "assistant", "content": "The capital of France is Paris."},
    {"role": "user", "content": "What's the population?"}
];

result = claudeAPI.sendConversation(messages);
```

## API Methods

### `sendMessage()`

Send a single message to Claude.

**Parameters:**
- `message` (required string) - The message to send
- `model` (string) - Claude model to use (default: claude-3-5-sonnet-20241022)
- `maxTokens` (numeric) - Maximum tokens in response (default: 1024)
- `temperature` (numeric) - Response randomness 0-2 (default: 1)
- `systemPrompt` (string) - System prompt to set context

**Returns:** Struct with `success`, `response`, `usage`, `model`, and `rawResponse` keys

### `sendConversation()`

Send a multi-turn conversation to Claude.

**Parameters:**
- `messages` (required array) - Array of message objects with `role` and `content`
- `model` (string) - Claude model to use (default: claude-3-5-sonnet-20241022)
- `maxTokens` (numeric) - Maximum tokens in response (default: 1024)
- `temperature` (numeric) - Response randomness 0-2 (default: 1)
- `systemPrompt` (string) - System prompt to set context

**Returns:** Struct with `success`, `response`, `usage`, `model`, and `rawResponse` keys

### `getModels()`

Get array of available Claude models.

**Returns:** Array of model strings

## Supported Models

- `claude-3-5-sonnet-20241022` (default)
- `claude-3-5-haiku-20241022`
- `claude-3-opus-20240229`
- `claude-3-sonnet-20240229`
- `claude-3-haiku-20240307`

## Error Handling

All methods return a struct with a `success` boolean. On error:

```cfm
{
    "success": false,
    "error": "Error message",
    "errorDetail": "Detailed error information"
}
```

## Development

This project follows the guidelines in `CLAUDE.md`. Key principles:

- CFScript syntax in CFC files
- Bracket notation for struct keys
- Proper var scoping and argument scoping
- Abstracted HTTP requests
- Environment variable support

## Testing

A test interface is available at `index.cfm` when running with CommandBox:

```bash
box start cfengine=lucee@6
```

## License

This project is provided as-is for educational and development purposes.