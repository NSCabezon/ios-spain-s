import SANLegacyLibrary

struct FundTransactionDetail {
    
    var operationExpenses: Amount? {
        guard let amount = dto?.operationExpensesAmount else {
            return nil
        }
        return Amount.createFromDTO(amount)
    }
    
    var linkedAccount: String? {
        if let ibanDTO = dto?.IBANChargeIncome {
            let iban = IBAN.create(ibanDTO)
            return iban.ibanPapel
        }
        
        return nil
    }
    
    var status: String? {
        return dto?.situationDesc
    }
    
    private(set) var dto: FundTransactionDetailDTO?
    
    init(_ dto: FundTransactionDetailDTO) {
        self.dto = dto
    }
 
}
