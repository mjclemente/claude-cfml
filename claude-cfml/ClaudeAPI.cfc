component displayname="ClaudeAPI" hint="ColdFusion component for interacting with Claude/Anthropic API" {

    public ClaudeAPI function init(string apiKey = "", string baseURL = "https://api.anthropic.com/v1") {
        variables.apiKey = resolveApiKey(arguments.apiKey);
        variables.baseURL = arguments.baseURL;
        variables.defaultModel = "claude-sonnet-4-20250514";
        variables.anthropicVersion = "2023-06-01";
        variables.timeout = 30;
        
        return this;
    }

    public struct function sendMessage(
        required string message,
        string model = variables.defaultModel,
        numeric maxTokens = 1024,
        numeric temperature = 1,
        string systemPrompt = ""
    ) {
        var requestBody = buildMessageRequest(
            model = arguments.model,
            maxTokens = arguments.maxTokens,
            temperature = arguments.temperature,
            systemPrompt = arguments.systemPrompt
        );
        
        // Build messages array
        var messageStruct = {};
        messageStruct["role"] = "user";
        messageStruct["content"] = arguments.message;
        requestBody["messages"] = [messageStruct];
        
        return makeHttpRequest(endpoint = "/messages", method = "POST", body = requestBody);
    }

    public struct function sendConversation(
        required array messages,
        string model = variables.defaultModel,
        numeric maxTokens = 1024,
        numeric temperature = 1,
        string systemPrompt = ""
    ) {
        var requestBody = buildMessageRequest(
            model = arguments.model,
            maxTokens = arguments.maxTokens,
            temperature = arguments.temperature,
            systemPrompt = arguments.systemPrompt
        );
        
        requestBody["messages"] = arguments.messages;
        
        return makeHttpRequest(endpoint = "/messages", method = "POST", body = requestBody);
    }

    public struct function listModels(
        string beforeId = "",
        string afterId = "",
        numeric limit = 20
    ) {
        var queryParams = [];
        
        if (len(trim(arguments.beforeId))) {
            arrayAppend(queryParams, "before_id=" & urlEncodedFormat(arguments.beforeId));
        }
        if (len(trim(arguments.afterId))) {
            arrayAppend(queryParams, "after_id=" & urlEncodedFormat(arguments.afterId));
        }
        if (arguments.limit != 20) {
            arrayAppend(queryParams, "limit=" & arguments.limit);
        }
        
        var endpoint = "/models";
        if (arrayLen(queryParams)) {
            endpoint &= "?" & arrayToList(queryParams, "&");
        }
        
        return makeHttpRequest(endpoint = endpoint, method = "GET");
    }


    // PRIVATE METHODS

    private string function resolveApiKey(string providedKey = "") {
        var apiKey = "";
        
        // 1. Check if API key was passed in manually (highest priority)
        if (len(trim(arguments.providedKey))) {
            apiKey = trim(arguments.providedKey);
        }
        // 2. Check environment variables
        else if (structKeyExists(server.system.environment, "ANTHROPIC_API_KEY") && len(trim(server.system.environment.ANTHROPIC_API_KEY))) {
            apiKey = trim(server.system.environment.ANTHROPIC_API_KEY);
        }
        // 3. Check Java system properties
        else {
            try {
                var systemProps = createObject("java", "java.lang.System");
                var systemApiKey = systemProps.getProperty("anthropic.api.key", "");
                if (len(trim(systemApiKey))) {
                    apiKey = trim(systemApiKey);
                }
            } catch (any e) {
                // If we can't access system properties, continue without error
            }
        }
        
        if (!len(trim(apiKey))) {
            throw(
                type = "ClaudeAPI.MissingApiKey", 
                message = "API Key Required", 
                detail = "No API key found. Please provide it via parameter, ANTHROPIC_API_KEY environment variable, or anthropic.api.key system property."
            );
        }
        
        return apiKey;
    }

    private struct function buildMessageRequest(
        required string model,
        required numeric maxTokens,
        required numeric temperature,
        string systemPrompt = ""
    ) {
        var requestBody = {};
        requestBody["model"] = arguments.model;
        requestBody["max_tokens"] = arguments.maxTokens;
        requestBody["temperature"] = arguments.temperature;
        
        // Add system prompt if provided
        if (len(trim(arguments.systemPrompt))) {
            requestBody["system"] = arguments.systemPrompt;
        }
        
        return requestBody;
    }

    private struct function makeHttpRequest(
        required string endpoint,
        required string method,
        struct body = {}
    ) {
        var result = {};
        
        try {
            var requestUrl = variables.baseURL & arguments.endpoint;
            var httpResult = "";
            
            cfhttp(
                url = requestUrl,
                method = arguments.method,
                timeout = variables.timeout,
                result = "httpResult"
            ) {
                cfhttpparam(type = "header", name = "x-api-key", value = variables.apiKey);
                cfhttpparam(type = "header", name = "anthropic-version", value = variables.anthropicVersion);
                
                if (arguments.method == "POST" && !structIsEmpty(arguments.body)) {
                    cfhttpparam(type = "header", name = "Content-Type", value = "application/json");
                    cfhttpparam(type = "body", value = serializeJSON(arguments.body));
                }
            }
            
            result = processHttpResponse(httpResult, arguments.method);
            
        } catch (any e) {
            result["success"] = false;
            result["error"] = "Exception: " & e.message;
            result["errorDetail"] = e.detail;
        }
        
        return result;
    }

    private struct function processHttpResponse(required struct httpResult, required string method) {
        var result = {};
        
        if (arguments.httpResult.statusCode == "200 OK") {
            var responseData = deserializeJSON(arguments.httpResult.fileContent);
            result["success"] = true;
            result["rawResponse"] = responseData;
            
            // Handle different response formats based on endpoint/method
            if (arguments.method == "POST") {
                // Messages API response format
                result["response"] = responseData.content[1].text;
                result["usage"] = responseData.usage;
                result["model"] = responseData.model;
            } else if (arguments.method == "GET") {
                // Models list API response format
                result["data"] = responseData.data;
                result["hasMore"] = responseData.has_more;
                result["firstId"] = responseData.first_id;
                result["lastId"] = responseData.last_id;
            }
        } else {
            result["success"] = false;
            result["error"] = "HTTP Error: " & arguments.httpResult.statusCode;
            result["errorDetail"] = arguments.httpResult.fileContent;
        }
        
        return result;
    }

}