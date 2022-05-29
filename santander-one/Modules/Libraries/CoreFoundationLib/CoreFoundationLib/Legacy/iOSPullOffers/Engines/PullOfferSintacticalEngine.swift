import Foundation
import CoreDomain

final class PullOfferSintacticalEngine: SintacticalEngine {
    
    private var originExpression: String
    private var tokens: [Token]
    internal let validCharsForVariable: String
    internal let validCharsForConstant: String
    internal let validCharsForOperators: String
    
    public init(originExpression: String, tokens: [Token], validCharsForVariable: String, validCharsForConstant: String, validCharsForOperators: String) {
        self.originExpression = originExpression
        self.tokens = tokens
        self.validCharsForVariable = validCharsForVariable
        self.validCharsForConstant = validCharsForConstant
        self.validCharsForOperators = validCharsForOperators
    }
    
    func isValid(expression: Any) -> Bool {
        guard let tokens = expression as? [Token], tokens.count > 0 else {
            return false
        }
        
        do {
            guard (try self.performSintacticalAnalysis()) != nil else {
                return false
            }
            
            return true
            
        } catch _ {
            return false
        }
    }
    
    func performSintacticalAnalysis() throws -> Expression? {
        if tokens.count == 0 {
            return nil
        }
        
        let parentExpression = PullOfferExpression()
        parentExpression.rawExpression = originExpression
        
        //COMPROBAR BALANCEO
        if !parentExpression.isBalanced() {
            throw NSError(domain: "NOT_BALANCED_EXPRESSION: \(parentExpression.rawExpression ?? "")", code: 1, userInfo: nil)
        }
        
        //PARSEO POSIBLES ARRAYS -> SON SUSTITUIDOS "[", ",", "]" Y CREADO TOKEN TIPO ARRAY
        parseArrays()
        
        //COMPROBAR OPERADORES
        if !parentExpression.hasValidOperators(validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators) {
            throw NSError(domain: "NOT_VALID_OPERATOR_FOUND: \(parentExpression.rawExpression ?? "")", code: 1, userInfo: nil)
        }
        
        //COMPROBAR ORDEN OPERANDOS Y OPERADORES
        if !parentExpression.isValid(validCharsForVariable: validCharsForVariable, validCharsForConstant: validCharsForConstant, validCharsForOperators: validCharsForOperators) {
            throw NSError(domain: "NOT_VALID_EXPRESSION: \(parentExpression.rawExpression ?? "")", code: 1, userInfo: nil)
        }
        
        var currentExpression: PullOfferOperation?
        for token in tokens {
            if token.type == .parenthesisLeft {
                let newCurrentExpression = PullOfferOperation()
                if let current = currentExpression {
                    newCurrentExpression.parentExpression = current
                    if current.lh == nil {
                        current.setLh(lh: newCurrentExpression)
                    } else {
                        current.setRh(rh: newCurrentExpression)
                    }
                }
                
                currentExpression = newCurrentExpression
                
            } else if token.type == .parenthesisRight{
                if let current = currentExpression {
                    if let parentExpression = current.parentExpression as? PullOfferOperation {
                        if parentExpression.lh == nil {
                            parentExpression.setLh(lh: current)
                        } else {
                            parentExpression.setRh(rh: current)
                        }
                        
                        currentExpression = parentExpression
                    } else {
                        let newParentExpression = PullOfferOperation()
                        current.parentExpression = newParentExpression
                        newParentExpression.setLh(lh: current)
                        currentExpression = newParentExpression
                    }
                }
                
            } else if token.type == .variable || token.type == .constant {
                let newVar = PullOfferVar(value: token.content, isVar: false)
                
                if currentExpression == nil {
                    currentExpression = PullOfferOperation()
                }
                
                newVar.parentExpression = currentExpression
                if !insertVarInOperation(operation: currentExpression!, variable: newVar) {
                    //SI HA HABIDO FALLO AL INSERTAR ES QUE ESTAMOS CON OTRA OPERACION EN UN HIJO
                    let newSon = PullOfferOperation()
                    newSon.parentExpression = currentExpression
                    let _ = insertVarInOperation(operation: newSon, variable: newVar)
                    currentExpression = newSon
                }
                
            } else if token.type == .oper {
                if let current = currentExpression, let oper = token.getOperator() {
                    if let currentNodeOper = current.oper {
                        //SI YA TIENE OPERADOR ES QUE NECESITAMOS INSERTAR HIJO NUEVO -> PUEDE SER NUEVO HIJO DERECHO O SER PADRE DEL NODO ACTUAL (EL ACTUAL SERIA HIJO IZQDO), DEPENDIENDO DE LA PRIORIDAD DE OPERADOR
                        if oper < currentNodeOper {
                            let newParent = PullOfferOperation()
                            if let currentNodeParent = current.parentExpression {
                                newParent.parentExpression = currentNodeParent
                                if let currentParentOperation = currentNodeParent as? PullOfferOperation {
                                    if let currentParentLeftSon = currentParentOperation.lh as? PullOfferOperation {
                                        (currentParentLeftSon == current)
                                            ? currentParentOperation.setLh(lh: newParent)
                                            : currentParentOperation.setRh(rh: newParent)
                                    } else if let currentParentRightSon = currentParentOperation.rh as? PullOfferOperation {
                                        (currentParentRightSon == current)
                                            ? currentParentOperation.setRh(rh: newParent)
                                            : currentParentOperation.setLh(lh: newParent)
                                    }
                                }
                            }
                            current.parentExpression = newParent
                            newParent.setOperator(oper: oper)
                            newParent.setLh(lh: current)
                            currentExpression = newParent
                        } else {
                            let newSon = PullOfferOperation()
                            newSon.parentExpression = current
                            newSon.setOperator(oper: oper)
                            if let rightVar = current.rh {
                                newSon.setLh(lh: rightVar)
                            }
                            current.setRh(rh: newSon)
                            currentExpression = newSon
                        }
                    } else {
                        current.setOperator(oper: oper)
                    }
                } else {
                    print("NO DEBERIA DE PASAR")
                }
            }
        }
        
        currentExpression?.printFullTree()
        
        return currentExpression?.getTopParent()
    }
    
    private func parseArrays() {
        guard self.tokens.count > 0, self.tokens.contains(where: {$0.type == .squareBracketLeft}) else {
            return
        }
        
        var arraysToReplace = [Token]()
        var indexesToReplace = [(Int, Int)]()
        var currentArray: Token? = nil
        
        var leftBracketIndex = -1
        var lastArrayIndex = -1
        for index in 0 ..< self.tokens.count {
            let token = self.tokens[index]
            if token.type == .squareBracketLeft {
                currentArray = Token(type: .constant, content: SpecialChars.squareBracketLeft.string)
                leftBracketIndex = index
                lastArrayIndex = -1
            } else {
                if let current = currentArray, token.type == .variable || token.type == .constant || token.type == .comma || token.type == .squareBracketRight, let stringCurrentContent = current.content as? String, let tokenStringContent = token.content as? String {
                    lastArrayIndex = index
                    current.content = stringCurrentContent+tokenStringContent
                }
            }
            
            if (token.type == .squareBracketRight || index == self.tokens.count-1) && leftBracketIndex != -1, let currentArrayUW = currentArray {
                arraysToReplace.append(currentArrayUW)
                indexesToReplace.append((leftBracketIndex, lastArrayIndex))
                currentArray = nil
            }
        }
        
        var indexToSubstract = 0
        for j in 0 ... arraysToReplace.count-1 {
            let range: Range = indexesToReplace[j].0-indexToSubstract ..< indexesToReplace[j].1-indexToSubstract+1
            self.tokens.removeSubrange(range)
            self.tokens.insert(arraysToReplace[j], at: range.lowerBound)
            
            indexToSubstract += (indexesToReplace[j].1 - indexesToReplace[j].0)
        }
    }
    
    private func insertVarInOperation(operation: Operation, variable: Variable) -> Bool {
        if operation.lh == nil {
            operation.setLh(lh: variable)
            return true
        } else if operation.rh == nil {
            operation.setRh(rh: variable)
            return true
        } else {
            //TRYING TO INSERT IN A COMPLETE OPERATION
            return false
        }
    }
    
}
