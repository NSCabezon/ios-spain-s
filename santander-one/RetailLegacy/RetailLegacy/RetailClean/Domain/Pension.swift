import SANLegacyLibrary
import Foundation
import CoreFoundationLib
import CoreDomain

class Pension: GenericProduct {
    
    let pensionEntity: PensionEntity
    var pensionDTO: PensionDTO {
        return pensionEntity.dto
    }
    
    init(_ entity: PensionEntity) {
        self.pensionEntity = entity
        super.init()
    }
    
    convenience init(dto: PensionDTO) {
        self.init(PensionEntity(dto))
    }
    
    func isAllianz(filterWith allianzProducts: [ProductAllianz]) -> Bool {
        guard !allianzProducts.isEmpty else { return false }
        return allianzProducts
            .filter { $0.type == self.pensionDTO.productSubtypeDTO?.productType }
            .contains { (productAllianz) -> Bool in
                guard
                    let fromSubtypeString = productAllianz.fromSubtype,
                    let fromSubtype = Int(fromSubtypeString),
                    let toSubtypeString = productAllianz.toSubtype,
                    let toSubtype = Int(toSubtypeString),
                    let productSubtypeString = self.pensionDTO.productSubtypeDTO?.productSubtype,
                    let productSubtype = Int(productSubtypeString)
                    else { return false }
                return fromSubtype <= productSubtype && productSubtype <= toSubtype
        }
    }
    
    override var productIdentifier: String {
        return pensionDTO.contract?.formattedValue ?? ""
    }
    
    override func getAlias() -> String? {
        return pensionDTO.alias
    }

    override func getDetailUI() -> String {
        return pensionDTO.contractDescription?.trim() ?? ""
    }

    override func getAmountValue() -> Decimal? {
        return pensionDTO.valueAmount?.value
    }

    override func getAmountCurrency() -> CurrencyDTO? {
        return pensionDTO.valueAmount?.currency
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return transformToAliasAndInfo(alias: alias ?? getAliasCamelCase()) + " | " + getContractShort()
    }

    override func getTipoInterv() -> OwnershipTypeDesc? {
        return pensionDTO.ownershipTypeDesc
    }
    
    override func getCounterValueAmountValue() -> Decimal? {
        return pensionDTO.counterValueAmount?.value
    }
    
    func getSharesNumber() -> Decimal? {
        return pensionDTO.sharesNumber
    }
    
    func getContractShort() -> String {
        guard let contract = pensionDTO.contractDescription, let minicontract = contract.substring(contract.count - 4) else { return "" }
        return "***" + minicontract
    }
    
}

extension Pension: Equatable {}

extension Pension: OperativeParameter {}

func == (lhs: Pension, rhs: Pension) -> Bool {
    return lhs.getAlias() == rhs.getAlias() &&
    lhs.getDetailUI() == rhs.getDetailUI() &&
    lhs.getAmountValue() == rhs.getAmountValue() &&
    lhs.getTipoInterv() == rhs.getTipoInterv()
}
