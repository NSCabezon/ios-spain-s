import CoreFoundationLib

/// iban and withholdingamount necessary in this use case
final class WithholdingConfiguration {
    let detailEntity: AccountDetailEntity
    
    init(detailEntity: AccountDetailEntity) {
        self.detailEntity = detailEntity
    }
}
