import CoreDomain

public struct ValidateScheduledTransferDTO {
    public var scaRepresentable: SCARepresentable?
    public var lengthSignature: String?
    public var commission: AmountDTO?
    public var serTuBancoBelongs: String?
    public var nameBeneficiaryBank: String?
    public var dataMagicPhrase: String?
    public var actuanteCode: String?
    public var actuanteNumber: String?
    public var actuanteCompany: String?

    public init() {}
    
    public init(scaRepresentable: SCARepresentable? = nil, lengthSignature: String? = nil, commission: AmountDTO? = nil, serTuBancoBelongs: String? = nil, nameBeneficiaryBank: String? = nil, dataMagicPhrase: String? = nil, actuanteCode: String? = nil, actuanteNumber: String? = nil, actuanteCompany: String? = nil) {
        self.scaRepresentable = scaRepresentable
        self.lengthSignature = lengthSignature
        self.commission = commission
        self.serTuBancoBelongs = serTuBancoBelongs
        self.nameBeneficiaryBank = nameBeneficiaryBank
        self.dataMagicPhrase = dataMagicPhrase
        self.actuanteCode = actuanteCode
        self.actuanteNumber = actuanteNumber
        self.actuanteCompany = actuanteCompany
    }
}

extension ValidateScheduledTransferDTO: ValidateScheduledTransferRepresentable {
    public var bankChargeAmountRepresentable: AmountRepresentable? {
        self.commission
    }
}
