import SANLegacyLibrary
import Foundation

enum BillType {
    case receipt
    case tax
}

struct Bill {
    
    static func create(_ from: BillDTO) -> Bill {
        return Bill(dto: from)
    }
    
    let billDTO: BillDTO
    
    internal init(dto: BillDTO) {
        billDTO = dto
    }
    
    var expirationDate: Date {
        return billDTO.expirationDate
    }
    
    var name: String {
        return billDTO.name
    }
    
    var holder: String {
        return billDTO.holder
    }
    
    var amountWithSymbol: Amount {
        if let value = billDTO.amount.value {
            var amount = billDTO.amount
            if status == .returned {
                amount.value = abs(value)
            } else {
                amount.value = -abs(value)
            }
            return Amount.createFromDTO(amount)
        } else {
            return Amount.createFromDTO(billDTO.amount)
        }
    }
    
    var amount: Amount {
        return Amount.createFromDTO(billDTO.amount)
    }
    
    var status: BillStatusDO {
        return BillStatusDO(from: billDTO.status)
    }
    
    var type: BillType {
        if billDTO.idban.count > 6 {
            return .receipt
        } else {
            return .tax
        }
    }
    
    var linkedAccount: String {
        return billDTO.debtorAccount
    }

    var issuerCode: String {
        return billDTO.code
    }

    var paymentDate: Date {
        return billDTO.pagDate
    }    
}

/// This struct was created to wrap data that was requiered in Bill detail
struct BillAndAccount {
    let bill: Bill
    let account: Account
}

extension BillAndAccount: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(bill.name)
        hasher.combine(bill.holder)
        hasher.combine(bill.status)
        hasher.combine(bill.amount.value)
        hasher.combine(bill.name)
        hasher.combine(bill.linkedAccount)
        hasher.combine(bill.issuerCode)
        hasher.combine(bill.paymentDate)
        hasher.combine(bill.expirationDate)
    }
}

extension BillAndAccount: Equatable {
    static func == (lhs: BillAndAccount, rhs: BillAndAccount) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
