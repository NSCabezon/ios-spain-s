import SANLegacyLibrary
import Foundation
import CoreFoundationLib

final class Imposition: GenericProduct {
    weak var deposit: Deposit?
    private(set) var dto: ImpositionDTO
    
    init(_ dto: ImpositionDTO) {
        self.dto = dto
        super.init()
    }
    
    var linkedAccountDesc: String? {
        return dto.linkedAccountDesc
    }
    
    var openingDate: Date? {
        return dto.openingDate
    }
    var dueDate: Date? {
        return dto.dueDate
    }
    var settlementAmount: Amount {
        return Amount.createFromDTO(dto.settlementAmount)
    }
    var TAE: String? {
        guard let tae = dto.TAE, let number = Decimal(string: tae) else {
            return nil
        }
        return taeFormatter.string(from: NSDecimalNumber(decimal: number))
    }
    var subcontract: String {
        return dto.impositionSubContract?.subcontractString ?? ""
    }
    
    var contract: String? {
        guard let bankCode = dto.impositionSubContract?.contract?.bankCode, let branchCode = dto.impositionSubContract?.contract?.branchCode, let product = dto.impositionSubContract?.contract?.product, let contractNumber = dto.impositionSubContract?.contract?.contractNumber else { return nil }
        let contractString = "\(bankCode) \(branchCode) \(product) \(contractNumber)"
        return  contractString
    }
    
    var renovationIndDesc: String? {
        return dto.renovationIndDesc
    }

    override func getAlias() -> String? {
        return dto.impositionSubContract?.subcontractString
    }
    
    override func getDetailUI() -> String? {
        return dto.interestCapitalizationIndDesc
    }
    
    override func getAmountValue() -> Decimal? {
        return nil
    }
}

// MARK: - GenericProductProtocol

extension Imposition: GenericProductProtocol {}

extension Imposition {
    private var taeFormatter: NumberFormatter {
        return formatterForRepresentation(.tae(decimals: 5))
    }
}

extension Imposition: Equatable {
    static func == (lhs: Imposition, rhs: Imposition) -> Bool {
        return lhs.openingDate == rhs.openingDate &&
            lhs.dueDate == rhs.dueDate &&
            lhs.TAE == rhs.TAE &&
            lhs.subcontract == rhs.subcontract
    }
}
