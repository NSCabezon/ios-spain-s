import Foundation

public enum TokenType {
    case parenthesisLeft
    case parenthesisRight
    case squareBracketLeft
    case squareBracketRight
    case comma
    case variable
    case constant
    case oper
}

public class Token {
    public var type: TokenType
    public var content: Any
    public var id: String

    public init(type: TokenType, content: Any) {
        self.type = type
        self.content = content
        self.id = UUID().uuidString
    }
    
    public func getOperator() -> Operator? {
        if type != .oper {
            return nil
        }
        
        guard let contentAsString = content as? String else {
            return nil
        }
        
        switch contentAsString {
        case Operator.equal.rawValue:
            return .equal
        case Operator.notEqual.rawValue:
            return .notEqual
        case Operator.greaterThan.rawValue:
            return .greaterThan
        case Operator.greaterOrEqualThan.rawValue:
            return .greaterOrEqualThan
        case Operator.lessThan.rawValue:
            return .lessThan
        case Operator.lessOrEqualThan.rawValue:
            return .lessOrEqualThan
        case Operator.contains.rawValue:
            return .contains
        case Operator.no_contains.rawValue:
            return .no_contains
        case Operator.indexOf.rawValue:
            return .indexOf
        case Operator.and.rawValue:
            return .and
        case Operator.or.rawValue:
            return .or
        case Operator.multiply.rawValue:
            return .multiply
        case Operator.divide.rawValue:
            return .divide
        case Operator.plus.rawValue:
            return .plus
        case Operator.minus.rawValue:
            return .minus
        default:
            print("OPERATOR NOT CREATED")
            return nil
        }
    }
}

extension Token: Equatable {
    public static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.id == rhs.id
    }
}
