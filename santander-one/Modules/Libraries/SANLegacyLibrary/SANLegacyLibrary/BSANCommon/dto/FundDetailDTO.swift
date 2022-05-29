import Foundation
import CoreDomain

public struct FundDetailDTO: Codable {
    public var holder: String?
    public var fundDesc: String?
    public var settlementValueAmount: AmountDTO?
    public var valueAmount: AmountDTO?
    public var valueDate: Date?
    public var sharesNumber: Decimal?
    public var linkedAccount: ContractDTO?
    public var linkedAccountDesc: String?
    
    public init() {}
}

extension FundDetailDTO: FundDetailRepresentable {
    public var associatedAccountRepresentable: String? {
        return linkedAccountDesc
    }

    public var ownerRepresentable: String? {
        return holder
    }

    public var descriptionRepresentable: String? {
        return fundDesc
    }

    public var dateOfValuationRepresentable: Date? {
        return valueDate
    }

    public var numberOfunitsRepresentable: String? {
        guard let sharesNumber = sharesNumber else {
            return nil
        }
        return AmountFormats.getSharesFormattedForWS(sharesNumber: sharesNumber)
    }

    public var valueOfAUnitAmountRepresentable: AmountRepresentable? {
        return settlementValueAmount
    }

    public var totalValueAmountRepresentable: AmountRepresentable? {
        return valueAmount
    }
}
