<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Claude API Test</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, textarea, select { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
        textarea { height: 100px; resize: vertical; }
        button { background-color: #007cba; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
        button:hover { background-color: #005a87; }
        .response { margin-top: 20px; padding: 15px; background-color: #f5f5f5; border-radius: 4px; }
        .error { background-color: #ffe6e6; border: 1px solid #ff9999; }
        .success { background-color: #e6ffe6; border: 1px solid #99ff99; }
        .usage { font-size: 0.9em; color: #666; margin-top: 10px; }
    </style>
    <script>
        function validateForm(buttonType) {
            var messageField = document.getElementById('message');
            if (buttonType === 'submit' && !messageField.value.trim()) {
                alert('Please enter a message to send to Claude.');
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <h1>Claude API Test Interface</h1>

    <cfparam name="form.apiKey" default="#structKeyExists(server.system.environment, 'ANTHROPIC_API_KEY') ? server.system.environment.ANTHROPIC_API_KEY : ''#">
    <cfparam name="form.message" default="">
    <cfparam name="form.model" default="claude-sonnet-4-20250514">
    <cfparam name="form.maxTokens" default="1024">
    <cfparam name="form.temperature" default="1">
    <cfparam name="form.systemPrompt" default="">

    <form method="post">
        <div class="form-group">
            <label for="apiKey">API Key:</label>
            <input type="password" id="apiKey" name="apiKey" value="<cfoutput>#form.apiKey#</cfoutput>" placeholder="Enter your Anthropic API key" required>
        </div>

        <div class="form-group">
            <label for="model">Model:</label>
            <select id="model" name="model">
                <cfif len(form.apiKey)>
                    <cftry>
                        <cfset claudeAPI = createObject("component", "claude-cfml.ClaudeAPI").init(form.apiKey)>
                        <cfset modelsResult = claudeAPI.listModels()>
                        <cfif modelsResult.success>
                            <cfloop array="#modelsResult.data#" index="model">
                                <option value="<cfoutput>#model.id#</cfoutput>" <cfif form.model eq model.id>selected</cfif>><cfoutput>#model.display_name#</cfoutput></option>
                            </cfloop>
                        <cfelse>
                            <option value="claude-sonnet-4-20250514" <cfif form.model eq "claude-sonnet-4-20250514">selected</cfif>>Claude Sonnet 4 (fallback)</option>
                        </cfif>
                        <cfcatch type="any">
                            <option value="claude-sonnet-4-20250514" <cfif form.model eq "claude-sonnet-4-20250514">selected</cfif>>Claude Sonnet 4 (fallback)</option>
                        </cfcatch>
                    </cftry>
                <cfelse>
                    <option value="claude-sonnet-4-20250514" <cfif form.model eq "claude-sonnet-4-20250514">selected</cfif>>Claude Sonnet 4</option>
                    <option disabled>Enter API key to load available models</option>
                </cfif>
            </select>
        </div>

        <div class="form-group">
            <label for="systemPrompt">System Prompt (optional):</label>
            <textarea id="systemPrompt" name="systemPrompt" placeholder="Enter system prompt (optional)"><cfoutput>#form.systemPrompt#</cfoutput></textarea>
        </div>

        <div class="form-group">
            <label for="message">Message:</label>
            <textarea id="message" name="message" placeholder="Enter your message to Claude"><cfoutput>#form.message#</cfoutput></textarea>
        </div>

        <div class="form-group">
            <label for="maxTokens">Max Tokens:</label>
            <input type="number" id="maxTokens" name="maxTokens" value="<cfoutput>#form.maxTokens#</cfoutput>" min="1" max="8192">
        </div>

        <div class="form-group">
            <label for="temperature">Temperature:</label>
            <input type="number" id="temperature" name="temperature" value="<cfoutput>#form.temperature#</cfoutput>" min="0" max="2" step="0.1">
        </div>

        <button type="submit" name="submit" onclick="return validateForm('submit')">Send Message</button>
        <button type="submit" name="listModels" onclick="return validateForm('listModels')" style="margin-left: 10px; background-color: #28a745;">List Available Models</button>
    </form>

    <cfif structKeyExists(form, "listModels")>
        <cfif len(form.apiKey)>
            <cftry>
                <cfset claudeAPI = createObject("component", "claude-cfml.ClaudeAPI").init(form.apiKey)>
                <cfset result = claudeAPI.listModels()>

                <cfif result.success>
                    <div class="response success">
                        <h3>Available Models:</h3>
                        <cfloop array="#result.data#" index="model">
                            <div style="margin-bottom: 10px; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                                <strong>ID:</strong> <cfoutput>#model.id#</cfoutput><br>
                                <strong>Display Name:</strong> <cfoutput>#model.display_name#</cfoutput><br>
                                <strong>Type:</strong> <cfoutput>#model.type#</cfoutput><br>
                                <strong>Created:</strong> <cfoutput>#model.created_at#</cfoutput>
                            </div>
                        </cfloop>
                        <div class="usage">
                            <strong>Pagination:</strong> 
                            Has more: <cfoutput>#result.hasMore#</cfoutput>
                            <cfif len(result.firstId)>, First ID: <cfoutput>#result.firstId#</cfoutput></cfif>
                            <cfif len(result.lastId)>, Last ID: <cfoutput>#result.lastId#</cfoutput></cfif>
                        </div>
                    </div>
                <cfelse>
                    <div class="response error">
                        <h3>Error:</h3>
                        <div><cfoutput>#result.error#</cfoutput></div>
                        <cfif structKeyExists(result, "errorDetail") AND len(result.errorDetail)>
                            <div style="margin-top: 10px;"><strong>Details:</strong><br>
                            <cfoutput>#result.errorDetail#</cfoutput></div>
                        </cfif>
                    </div>
                </cfif>

                <cfcatch type="any">
                    <div class="response error">
                        <h3>Error:</h3>
                        <div>Exception: <cfoutput>#cfcatch.message#</cfoutput></div>
                        <div style="margin-top: 10px;"><strong>Details:</strong><br>
                        <cfoutput>#cfcatch.detail#</cfoutput></div>
                    </div>
                </cfcatch>
            </cftry>
        <cfelse>
            <div class="response error">
                <h3>Error:</h3>
                <div>Please provide an API key to list models.</div>
            </div>
        </cfif>
    <cfelseif structKeyExists(form, "submit") OR len(form.message)>
        <cfif len(form.apiKey) AND len(form.message)>
            <cftry>
                <cfset claudeAPI = createObject("component", "claude-cfml.ClaudeAPI").init(form.apiKey)>
                <cfset result = claudeAPI.sendMessage(
                    message = form.message,
                    model = form.model,
                    maxTokens = val(form.maxTokens),
                    temperature = val(form.temperature),
                    systemPrompt = form.systemPrompt
                )>

                <cfif result.success>
                    <div class="response success">
                        <h3>Response from Claude:</h3>
                        <div><cfoutput>#replace(result.response, chr(10), "<br>", "all")#</cfoutput></div>
                        
                        <div class="usage">
                            <strong>Usage:</strong> 
                            Input tokens: <cfoutput>#result.usage.input_tokens#</cfoutput>, 
                            Output tokens: <cfoutput>#result.usage.output_tokens#</cfoutput><br>
                            <strong>Model:</strong> <cfoutput>#result.model#</cfoutput>
                        </div>
                    </div>
                <cfelse>
                    <div class="response error">
                        <h3>Error:</h3>
                        <div><cfoutput>#result.error#</cfoutput></div>
                        <cfif structKeyExists(result, "errorDetail") AND len(result.errorDetail)>
                            <div style="margin-top: 10px;"><strong>Details:</strong><br>
                            <cfoutput>#result.errorDetail#</cfoutput></div>
                        </cfif>
                    </div>
                </cfif>

                <cfcatch type="any">
                    <div class="response error">
                        <h3>Error:</h3>
                        <div>Exception: <cfoutput>#cfcatch.message#</cfoutput></div>
                        <div style="margin-top: 10px;"><strong>Details:</strong><br>
                        <cfoutput>#cfcatch.detail#</cfoutput></div>
                    </div>
                </cfcatch>
            </cftry>
        <cfelse>
            <div class="response error">
                <h3>Error:</h3>
                <div>Please provide both an API key and a message.</div>
            </div>
        </cfif>
    </cfif>

    <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ccc;">
        <h3>About this API wrapper:</h3>
        <ul>
            <li>Uses the ClaudeAPI.cfc component written in CFScript</li>
            <li>Supports all current Claude models</li>
            <li>Handles both single messages and conversations</li>
            <li>Includes proper error handling and usage tracking</li>
        </ul>
        
        <h3>Example usage in your CFML code:</h3>
        <pre style="background-color: #f0f0f0; padding: 10px; border-radius: 4px;">
claudeAPI = createObject("component", "claude-cfml.ClaudeAPI").init("your-api-key-here");
result = claudeAPI.sendMessage("Hello, Claude!");

if (result.success) {
    writeOutput(result.response);
} else {
    writeOutput("Error: " & result.error);
}
        </pre>
    </div>
</body>
</html>