import CoreDomain

final class PullOfferExpression: Expression {
    var rawExpression: String?
    var parentExpression: Expression?
    
    func getTopParent() -> Expression{
        if let parent = self.parentExpression {
            return parent.getTopParent()
        } else {
            return self
        }
    }
    
    func getNodeVariables() -> [Variable] {
        fatalError("NOT IMPLEMENTED")
    }
}

extension PullOfferExpression {
    
    //SE COMPRUEBA QUE LOS PARÉNTESIS EN LA EXPRESIÓN ESTÉN BALANCEADOS. ES DECIR, MISMO NUMERO DE PARÉNTESIS IZQDOS QUE DCHOS
    func isBalanced() -> Bool {
        guard let strongExpression = self.rawExpression else {
            return false
        }
        
        let sequenceToCheck = strongExpression.map({$0})
        
        var stack = [Bracket]()
        for char in sequenceToCheck {
            if let bracket = Bracket(rawValue: char) {
                if let open = bracket.matchingOpen {
                    guard let last = stack.last, last == open  else {
                        return false
                    }
                    stack.removeLast()
                } else {
                    stack.append(bracket)
                }
            }
        }
        return stack.isEmpty
    }
    
    //SE COMPRUEBA QUE LOS OPERADORES DEVUELTOS POR EL ANALISIS LEXICO SEAN VALIDOS
    func hasValidOperators(validCharsForVariable: String, validCharsForConstant: String, validCharsForOperators: String) -> Bool {
        
        let validOperators = Operator.allOperators().map({$0.rawValue})
        
        guard let strongExpression = self.rawExpression else {
            return false
        }
        
        let engine = PullOfferLexicalEngine(rawExpression: strongExpression, validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators)
        do {
            let tokens = try engine.performLexicalAnalysis().filter({$0.type == .oper})
            if tokens.count > 0 {
                for i in 0 ... tokens.count-1 {
                    let currentToken = tokens[i]
                    if !validOperators.contains(currentToken.content as! String) {
                        return false
                    }
                }
            }
            
            return true
            
        } catch _ {
            return false
        }        
    }
    
    //SE COMPRUEBA QUE EL ORDEN DE LOS ELEMENTOS EN LA EXPRESIÓN SEA VÁLIDO. POR EJEMPLO, OPERADOR SEGUIDO DE VARIABLE O CONSTANTE, NUNCA OTRO OPERADOR
    func isValid(validCharsForVariable: String, validCharsForConstant: String, validCharsForOperators: String) -> Bool {
        
        guard let strongExpression = self.rawExpression else {
            return false
        }
        
        let engine = PullOfferLexicalEngine(rawExpression: strongExpression, validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators)
        do {
            let tokens = try engine.performLexicalAnalysis()
            if !hasValidOperators(validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators) {
                return false
            }
            
            var lastToken: Token? = nil
            for i in 0 ... tokens.count-1 {
                let currentToken = tokens[i]
                if let lastToken = lastToken {
                    if currentToken.type == .oper && !(lastToken.type == .variable || lastToken.type == .constant || lastToken.type == .parenthesisRight || lastToken.type == .squareBracketRight) {
                        return false
                    } else if (currentToken.type == .variable || currentToken.type == .constant) && (lastToken.type == .variable || lastToken.type == .constant) {
                        return false
                    } else if currentToken.type == .squareBracketLeft && (lastToken.type != .oper && lastToken.type != .parenthesisLeft) {
                        return false
                    }
                    
                } else {
                    if currentToken.type == .oper || currentToken.type == .parenthesisRight || currentToken.type == .squareBracketRight {
                        return false
                    }
                }
                
                lastToken = currentToken
            }
            
            return true
            
        } catch _ {
            return false
        }
    }
}
