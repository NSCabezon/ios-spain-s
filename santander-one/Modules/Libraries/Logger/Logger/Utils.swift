import Foundation

extension Level: Comparable {}

public func <(a: Level, b: Level) -> Bool {
    return a.rawValue < b.rawValue
}

public func <=(a: Level, b: Level) -> Bool {
    return a.rawValue <= b.rawValue
}

public func >(a: Level, b: Level) -> Bool {
    return a.rawValue > b.rawValue
}

public func >=(a: Level, b: Level) -> Bool {
    return a.rawValue >= b.rawValue
}

precedencegroup Additive {
    associativity: left
}
infix operator &= : Additive

func &=(left: inout Bool, right: Bool) {
    left = left && right
}

public extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
