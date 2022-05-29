import Foundation

public struct InactiveCardDTO: Codable {
    public var PAN: String?
    public var contract: ContractDTO?
    public var cardDescription: String?
    public var cardContractDescription: String?
    public var expirationDate: Date?
    public var inactiveCardType: InactiveCardType?
    
    public init() {}
    
    public static func createFromCardSuperSpeedDTO(from: CardSuperSpeedDTO) -> InactiveCardDTO{
        var newInactiveCardDTO = InactiveCardDTO()
        newInactiveCardDTO.PAN = from.PAN
        //        newInactiveCardDTO.contract =
        //        newInactiveCardDTO.cardDescription =
        //        newInactiveCardDTO.cardContractDescription =

        if let expirationDateString = from.expirationDate, let expirationDate = DateFormats.toDate(string: expirationDateString, output: DateFormats.TimeFormat.yyyyMM){
            newInactiveCardDTO.expirationDate = expirationDate
        }
        
        if from.indActive != "A" {
            newInactiveCardDTO.inactiveCardType = InactiveCardType.inactive
        } else if from.indBlocking == "S" {
            newInactiveCardDTO.inactiveCardType = InactiveCardType.temporallyOff
        }
        
        return newInactiveCardDTO
    }
}
