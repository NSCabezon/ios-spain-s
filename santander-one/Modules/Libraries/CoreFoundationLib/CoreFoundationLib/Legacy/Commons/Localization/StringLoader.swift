
public protocol StringLoader {
    
    func updateCurrentLanguage(language: Language)
    
    func getCurrentLanguage() -> Language
    
    func getString(_ key: String) -> LocalizedStylableText
    
    func getString(_ key: String, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText
    
    func getQuantityString(_ key: String, _ count: Int, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText
    
    func getQuantityString(_ key: String, _ count: Double, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText

    func getWsErrorString(_ key: String) -> LocalizedStylableText
    func getWsErrorIfPresent(_ key: String) -> LocalizedStylableText?
    func getWsErrorWithNumber(_ key: String, _ phone: String) -> LocalizedStylableText
}
