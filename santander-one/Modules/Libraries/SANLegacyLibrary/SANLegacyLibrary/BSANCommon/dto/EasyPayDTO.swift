import Foundation
import CoreDomain

public struct EasyPayDTO: Codable {
    public var issueDate: Date?
    public var paymentMethod: String?
    public var productSubtype: ProductSubtypeDTO?
    public var feeVariationType: String?
    public var supportCode: String?
    public var transactionOperationModeType: String?
    public var transactionOriginType: String?
    public var contractedCommerceName: String?
    public var atmCommerceDesc: String?

    public init() {}
}

extension EasyPayDTO: EasyPayRepresentable {
    public var productSubtypeRepresentable: ProductSubtypeRepresentable? {
        productSubtype
    }
}
