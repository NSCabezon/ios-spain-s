import Foundation
import CoreDomain

public struct TransferScheduledDTO: Codable {
    public var concept: String?
    public var transferAmount: AmountDTO?
    public var numberOrderHeader: String?
    public var descTipInst: String?
    public var dateStartValidity: Date?
    public var dateEndValidity: Date?
    public var urgency: String?
    public var typeTransfer: String?
    public var typeSelection: String?
    public var periodicalType: PeriodicalTypeTransferDTO?

    public init() {}
}

extension TransferScheduledDTO: Equatable {
    
    public static func == (lhs: TransferScheduledDTO, rhs: TransferScheduledDTO) -> Bool {
        return lhs.concept == rhs.concept && lhs.numberOrderHeader == rhs.numberOrderHeader
    }
}

extension TransferScheduledDTO: TransferRepresentable {
    public var ibanRepresentable: IBANRepresentable? {
        guard let iban = self.numberOrderHeader else {
            return nil
        }
        return IBANDTO(ibanString: iban)
    }

    public var name: String? {
        return nil
    }

    public var transferConcept: String? {
        return concept
    }

    public var typeOfTransfer: TransferRepresentableType? {
        return .emitted
    }

    public var scheduleType: TransferRepresentableScheduleType? {
        return typeTransfer?.lowercased() == "p" ? .periodic : .scheduled
    }

    public var amountRepresentable: AmountRepresentable? {
        return transferAmount
    }

    public var transferExecutedDate: Date? {
        return dateStartValidity
    }

    public var transferNumber: String? {
        return nil
    }

    public var contractRepresentable: ContractRepresentable? {
        return nil
    }
}
