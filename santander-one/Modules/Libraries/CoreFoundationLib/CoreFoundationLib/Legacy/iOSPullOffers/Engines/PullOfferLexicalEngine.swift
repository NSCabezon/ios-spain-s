import Foundation
import CoreDomain

class PullOfferLexicalEngine: LexicalEngine {
    
    private var originExpression: String
    internal let validCharsForVariable: String
    internal let validCharsForConstant: String
    internal let validCharsForOperators: String

    public init(rawExpression: String, validCharsForVariable: String, validCharsForConstant: String, validCharsForOperators: String) {
        self.originExpression = rawExpression
        self.validCharsForVariable = validCharsForVariable
        self.validCharsForConstant = validCharsForConstant
        self.validCharsForOperators = validCharsForOperators
    }
    
    func isValid(expression: Any) -> Bool {
        guard let expression = expression as? String, expression != "" else {
            return false
        }

        do {
            let tokens = try self.performLexicalAnalysis()
            return tokens.count > 0
            
        } catch _ {
            return false
        }
    }
    
    func performLexicalAnalysis() throws -> [Token] {
        
        var tokens: [Token] = []

        let expressionChars = originExpression.map({$0})
        var lastToken: Token?
        var containsCoincidence = false
        var containsIndex = 0
        
        for i in 0...expressionChars.count-1 {
            let currentChar = expressionChars[i]
            
            let isStringConstant = (lastToken?.content as? String)?.map({$0 == SpecialChars.escapeQuote.char}).filter({$0 == true}).count ?? 0 == 1
            let lastWasFinishedString = (lastToken?.content as? String)?.map({$0 == SpecialChars.escapeQuote.char}).filter({$0 == true}).count ?? 0 == 2
            
            if let specialCharToken = SpecialChars.parse(input: currentChar)?.tokenType, (specialCharToken != .comma) || (lastWasFinishedString || !isStringConstant) {
                containsCoincidence = false
                lastToken = createNewResult(newString: String(currentChar), type: specialCharToken)
                if let lastTokenUW = lastToken {
                    tokens.append(lastTokenUW)
                }
            } else if currentChar == SpecialChars.space.char && !isStringConstant {
                containsCoincidence = false
            } else if Operator.allOperators().filter({$0.isTextualOperator == true}).map({$0.rawValue.first!}).contains(currentChar) && ((i-1>=0) ? expressionChars[i-1] == SpecialChars.space.char : false) {
                //IF CURRENT CHAR IS C OR N FROM CONTAINS AND NO_CONTAINS AND PREVIOUS CHAR WAS SPACE
                containsCoincidence = true
                containsIndex = containsCoincidence ? i : 0
            } else {
                
                if containsCoincidence {
                    for oper in Operator.allOperators().filter({$0.isTextualOperator == true}).map({$0.rawValue}) {
                        if let checkOperator = checkContains(toCheck: oper, expressionChars: expressionChars, charIndex: i, coincidenceOrigin: containsIndex) {
                            lastToken = checkOperator.1
                            containsCoincidence = checkOperator.0
                            
                            if let lastTokenUW = lastToken {
                                tokens.append(lastTokenUW)
                            }
                            break
                        }
                    }
                } else {
                    containsCoincidence = false
                    let lastWasSpace = (i-1>=0) ? expressionChars[i-1] == SpecialChars.space.char : false
                    let containsSingleQuote = (lastToken?.content as? String)?.contains(SpecialChars.singleQuote.char) ?? false
                    
                    if let strongLast = lastToken, !lastWasSpace || lastWasSpace && isStringConstant, strongLast.type != .parenthesisLeft, strongLast.type != .parenthesisRight {
                        let containsDoubleQuote = (strongLast.content as? String)?.map({$0 == SpecialChars.singleQuote.char}).filter({$0 == true}).count ?? 0 > 1
                        
                        if let content = strongLast.content as? String {
                            if strongLast.type == .variable && validCharsForVariable.contains(currentChar.description) && !containsDoubleQuote {
                                tokens.last!.content = content+currentChar.description
                            } else if strongLast.type == .constant && validCharsForConstant.contains(currentChar.description) && ((!containsSingleQuote && !validCharsForOperators.contains(currentChar.description)) || containsSingleQuote) && !containsDoubleQuote {
                                tokens.last!.content = content+currentChar.description
                            } else if strongLast.type == .oper && validCharsForOperators.contains(currentChar.description) && !containsDoubleQuote {
                                tokens.last!.content = content+currentChar.description
                            } else {
                                if let newLastToken = createNewResult(currentChar: currentChar) {
                                    lastToken = newLastToken
                                    tokens.append(newLastToken)
                                } else {
                                    throw NSError(domain: "NOT_ALLOWED_CHAR_IN_EXPRESSION: \(originExpression) at char: \(currentChar.description)(\(i))", code: 1, userInfo: nil)
                                }
                            }
                        }
                    } else {
                        //NUEVO
                        if let newLastToken = createNewResult(currentChar: currentChar) {
                            lastToken = newLastToken
                            tokens.append(newLastToken)
                        } else {
                            throw NSError(domain: "NOT_ALLOWED_CHAR_IN_EXPRESSION: \(originExpression) at char: \(currentChar.description)(\(i))", code: 1, userInfo: nil)
                        }
                    }
                }
            }
        }
        
        return tokens
    }
    
    private func checkContains(toCheck: String, expressionChars: [Character], charIndex: Int, coincidenceOrigin: Int) -> (Bool, Token)?{
        if expressionChars[coincidenceOrigin] == toCheck.map({$0}).first! {
            if expressionChars[coincidenceOrigin...charIndex] == toCheck.map({$0})[0...charIndex-coincidenceOrigin] {
                //COINCIDES (PARTIALLY OR TOTALLY)
                if charIndex - coincidenceOrigin == toCheck.map({$0}).count-1 {
                    //INSERT OPERATOR CONTAINS
                    let lastToken = createNewResult(newString: toCheck, type: .oper)
                    return (false, lastToken)
                }
            } else {
                //ESTABA COINCIDIENDO CON CONTAINS O NO_CONTAINS, PERO DEJO DE COINCIDIR. POR EJEMPLO: CONTAINW. TOMAMOS COMO VARIABLE
                let currentChars = expressionChars[coincidenceOrigin...charIndex]
                let lastToken = createNewResult(newString: currentChars.map({$0.description}).joined(), type: .variable)
                return (false, lastToken)
            }
        }
        
        return nil
    }
    
    private func createNewResult(currentChar: Character) -> Token? {
        if (currentChar == SpecialChars.escapeQuote.char || currentChar == "t" || currentChar == "f" || currentChar == SpecialChars.singleQuote.char || (currentChar.description as NSString).integerValue != 0) && validCharsForConstant.contains(currentChar.description) {
            //NUEVO TOKEN CONSTANTE STRING
            return createNewResult(newString: currentChar.description, type: .constant)
        } else if validCharsForOperators.contains(currentChar.description) {
            //NUEVO TOKEN OPERADOR STRING
            return createNewResult(newString: currentChar.description, type: .oper)
        } else if validCharsForVariable.contains(currentChar.description) {
            //NUEVO TOKEN VARIABLE
            return createNewResult(newString: currentChar.description, type: .variable)
        } else {
            return nil
        }
    }
    
    private func createNewResult(newString: String, type: TokenType) -> Token {
        let newToken = Token(type: type, content: newString)
        return newToken
    }
    
}

extension PullOfferLexicalEngine {
    func getSeparatedTokens(tokens: [Token]) -> [String] {
        return tokens.map({$0.content as! String})
    }
}
