import Foundation

public struct FractionablePurchaseDetailParameters {
    public let pan: String
    public let movID: String
    
    public init(pan: String, movID: String) {
        self.pan = pan
        self.movID = movID
    }
}
