import CoreDomain

public class BaseEngine {
    //VALID VARIABLES, CONSTANTS AND OPERATORS
    internal let validCharsForVariable = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890"
    internal let validCharsForConstant = "abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ_1234567890\"'/- ,"
    internal let validCharsForOperators = "<>=*/+-!&|"
    var variablesArray: [String]
    var variablesValuesArray: [Any]

    public init(variablesArray: [String] = [], variablesValuesArray: [Any] = []) {
        self.variablesArray = variablesArray
        self.variablesValuesArray = variablesValuesArray
    }
}

extension BaseEngine: Engine {
    public func isValid(expression: Any) -> Bool {
        guard let expression = expression as? String, expression != "" else {
            return false
        }
        let lexicalEngine = PullOfferLexicalEngine(rawExpression: expression, validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators)
        if lexicalEngine.isValid(expression: expression) == false {
            return false
        }
        do {
            let tokens = try lexicalEngine.performLexicalAnalysis()
            let sintacticalEngine = PullOfferSintacticalEngine(originExpression: expression, tokens: tokens, validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators)
            if sintacticalEngine.isValid(expression: tokens) == false {
                return false
            }
            guard let pullOfferExpression = try sintacticalEngine.performSintacticalAnalysis() else {
                return false
            }
            let semanticalEngine = PullOfferSemanticalEngine(variablesNamesArray: variablesArray, variablesValuesArray: variablesValuesArray)
            return semanticalEngine.isValid(expression: pullOfferExpression)
        } catch _ {
            return false
        }
    }
}

extension BaseEngine: EngineInterface {
    public func resetEngine() {
        variablesArray.removeAll()
        variablesValuesArray.removeAll()
    }
    
    public func addRule(identifier: String, value: Any) {
        if let index = variablesArray.firstIndex(of: identifier) {
            variablesValuesArray[index] = value
        } else {
            variablesArray.append(identifier)
            variablesValuesArray.append(value)
        }
    }
    
    public func addRules(rules: [String: Any]) {
        for key in rules.keys {
            if let value = rules[key] {
                addRule(identifier: key, value: value)
            }
        }
    }
}
