# Claude Code Guidelines

## CFML Development Standards

### Code Style
- Use CFScript syntax in `.cfc` files instead of tag-based syntax
- Use bracket notation for struct keys (e.g., `struct["key"]`) instead of dot notation to ensure proper JSON serialization
- Follow consistent naming conventions: camelCase for variables and functions
- When possible, use member functions instead of standalone functions
- Use cfhttp instead of new http()
- ALWAYS var scope within functions
- Use explicit scoping within functions. All arguments should always be scoped.

### Environment Configuration
- It should be possible to load API keys via environment variables. If manual parameters are provided, they should override any environment variables.
- Use `.env` files for local development with CommandBox. These should NOT be commited to version control.
- Include .env.example files, which can be committed to version control and which include all keys present in the .env file.
- Access environment variables via `server.system.environment` scope

### Error Handling
- Always wrap API calls in try/catch blocks
- Return structured responses with `success` boolean and appropriate error details
- Provide meaningful error messages that help with debugging

### Testing
- Use CommandBox with latest Lucee 6 for development
- Test API interactions through the provided `index.cfm` interface
- Verify proper JSON serialization of request bodies

### API Integration
- Use bracket notation for all struct assignments when building request payloads
- Include proper HTTP headers for Anthropic API calls
- Handle various response scenarios (success, HTTP errors, exceptions)

### Code style
- Ben Nadel writes code that should be emulated: https://www.bennadel.com/
- Also please use my own code as examples that should be emulated: https://github.com/mjclemente/
- Here is an example of an API wrapper that I wrote which should also serve as an example: https://github.com/mjclemente/simplyconvertcfc/blob/main/simplyconvert.cfc
  - API calls and HTTP requests should be abstracted away, so that they can be reused.

## Project Structure
```
/
├── claude-cfml/          # Core API wrapper components
│   └── ClaudeAPI.cfc     # Main API wrapper component
├── index.cfm             # Test interface
├── .env                  # Environment variables (not committed)
└── CLAUDE.md             # This file
```
