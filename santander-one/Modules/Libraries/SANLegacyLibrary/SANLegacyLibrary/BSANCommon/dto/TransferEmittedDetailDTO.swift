import Foundation
import CoreDomain

public struct TransferEmittedDetailDTO: Codable {
    public var origin: IBANDTO?
    public var beneficiary: IBANDTO?
    public var transferAmount: AmountDTO?
    public var banckCharge: AmountDTO?
    public var netAmount: AmountDTO?
    
    public var emisionDate: Date?
    public var valueDate: Date?
    
    public var originName: String?
    public var beneficiaryName: String?
    
    public var spentIndicator: String?
    public var transferType: String?
    public var countryCode: String?
    public var spentDescIndicator: String?
    public var descTransferType: String?
    public var countryName: String?

    public init() {}
}

extension TransferEmittedDetailDTO: TransferRepresentable {
    public var ibanRepresentable: IBANRepresentable? {
        return self.beneficiary
    }

    public var name: String? {
        return self.beneficiaryName
    }

    public var transferConcept: String? {
        return nil
    }

    public var typeOfTransfer: TransferRepresentableType? {
        return .emitted
    }

    public var scheduleType: TransferRepresentableScheduleType? {
        return nil
    }

    public var amountRepresentable: AmountRepresentable? {
        return self.transferAmount
    }

    public var transferExecutedDate: Date? {
        return self.emisionDate
    }

    public var transferNumber: String? {
        return nil
    }

    public var contractRepresentable: ContractRepresentable? {
        return nil
    }
}
