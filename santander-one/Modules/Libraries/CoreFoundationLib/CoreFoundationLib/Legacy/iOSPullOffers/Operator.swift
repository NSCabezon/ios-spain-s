//
//  Operator.swift
//  IOS-Pull-Offers
//
//  Created by Carlos Pérez Pérez on 4/6/18.
//  Copyright © 2018 Carlos Pérez Pérez. All rights reserved.
//

public enum Operator: String {
    //TODO: ESTUDIAR CASO DE NEGACION "!" -> CAMBIARIA PRIMERAS FASES ANALISIS SINTACTICO, POR EJEMEPLO: DOS OPERADORES SEGUIDOS (a==true && !(b>4))
    
    //AL AÑADIR UN NUEVO OPERADOR, SE DEBERÁ METER EN LOS METODOS QUE EXTIENDEN Operator, EN EL METODO getOperator() DE LA CLASE TOKEN Y EN LAS CLASES PULLOFFEROPERATION Y PULLOFFERVAR
    case equal = "=="
    case notEqual = "!="
    case greaterThan = ">"
    case greaterOrEqualThan = ">="
    case lessThan = "<"
    case lessOrEqualThan = "<="
    case contains = "contains"
    case no_contains = "no_contains"
    case length = "length"
    case indexOf = "indexOf"
    case and = "&&"
    case or = "||"
    case multiply = "*"
    case divide = "/"
    case plus = "+"
    case minus = "-"
}

public enum OperatorType: Int {
    case logical = 0
    case arithmetical = 1
}

public extension Operator {
    
    var isTextualOperator: Bool {
        return self == .contains || self == .no_contains || self == .length || self == .indexOf
    }
    
    static func allOperators() -> [Operator] {
        return [.equal, .notEqual, .greaterThan, .greaterOrEqualThan, .lessThan, .lessOrEqualThan, .contains, .no_contains, .length, .indexOf, .and, .or, .multiply, .divide, .plus, .minus]
    }
    
    func type() -> OperatorType {
        switch self {
        case .equal, .notEqual, .greaterThan, .greaterOrEqualThan, .lessThan, .lessOrEqualThan, .contains, .no_contains, .and, .or:
            return .logical
        default:
            return .arithmetical
        }
    }
    
    //COMPROBACION DE SI CONCUERDA TIPO DE LOS OPERANDOS Y EL OPERADOR
    func matchesWithVariables(leftVar: Variable, rightVar: Variable) -> Bool {
        guard let leftType = leftVar.type, let rightType = rightVar.type else {
            return false
        }
        
        if leftType == .array || rightType == .array {
            
            var leftVarForIter = leftVar
            if let leftVarValue = leftVar.value as? Variable {
                leftVarForIter = leftVarValue
            }
            var rightVarForIter = rightVar
            if let rightVarValue = rightVar.value as? Variable {
                rightVarForIter = rightVarValue
            }
            
            return matchesArrayVariables(leftVar: leftVarForIter, rightVar: rightVarForIter)
        } else if self.type() == .arithmetical {
            return leftType == .arithmetical && rightType == .arithmetical
        } else if self.type() == .logical {
            if leftType == rightType && (self == .contains || self == .no_contains) {
                return leftType == .string
            } else {
                return leftType == rightType
            }
        }
        
        return false
    }
    
    private func matchesArrayVariables(leftVar: Variable, rightVar: Variable) -> Bool {
        guard let leftType = leftVar.type, let rightType = rightVar.type else {
            return false
        }
        
        var leftArrayElementType: VarType? = nil
        var rightArrayElementType: VarType? = nil
        if leftType == .array, let leftValueArray = leftVar.value as? [Variable], let leftValue = leftValueArray.first, let newLeftType = leftValue.type {
            //COMPRUEBO SI TODOS LOS ELEMENTOS DEL ARRAY TIENEN MISMO TIPO
            if leftValueArray.filter({$0.type == leftValueArray.first?.type}).count != leftValueArray.count {
                return false
            }
            
            leftArrayElementType = newLeftType
        }
        if rightType == .array, let rightValueArray = rightVar.value as? [Variable], let rightValue = rightValueArray.first, let newRightType = rightValue.type {
            //COMPRUEBO SI TODOS LOS ELEMENTOS DEL ARRAY TIENEN MISMO TIPO
            if rightValueArray.filter({$0.type == rightValueArray.first?.type}).count != rightValueArray.count {
                return false
            }
            
            rightArrayElementType = newRightType
        }
        
        if let leftArrayElementUWType = leftArrayElementType, let rightArrayElementUWType = rightArrayElementType, leftArrayElementUWType == rightArrayElementUWType {
            //LOS DOS SON ARRAYS
            return self == .equal || self == .notEqual || self == .contains || self == .no_contains
        } else {
            if let leftArrayElementUWType = leftArrayElementType, leftArrayElementUWType == rightType {
                //ELEMENTO DE LA IZQDA ES ARRAY, DERECHO ES VARIABLE SIMPLE
                if rightType == .arithmetical {
                    return self == .contains || self == .no_contains || self == .greaterThan || self == .greaterOrEqualThan || self == .lessThan || self == .lessOrEqualThan || self == .indexOf
                } else {
                    return self == .contains || self == .no_contains || self == .indexOf
                }
            } else if let rightArrayElementUWType = rightArrayElementType, leftType == rightArrayElementUWType {
                //ELEMENTO DE LA DCHA ES ARRAY, IZQDO ES VARIABLE SIMPLE
                if leftType == .arithmetical {
                    return self == .greaterThan || self == .greaterOrEqualThan || self == .lessThan || self == .lessOrEqualThan
                } else if leftType == .string {
                    return self == .contains || self == .no_contains
                }
            }
        }
        
        return false
    }
}

extension Operator: Comparable {
    
    //ESTA COMPARACION SE BASA EN LA PRIORIDAD DE OPERADOR. POR EJEMPLO, UNA MULTIPLICACION SE RESUELVE ANTES QUE UNA SUMA EN LA EXPRESION A*B+C
    public static func < (lhs: Operator, rhs: Operator) -> Bool {
        
        if lhs.type() != rhs.type() {
            return rhs.type() == .arithmetical
        }
        
        if lhs.type() == .arithmetical {
            if lhs == rhs {
                return false
            }
            
            if lhs == .plus || lhs == .minus {
                return true
            }
            
            return false
        } else {
            if lhs == rhs {
                return false
            }
            
            if lhs == .or {
                return true
            }
            
            if lhs == .and && rhs != .or {
                return true
            }
            
            return false
        }
    }
}
