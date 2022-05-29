import Foundation
import CoreDomain

public struct TransferEmittedDTO: Codable, Hashable {
    public var executedDate: Date?
    public var beneficiary: String?
    public var concept: String?
    public var amount: AmountDTO?
    public var countryCode: String?
    public var serviceOrder: ContractDTO?
    public var transferNumber: String?
    public var aplicationCode: String?
    public var transferType: String?
    public var countryName: String?
    public var ibanString: String?
    
    public init() {}
    
    public static func == (lhs: TransferEmittedDTO, rhs: TransferEmittedDTO) -> Bool {
        return lhs.transferNumber == rhs.transferNumber && lhs.serviceOrder?.contractNumber == rhs.serviceOrder?.contractNumber
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(transferNumber)
    }
}

extension TransferEmittedDTO: TransferRepresentable {
    public var ibanRepresentable: IBANRepresentable? {
        guard let iban = self.ibanString else {
            return nil
        }
        return IBANDTO(ibanString: iban)
    }
    
    public var name: String? {
        self.beneficiary
    }

    public var transferConcept: String? {
        self.concept
    }

    public var typeOfTransfer: TransferRepresentableType? {
        return .emitted
    }

    public var scheduleType: TransferRepresentableScheduleType? {
        .normal
    }

    public var amountRepresentable: AmountRepresentable? {
        self.amount
    }

    public var transferExecutedDate: Date? {
        self.executedDate
    }

    public var contractRepresentable: ContractRepresentable? {
        self.serviceOrder
    }
}
