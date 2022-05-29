public protocol EngineInterface {
    func isValid(expression: Any) -> Bool
    func resetEngine()
    func addRule(identifier: String, value: Any)
    func addRules(rules: [String: Any])
}
