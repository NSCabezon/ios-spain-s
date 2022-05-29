public struct UsualTransferInput {
    public let amountDTO: AmountDTO
    public let concept: String
    public let beneficiaryMail: String
    public let transferType: TransferTypeDTO
    
    public init(amountDTO: AmountDTO, concept: String, beneficiaryMail: String, transferType: TransferTypeDTO){
        self.amountDTO = amountDTO
        self.concept = concept
        self.beneficiaryMail = beneficiaryMail
        self.transferType = transferType
    }
}

