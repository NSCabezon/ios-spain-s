public struct PrepaidCardDataDTO: Codable  {
    public var commercialChannel: String?
    public var currentBalance: AmountDTO?
    public var referenceStandardDTO: ReferenceStandardDTO?
    public var cardContract: ContractDTO?
    public var liquidationType: String?
    public var paymentMethod: String?
    public var holderName: String?
    public var prodNameDescISBAN: String?
    public var signatureDTO: SignatureDTO?
    public var token: String?

    public init() {}
    
    public static func createFromCardSuperSpeedDTO(from: CardSuperSpeedDTO) -> PrepaidCardDataDTO {
        let newCardDataDTO = PrepaidCardDataDTO()
        // prepaidBalance current not available
//        newCardDataDTO.currentBalance = from.prepaidBalance

        return newCardDataDTO
    }
}
