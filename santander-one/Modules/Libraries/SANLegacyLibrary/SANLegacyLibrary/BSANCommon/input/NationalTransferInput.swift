import CoreDomain

public struct NationalTransferInput {
    public var beneficiary: String
    public var isSpanishResident: Bool
    public var ibandto: IBANDTO
    public var saveAsUsual: Bool
    public var saveAsUsualAlias: String?
    public var beneficiaryMail: String?
    public var amountDTO: AmountDTO
    public var concept: String?
    
    public init(beneficiary: String, isSpanishResident: Bool, ibandto: IBANDTO, saveAsUsual: Bool, saveAsUsualAlias: String?, beneficiaryMail: String?, amountDTO: AmountDTO, concept: String?) {
        self.beneficiary = beneficiary
        self.isSpanishResident = isSpanishResident
        self.ibandto = ibandto
        self.saveAsUsual = saveAsUsual
        self.saveAsUsualAlias = saveAsUsualAlias
        self.beneficiaryMail = beneficiaryMail
        self.amountDTO = amountDTO
        self.concept = concept
    }
    
    public init(beneficiary: String, isSpanishResident: Bool, ibanRepresentable: IBANRepresentable, saveAsUsual: Bool, saveAsUsualAlias: String?, beneficiaryMail: String?, amountRepresentable: AmountRepresentable, concept: String?) {
        self.beneficiary = beneficiary
        self.isSpanishResident = isSpanishResident
        self.saveAsUsual = saveAsUsual
        self.saveAsUsualAlias = saveAsUsualAlias
        self.beneficiaryMail = beneficiaryMail
        self.concept = concept
        self.ibandto = IBANDTO(countryCode: ibanRepresentable.countryCode, checkDigits: ibanRepresentable.checkDigits, codBban: ibanRepresentable.codBban)
        let currency = CurrencyDTO(currencyName: amountRepresentable.currencyRepresentable?.currencyName ?? "", currencyType: amountRepresentable.currencyRepresentable?.currencyType ?? .eur)
        self.amountDTO = AmountDTO(value: amountRepresentable.value ?? .zero, currency: currency)
    }
    
    public mutating func setBeneficiary(beneficiary: String) -> NationalTransferInput {
        self.beneficiary = beneficiary
        return self
    }
    
    public mutating func setSpanishResident(isSpanishResident: Bool) -> NationalTransferInput {
        self.isSpanishResident = isSpanishResident
        return self
    }
    
    public mutating func setIbandto(ibandto: IBANDTO) -> NationalTransferInput {
        self.ibandto = ibandto
        return self
    }
    
    public mutating func setSaveAsUsual(saveAsUsual: Bool) -> NationalTransferInput {
        self.saveAsUsual = saveAsUsual
        return self
    }
    
    public mutating func setSaveAsUsualAlias(saveAsUsualAlias: String) -> NationalTransferInput {
        self.saveAsUsualAlias = saveAsUsualAlias
        return self
    }
    
    public mutating func setBeneficiaryMail(beneficiaryMail: String) -> NationalTransferInput {
        self.beneficiaryMail = beneficiaryMail
        return self
    }
    
    public mutating func setAmountDTO(amountDTO: AmountDTO) -> NationalTransferInput {
        self.amountDTO = amountDTO
        return self
    }
    
    public mutating func setConcept(concept: String) -> NationalTransferInput {
        self.concept = concept
        return self
    }
}

extension NationalTransferInput: NationalTransferInputRepresentable {}
