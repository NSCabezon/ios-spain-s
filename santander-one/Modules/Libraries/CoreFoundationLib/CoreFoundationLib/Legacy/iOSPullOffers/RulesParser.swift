import Fuzi

public class RulesParser: Parser {
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    public func deserialize(_ parseable: [RuleDTO]) -> String? {
        var output = "<rules>"
        
        for rule in parseable {
            output += "<rule>"
            output += "<id>\(rule.id)</id>"
            output += "<expression>\(rule.expression)</expression>"
            output += "</rule>"
        }
        
        output += "</rules>"
        return output
    }
    
    public func serialize(_ responseString: String) -> [RuleDTO]? {
        var output = [RuleDTO]()
        if let document = try? XMLDocument(string: responseString) {
            if let rules = document.root {
                for rule in rules.children(tag: "rule") {
                    let id = rule.firstChild(tag: "id")?.stringValue ?? ""
                    let expression = rule.firstChild(tag: "expression")?.stringValue ?? ""
                    output.append(RuleDTO(id: id, expression: expression))
                }
            }
        }
        
        return output
    }
    
}
