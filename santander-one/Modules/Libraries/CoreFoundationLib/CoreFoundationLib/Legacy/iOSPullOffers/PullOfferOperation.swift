import Foundation
import CoreDomain

final class PullOfferOperation: Operation {
    
    var lh: Expression?
    var rh: Expression?
    var oper: Operator?
    var rawExpression: String?
    var parentExpression: Expression?
    
    func setLh(lh: Expression) {
        self.lh = lh
    }
    
    func setRh(rh: Expression) {
        self.rh = rh
    }
    
    func setOperator(oper: Operator) {
        self.oper = oper
    }
    
    func getTopParent() -> Expression {
        if let parent = self.parentExpression {
            return parent.getTopParent()
        } else {
            return self
        }
    }
    
    func getNodeVariables() -> [Variable] {
        var output: [Variable] = []
        
        if let lh = self.lh {
            output.append(contentsOf: lh.getNodeVariables())
        }
        
        if let rh = self.rh {
            output.append(contentsOf: rh.getNodeVariables())
        }
        
        return output
    }
    
    //PARA COMPROBAR SI LA OPERACION SE PUEDE TIENEN TODAS LAS VARIABLES A SUSTITUIR
    func hasAllVariablesNeeded(knownVariables: [Variable]) -> Bool {
        let nodeVariables = self.getNodeVariables().filter({$0.type == .variable})
        
        for variable in nodeVariables {
            if !knownVariables.contains(where: {$0.type == variable.type}) {
                return false
            }
        }
        
        return true
    }
    
    func resolve(variables: [Variable]) throws -> PullOfferResult {
        
        var lhUW: Variable? = nil
        var rhUW: Variable? = nil
        
        for side in [Utils.Side.left, Utils.Side.right] {
            let elem = side == .left
                ? self.lh
                : self.rh
            
            if let elemVar = elem as? Variable {
                side == .left
                    ? (lhUW = elemVar)
                    : (rhUW = elemVar)
                
            } else if let elemOp = elem as? PullOfferOperation {
                let elemResult = try elemOp.resolve(variables: variables)
                if elemResult.result == .valid, let elemValue = elemResult.resultValue as? PullOfferVar {
                    side == .left
                        ? (lhUW = elemValue)
                        : (rhUW = elemValue)
                }
            }
        }
        
        //ESTE CASO ES PARA CUANDO EL MOTOR HA GENERADO UNA EXPRESION SIN OPERADOR Y CON UNO DE LOS HIJOS, COMO POR EJEMPLO EL RESULTADO DE LA EXPRESION (5)
        if oper == nil && ((lhUW != nil && rhUW == nil) || (lhUW == nil && rhUW != nil)) {
            let variableNotNil = (lhUW != nil) ? lhUW : rhUW
            if let variableNotNil = variableNotNil, let value = variableNotNil.value, let type = variableNotNil.type {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: value, type: type))
            }
        }
        
        guard let lh = lhUW, let rh = rhUW else {
            throw NSError(domain: "VARIABLES NOT FOUND: \nLEFT: \(String(describing: lhUW))\nRIGHT: \(String(describing: rhUW))", code: 1, userInfo: nil)
        }
        
        guard let operUW = oper else {
            throw NSError(domain: "OPERATOR NOT FOUND", code: 1, userInfo: nil)
        }
        
        if !operUW.matchesWithVariables(leftVar: lh, rightVar: rh) {
            throw NSError(domain: "VARIABLES NOT MATCHING: \nOPER: \(operUW.type())\nLEFT: \(lh.value is [PullOfferVar] ? (lh.value as! [PullOfferVar]).map({$0.value}) : [lh.value])\nRIGHT: \(rh.value is [PullOfferVar] ? (rh.value as! [PullOfferVar]).map({$0.value}) : [rh.value])", code: 1, userInfo: nil)
        }
        
        switch operUW {
        case .and:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: leftVar && rightVar, type: .logical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .or:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: leftVar || rightVar, type: .logical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .equal:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: leftVar == rightVar, type: .logical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .notEqual:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: !(leftVar == rightVar), type: .logical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .greaterThan:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: leftVar > rightVar, type: .logical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .greaterOrEqualThan:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: leftVar == rightVar || leftVar > rightVar, type: .logical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .lessThan:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: leftVar < rightVar, type: .logical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .lessOrEqualThan:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: leftVar == rightVar || leftVar < rightVar, type: .logical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .contains:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar, let containsResult = leftVar.contains(rhs: rightVar)?.value as? Bool {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: containsResult, type: .logical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .no_contains:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar, let containsResult = leftVar.contains(rhs: rightVar)?.value as? Bool {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: !containsResult, type: .logical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .length:
            //TODO: HACER OPERACION CON length
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .indexOf:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar, let indexResult = leftVar.indexOf(rhs: rightVar)?.value as? Int {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: indexResult, type: .arithmetical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .plus:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar, let addResult = leftVar + rightVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: addResult, type: .arithmetical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .minus:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar, let subsResult = leftVar - rightVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: subsResult, type: .arithmetical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .multiply:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar, let multiplyResult = leftVar * rightVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: multiplyResult, type: .arithmetical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        case .divide:
            if let leftVar = lh as? PullOfferVar, let rightVar = rh as? PullOfferVar, let divideResult = leftVar / rightVar {
                return PullOfferResult(idRule: "", result: .valid, resultError: nil, resultValue: PullOfferVar(value: divideResult, type: .arithmetical))
            }
            return PullOfferResult(idRule: "", result: .error, resultError: nil, resultValue: nil)
        }
    }
    
    func printFullTree() {
        let topParent = (self as Expression).getTopParent()
        if let topOperation = topParent as? Operation {
            let _ = topOperation.printTree(level: 0)
        }
    }
    
    func printTree(level: Int?) -> String {
        let topOperation = self as Operation
        
        if (topOperation.lh as? Operation) != nil || (topOperation.rh as? Operation) != nil {
            if let oper = topOperation.oper {
                print("\n LEVEL: \(level ?? 0) : \(oper.rawValue)")
            }
        }
        
        var leftSonString = ""
        var sonOperatorString = ""
        var rightSonString = ""
        
        if let leftSon = topOperation.lh {
            if let leftSonOperation = leftSon as? Operation {
                let _ = leftSonOperation.printTree(level: level != nil ? level! + 1 : nil)
            } else if let leftSonVariable = leftSon as? Variable {
                leftSonString = "\(leftSonVariable.value ?? "NIL LEFT SON")"
            }
        }
        
        if (topOperation.lh as? Variable) != nil && (topOperation.rh as? Variable) != nil {
            if let oper = topOperation.oper {
                sonOperatorString = "\(oper.rawValue)"
            }
        }
        
        if let rightSon = topOperation.rh {
            if let rightSonOperation = rightSon as? Operation {
                let _ = rightSonOperation.printTree(level: level != nil ? level! + 1 : nil)
            } else if let rightSonVariable = rightSon as? Variable {
                rightSonString = "\(rightSonVariable.value ?? "NIL RIGHT SON")"
            }
        }
        
        var output = ""
        if "\(leftSonString)\(sonOperatorString)\(rightSonString)" != "" {
            if leftSonString != "" {
                output += "\(leftSonString) "
            }
            if sonOperatorString != "" {
                output += "\(sonOperatorString) "
            }
            if rightSonString != "" {
                output += "\(rightSonString)"
            }
            
            var levelToShow = level
            if (leftSonString == "" && rightSonString != "") || (rightSonString == "" && leftSonString != "") {
                levelToShow = levelToShow != nil ? levelToShow!+1 : 0
            }
            
            print("\n LEVEL: \(levelToShow ?? 0) : \(output)")
        }
        return output
    }
}

extension PullOfferOperation: Equatable {
    static func == (lhs: PullOfferOperation, rhs: PullOfferOperation) -> Bool {
        var sameLeftSon = false
        var sameRightSon = false
        
        if let leftLeftSonOp = lhs.lh as? PullOfferOperation, let rightLeftSonOp = rhs.lh as? PullOfferOperation {
            sameLeftSon = leftLeftSonOp == rightLeftSonOp
        } else {
            if let leftLeftSonVar = lhs.lh as? PullOfferVar, let rightLeftSonVar = rhs.lh as? PullOfferVar {
                sameLeftSon = ((leftLeftSonVar.value as? String) == (rightLeftSonVar.value as? String)) && (leftLeftSonVar.type == rightLeftSonVar.type)
            }
        }
        
        if let leftRightSonOp = lhs.rh as? PullOfferOperation, let rightRightSonOp = rhs.rh as? PullOfferOperation {
            sameRightSon = leftRightSonOp == rightRightSonOp
        }else {
            if let leftRightSonVar = lhs.rh as? PullOfferVar, let rightRightSonVar = rhs.rh as? PullOfferVar {
                sameRightSon = ((leftRightSonVar.value as? String) == (rightRightSonVar.value as? String)) && (leftRightSonVar.type == rightRightSonVar.type)
            }
        }
        
        return sameLeftSon && sameRightSon
    }
}
