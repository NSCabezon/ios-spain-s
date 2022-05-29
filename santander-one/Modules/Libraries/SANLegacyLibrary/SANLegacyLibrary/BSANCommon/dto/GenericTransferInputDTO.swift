import CoreDomain

public struct GenericTransferInputDTO: Codable {
    public let beneficiary: String?
    public let isSpanishResident: Bool?
    public let ibandto: IBANDTO
    public let saveAsUsual: Bool?
    public let saveAsUsualAlias: String?
    public let beneficiaryMail: String?
    public let amountDTO: AmountDTO
    public let concept: String?
    public let transferType: TransferTypeDTO
    public let tokenPush: String?
    
    public init(beneficiary: String?,
                isSpanishResident: Bool?,
                ibandto: IBANDTO,
                saveAsUsual: Bool?,
                saveAsUsualAlias: String?,
                beneficiaryMail: String?,
                amountDTO: AmountDTO,
                concept: String?,
                transferType: TransferTypeDTO,
                tokenPush: String?) {
        self.beneficiary = beneficiary
        self.isSpanishResident = isSpanishResident
        self.ibandto = ibandto
        self.saveAsUsual = saveAsUsual
        self.saveAsUsualAlias = saveAsUsualAlias
        self.beneficiaryMail = beneficiaryMail
        self.amountDTO = amountDTO
        self.concept = concept
        self.transferType = transferType
        self.tokenPush = tokenPush
    }
    
    public init(beneficiary: String?,
                isSpanishResident: Bool?,
                ibanRepresentable: IBANRepresentable,
                saveAsUsual: Bool?,
                saveAsUsualAlias: String?,
                beneficiaryMail: String?,
                amountRepresentable: AmountRepresentable,
                concept: String?,
                transferType: TransferTypeDTO,
                tokenPush: String?) {
        self.beneficiary = beneficiary
        self.isSpanishResident = isSpanishResident
        self.saveAsUsual = saveAsUsual
        self.saveAsUsualAlias = saveAsUsualAlias
        self.beneficiaryMail = beneficiaryMail
        self.concept = concept
        self.transferType = transferType
        self.ibandto = IBANDTO(countryCode: ibanRepresentable.countryCode,
                               checkDigits: ibanRepresentable.checkDigits,
                               codBban: ibanRepresentable.codBban)
        let currency = CurrencyDTO(currencyName: amountRepresentable.currencyRepresentable?.currencyName ?? "",
                                   currencyType: amountRepresentable.currencyRepresentable?.currencyType ?? .eur)
        self.amountDTO = AmountDTO(value: amountRepresentable.value ?? .zero,
                                   currency: currency)
        self.tokenPush = tokenPush
    }
}
