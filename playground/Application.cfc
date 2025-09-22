component {
    this.name = "ClaudeCFMLPlayground";
    this.applicationTimeout = createTimeSpan(0, 2, 0, 0);
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 0, 30, 0);
    
    // Create mapping to the claude-cfml directory
    this.mappings["/claude-cfml"] = getDirectoryFromPath(getCurrentTemplatePath()) & "../claude-cfml/";
}