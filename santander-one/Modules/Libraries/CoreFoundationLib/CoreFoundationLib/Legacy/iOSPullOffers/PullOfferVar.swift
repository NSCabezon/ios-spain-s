import Foundation
import CoreDomain

final class PullOfferVar: Variable {
    
    var id: String?
    var value: Any? {
        didSet {
            self.type = getTypeFor(value: value as Any)
        }
    }
    var type: VarType?
    var rawExpression: String?
    var parentExpression: Expression?
    
    public init(value: Any, type: VarType) {
        self.value = parseValue(value: value)
        self.type = type
    }
    
    public init(value: Any?, isVar: Bool) {
        self.value = parseValue(value: value)
        self.type = getTypeFor(value: value as Any)
        
        if isVar {
            self.type = .variable
        }
    }
    
    private func parseValue(value: Any?) -> Any?{
        if let string = value as? String {
            if let firstChar = string.map({$0}).first {
                if firstChar == SpecialChars.escapeQuote.char {
                    return string.replacingOccurrences(of: SpecialChars.escapeQuote.string, with: "")
                } else {
                    return string
                }
            }
            
            if string == "true" || string == "false" {
                return string == "true"
            }
            
            if let doubleValue = Double(string) {
                return doubleValue
            }
            
            if let firstChar = string.map({$0}).first, firstChar == SpecialChars.singleQuote.char {
                if let date = PullOffersTimeManager.toDate(input: string.replacingOccurrences(of: SpecialChars.singleQuote.string, with: "")) {
                    return date
                }
            }
            
            if let firstChar = string.map({$0}).first {
                if firstChar == SpecialChars.squareBracketLeft.char {
                    return parseArray(input: string)
                }
            }
        } else if let valuesArray = value as? [Any] {
            return valuesArray.map({PullOfferVar(value: $0, isVar: false)})
        }
        
        return value
    }
    
    private func parseArray(input: String) -> [PullOfferVar] {
        let components = input.replacingOccurrences(of: SpecialChars.squareBracketLeft.string, with: "")
            .replacingOccurrences(of: SpecialChars.squareBracketRight.string, with: "")
            .split(separator: SpecialChars.comma.char)
        
        return components.map({PullOfferVar(value: String($0), isVar: false)})
    }
    
    private func getTypeFor(value: Any) -> VarType{
        if let string = value as? String {
            if let firstChar = string.map({$0}).first {
                if firstChar == SpecialChars.escapeQuote.char {
                    return .string
                }
            }
            
            if string == "true" || string == "false" {
                return .logical
            }
            
            if Double(string) != nil{
                return .arithmetical
            }
            
            if let firstChar = string.map({$0}).first, firstChar == SpecialChars.singleQuote.char {
                if PullOffersTimeManager.toDate(input: string.replacingOccurrences(of: SpecialChars.singleQuote.string, with: "")) != nil {
                    return .date
                }
            }
            
            if let firstChar = string.map({$0}).first {
                if firstChar == SpecialChars.squareBracketLeft.char {
                    return .array
                }
            }
            
        } else if value is Bool {
            return .logical
        } else if value is Int {
            return .arithmetical
        } else if value is Date {
            return .date
        } else if value is Double {
            return .arithmetical
        } else if value is [Any] {
            return .array
        }
        
        return .variable
    }
    
    func getTopParent() -> Expression{
        if let parent = self.parentExpression {
            return parent.getTopParent()
        } else {
            return self
        }
    }
    
    func getNodeVariables() -> [Variable] {
        if self.value != nil, self.type != nil {
            return [self]
        }
        
        return []
    }
    
    func getDoubleValue() -> Double? {
        var realValue: Any? = self.value
        if let newSelf = self.value as? PullOfferVar {
            realValue = newSelf.value
        }
        
        guard let valueUW = realValue else {
            return nil
        }
        
        if let doubleValue = valueUW as? Double {
            return doubleValue
        } else if let intValue = valueUW as? Int {
            return Double(intValue)
        } else if let stringValue = valueUW as? String {
            return Double(stringValue)
        }
        
        return nil
    }
}

extension PullOfferVar: Comparable {
    
    static func < (lhs: PullOfferVar, rhs: PullOfferVar) -> Bool {
        guard let lType = lhs.type, let rType = rhs.type else {
            return false
        }
        
        if lType == .logical || lType == .string {
            return false
        }
        
        if lType == .arithmetical, lType == rType {
            if let lhsValue = lhs.getDoubleValue(), let rhsValue = rhs.getDoubleValue() {
                return lhsValue < rhsValue
            }
        } else if lType == .date, let lDate = lhs.value as? Date, let rDate = rhs.value as? Date {
            return lDate.compare(rDate) == .orderedAscending
        } else if (lType == .array && rType == .arithmetical) || (lType == .arithmetical && rType == .array) {
            if let array = lhs.value as? [PullOfferVar], let singleElement = rhs.getDoubleValue() {
                return array.filter({$0.getDoubleValue()! < singleElement}).count == array.count
            } else if let singleElement = lhs.getDoubleValue(), let array = rhs.value as? [PullOfferVar] {
                return array.filter({singleElement < $0.getDoubleValue()!}).count == array.count
            }
        }
        
        return false
    }
    
    static func == (lhs: PullOfferVar, rhs: PullOfferVar) -> Bool {
        guard let lType = lhs.type, let rType = rhs.type, lType == rType else {
            return false
        }
        
        if lType == .date, let lDate = lhs.value as? Date, let rDate = rhs.value as? Date {
            return lDate.compare(rDate) == .orderedSame
        } else {
            if let lhsValue = lhs.getDoubleValue(), let rhsValue = rhs.getDoubleValue() {
                return lhsValue == rhsValue
            } else if let lValue = lhs.value as? Bool, let rValue = rhs.value as? Bool {
                return lValue == rValue
            } else if let lValue = lhs.value as? String, let rValue = rhs.value as? String {
                return lValue == rValue
            } else if let lArray = lhs.value as? [PullOfferVar], let rArray = rhs.value as? [PullOfferVar], lArray.count == rArray.count {
                for i in 0...lArray.count-1 {
                    if let lElement = lArray[i].getDoubleValue(), let rElement = rArray[i].getDoubleValue(), lElement != rElement {
                        return false
                    } else if let lElement = lArray[i].value as? Bool, let rElement = rArray[i].value as? Bool, lElement != rElement {
                        return false
                    } else if let lElement = lArray[i].value as? String, let rElement = rArray[i].value as? String, lElement != rElement {
                        return false
                    }
                }
                
                return true
            }
        }
        
        return false
    }
    
    static func && (lhs: PullOfferVar, rhs: PullOfferVar) -> Bool {
        if let lValue = lhs.value as? Bool, let rValue = rhs.value as? Bool {
            return lValue && rValue
        }
        
        return false
    }
    
    static func || (lhs: PullOfferVar, rhs: PullOfferVar) -> Bool {
        if let lValue = lhs.value as? Bool, let rValue = rhs.value as? Bool {
            return lValue || rValue
        }
        
        return false
    }
    
    static func + (lhs: PullOfferVar, rhs: PullOfferVar) -> PullOfferVar? {
        guard let lType = lhs.type, let rType = rhs.type, lType == rType else {
            return nil
        }
        
        if lType == .arithmetical {
            if let lhsValue = lhs.getDoubleValue(), let rhsValue = rhs.getDoubleValue() {
                return PullOfferVar(value: lhsValue + rhsValue, type: lType)
            }
        }
        
        return nil
    }
    
    static func - (lhs: PullOfferVar, rhs: PullOfferVar) -> PullOfferVar? {
        guard let lType = lhs.type, let rType = rhs.type, lType == rType else {
            return nil
        }
        
        if lType == .arithmetical {
            if let lhsValue = lhs.getDoubleValue(), let rhsValue = rhs.getDoubleValue() {
                return PullOfferVar(value: lhsValue - rhsValue, type: lType)
            }
        }
        
        return nil
    }
    
    static func * (lhs: PullOfferVar, rhs: PullOfferVar) -> PullOfferVar? {
        guard let lType = lhs.type, let rType = rhs.type, lType == rType else {
            return nil
        }
        
        if lType == .arithmetical {
            if let lhsValue = lhs.getDoubleValue(), let rhsValue = rhs.getDoubleValue() {
                return PullOfferVar(value: lhsValue * rhsValue, type: lType)
            }
        }
        
        return nil
    }
    
    static func / (lhs: PullOfferVar, rhs: PullOfferVar) -> PullOfferVar? {
        guard let lType = lhs.type, let rType = rhs.type, lType == rType else {
            return nil
        }
        
        if lType == .arithmetical {
            if let lhsValue = lhs.getDoubleValue(), let rhsValue = rhs.getDoubleValue() {
                return PullOfferVar(value: lhsValue / rhsValue, type: lType)
            }
        }
        
        return nil
    }
}

extension PullOfferVar {
    func contains (rhs: PullOfferVar) -> PullOfferVar? {
        guard let lType = self.type, let rType = rhs.type else {
            return nil
        }
        
        if lType == rType, lType == .string, let lhString = self.value as? String, let rhString = rhs.value as? String {
            //TODO: AQUI SE RETORNA CON TIPO STRING??? NO DEBERIA SER LOGICAL???
            return PullOfferVar(value: lhString.lowercased().contains(rhString.lowercased()), type: .logical)
        }
        
        if (lType == .array && rType != .array) || (lType != .array && rType == .array) {
            if let array = self.value as? [PullOfferVar], let arrayFirstType = array.first?.type, let rightType = rhs.type, arrayFirstType == rightType {
                //ELEMENTO DE LA IZQUIERDA ES ARRAY Y EL DE LA DERECHA PUEDE SER ARITMETICO, LOGICO O STRING
                if arrayFirstType == .arithmetical {
                    return PullOfferVar(value: array.contains(where: {$0.getDoubleValue() == rhs.getDoubleValue()}), type: .logical)
                } else if arrayFirstType == .string {
                    if let rhsString = rhs.value as? String {
                        return PullOfferVar(value: array.compactMap({$0.value as? String}).contains(where: {$0 == rhsString}), type: .logical)
                    }
                } else if arrayFirstType == .logical {
                    if let rhsString = rhs.value as? Bool {
                        return PullOfferVar(value: array.compactMap({$0.value as? Bool}).contains(where: {$0 == rhsString}), type: .logical)
                    }
                }
            } else if let array = rhs.value as? [PullOfferVar], let arrayFirstType = array.first?.type, let leftType = self.type, arrayFirstType == leftType {
                //ELEMENTO DE LA IZQUIERDA ES STRING Y EL DE LA DERECHA ES ARRAY DE STRINGS (SE HACE UN SUBSTRING)
                if arrayFirstType == .string {
                    for substr in array.map({$0.value as? String}) {
                        if let leftString = self.value as? String, let substrUW = substr {
                            if !leftString.contains(substrUW) {
                                return PullOfferVar(value: false, type: .logical)
                            }
                        }
                    }
                    
                    return PullOfferVar(value: true, type: .logical)
                }
            }
        } else {
            //AMBOS ELEMENTOS SON ARRAYS
            if let leftArray = self.value as? [PullOfferVar], let rightArray = rhs.value as? [PullOfferVar] {
                for elem in rightArray {
                    if !leftArray.contains(elem) {
                        return PullOfferVar(value: false, type: .logical)
                    }
                }
                
                return PullOfferVar(value: true, type: .logical)
            }
        }
        
        return nil
    }
    
    func indexOf(rhs: PullOfferVar) -> PullOfferVar? {
        guard let lType = self.type, let rType = rhs.type, lType == .array && rType != .array else {
            return nil
        }
        
        if let array = self.value as? [PullOfferVar], let arrayFirstType = array.first?.type, let rightType = rhs.type, arrayFirstType == rightType {
            //ELEMENTO DE LA IZQUIERDA ES ARRAY Y EL DE LA DERECHA PUEDE SER ARITMETICO, LOGICO O STRING
            if arrayFirstType == .arithmetical {
                if let rhsString = rhs.getDoubleValue(), let index = array.compactMap({$0.getDoubleValue()}).firstIndex(where: {$0 == rhsString}) {
                    return PullOfferVar(value: index, type: .arithmetical)
                }
            } else if arrayFirstType == .string {
                if let rhsString = rhs.value as? String, let index = array.compactMap({$0.value as? String}).firstIndex(where: {$0 == rhsString}) {
                    return PullOfferVar(value: index, type: .arithmetical)
                }
            } else if arrayFirstType == .logical {
                if let rhsString = rhs.value as? Bool, let index = array.compactMap({$0.value as? Bool}).firstIndex(where: {$0 == rhsString}) {
                    return PullOfferVar(value: index, type: .arithmetical)
                }
            }
        }
        
        return nil
    }
}
