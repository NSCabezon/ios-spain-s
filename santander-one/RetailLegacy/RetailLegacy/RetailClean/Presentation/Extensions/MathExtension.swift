import Foundation

extension Int {
    static func secureInt(value: Double) -> Int {
        guard Double(Int.max) > value else {
            return Int.max
        }
        return Int(value)
    }
}

extension Double {
    /// Calculate the proportion among four numbers, using three.
    /// The proportion is used as (a/b) = (c/d)
    ///
    /// - Returns: the result of calculating number d. If a equals 0, returns nil.
    static func proportion(a: Double, b: Double, c: Double) -> Double? {
        guard a != 0 else { return nil }
        return c * b / a
    }
}
