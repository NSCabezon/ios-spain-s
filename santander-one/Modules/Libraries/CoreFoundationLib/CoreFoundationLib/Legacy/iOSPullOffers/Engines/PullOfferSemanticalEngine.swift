import Foundation
import CoreDomain

final class PullOfferSemanticalEngine: SemanticalEngine {
    
    internal var variablesNamesArray: [String]
    internal var variablesValuesArray: [Any]
    
    public init(variablesNamesArray: [String], variablesValuesArray: [Any]) {
        self.variablesNamesArray = variablesNamesArray
        self.variablesValuesArray = variablesValuesArray
    }
    
    func isValid(expression: Any) -> Bool {
        guard let expression = expression as? Expression else {
            return false
        }
        
        do {
            let result: PullOfferResult = try self.performSemanticalAnalysis(with: expression)
            guard result.result == .valid, let pullOfferVar = result.resultValue as? PullOfferVar, pullOfferVar.type == .logical else {
                return false
            }
            
            return (pullOfferVar.value as? Bool) ?? false
            
        } catch _ {
            return false
        }
    }
    
    func performSemanticalAnalysis(with node: Expression) throws -> PullOfferResult {
        
        var expressionToUse: Expression? = node
        if let parentOperation = node as? Operation {
            if parentOperation.lh == nil || parentOperation.rh == nil {
                expressionToUse = (parentOperation.lh == nil)
                    ? parentOperation.rh
                    : parentOperation.lh
            }
        }
        
        guard let operation = expressionToUse as? Operation else {
            throw NSError(domain: "NOT_AN_OPERATION: \(node.rawExpression ?? "")", code: 1, userInfo: nil)
        }
        
        let rawVariables = variablesNamesArray.map({PullOfferVar(value: $0, isVar: true)})
        let rawValues = variablesValuesArray.map({PullOfferVar(value: $0, isVar: false)})
        
        if !operation.hasAllVariablesNeeded(knownVariables: rawVariables) {
            throw NSError(domain: "NOT_AVAILABLE VARIABLES: \nFOUND: \(node.getNodeVariables())\nKNOWN VARIABLES: \(variablesNamesArray)", code: 1, userInfo: nil)
        }
        
        //HACER MATCH ENTRE variablesArray Y OPERATION
        return try evaluate(rule: operation, varsIds: rawVariables, varsValues: rawValues)
    }
    
    func evaluate(rule: Expression, varsIds: [Variable], varsValues: [Variable]) throws -> PullOfferResult {
        guard var operation = rule as? Operation else {
            throw NSError(domain: "NOT_AN_OPERATION: \(rule.rawExpression ?? "")", code: 1, userInfo: nil)
        }
        
        //REEMPLAZA LAS VARIABLES CON LOS VALORES REALES CON LOS QUE SE RESOLVERA
        replaceVariables(operation: &operation, varsIds: varsIds, varsValues: varsValues)
        
        return try operation.resolve(variables: varsIds)
    }
    
    private func replaceVariables(operation: inout Operation, varsIds: [Variable], varsValues: [Variable]) {
        
        for side in [Utils.Side.left, Utils.Side.right] {
            let elem = side == .left
                ? operation.lh
                : operation.rh
            
            if var element = elem as? Variable, element.type == .variable || element.type == .array {
                if element.type == .variable {
                    var replacement = getVariableToReplace(varToReplace: element, varsIds: varsIds, varsValues: varsValues)
                    replacement?.parentExpression = operation.parentExpression
                    side == .left
                        ? (operation.lh = replacement)
                        : (operation.rh = replacement)
                } else if element.type == .array, var array = element.value as? [Variable], array.count > 0 {
                    //ESTE CASO SE DARÁ CUANDO HAY ARRAY DE CONSTANTES O VARIABLES EN EL HIJO
                    for i in 0 ... array.count-1 {
                        let arrayVar = array[i]
                        if let replacement = getVariableToReplace(varToReplace: arrayVar, varsIds: varsIds, varsValues: varsValues) {
                            array.remove(at: i)
                            array.insert(replacement, at: i)
                        }
                    }
                    
                    element.value = array
                }
            } else if var element = elem as? Operation {
                replaceVariables(operation: &element, varsIds: varsIds, varsValues: varsValues)
            }
        }
    }
    
    private func getVariableToReplace(varToReplace: Variable, varsIds: [Variable], varsValues: [Variable]) -> Variable? {
        if let index = varsIds.firstIndex(where: {$0.value as? String == varToReplace.value as? String}) {
            return varsValues[index]
        }
        
        return nil
    }
}
