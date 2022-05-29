import Foundation

public struct BillEmittersPaymentConfirmationDTO: Codable  {
    public let billNumber: String
    
    public init (billNumber: String) {
        self.billNumber = billNumber
    }
}
