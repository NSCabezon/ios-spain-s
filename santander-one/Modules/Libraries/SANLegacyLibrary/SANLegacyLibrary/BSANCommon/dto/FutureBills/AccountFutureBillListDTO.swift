//

import Foundation
import CoreDomain

public struct AccountFutureBillListDTO: Codable {
    public var billList: [AccountFutureBillDTO] = []
    public let additionalInfo: AditionalInfoDTO?
    
    public init (billList: [AccountFutureBillDTO], additionalInfo: AditionalInfoDTO?) {
        self.billList = billList
        self.additionalInfo = additionalInfo
    }
}

extension AccountFutureBillListDTO: AccountFutureBillListRepresentable {
    public var billListRepresentable: [AccountFutureBillRepresentable] {
        return self.billList
    }
    
    public var additionalInfoRepresentable: AditionalInfoRepresentable? {
        return self.additionalInfo
    }
}

public struct AccountFutureBillDTO: Codable {
    public let account: String?
    public let bill:  String?
    public let billType: String?
    public let billAmount: Double?
    public let billCurrency: String?
    public let billDateExpiry: String?
    public let billStatus: String?
    public let billConcept: String?
    public let personName: String?
}

extension AccountFutureBillDTO: AccountFutureBillRepresentable {
    public var billAmountRepresentable: AmountRepresentable? {
        guard let billAmount = self.billAmount,
              let billCurrency = self.billCurrency else {
                  return nil
              }
        return AmountDTO(value: Decimal(billAmount),
                         currency: CurrencyDTO.create(billCurrency))
    }
    
    public var billStatusEnum: FutureBillStatus? {
        switch self.billStatus ?? "" {
        case "AUT":
            return .autorized
        case "PAU":
            return .pending
        case "RCH":
            return .rejected
        default:
            return .none
        }
    }
    
    public var billDateExpiryDate: Date? {
        guard let dateString = self.billDateExpiry else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }

    public func isEqualTo(_ representable: AccountFutureBillRepresentable) -> Bool {
        return representable.account == self.account && representable.bill == self.bill
    }
}

public struct AditionalInfoDTO: Codable {
    public let last: Bool?
    public let totalElements: Int?
    public let totalPages: Int?
    public let first: Bool?
}

extension AditionalInfoDTO: AditionalInfoRepresentable {
}
