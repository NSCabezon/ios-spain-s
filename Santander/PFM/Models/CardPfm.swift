import SANLegacyLibrary
import CoreFoundationLib

struct CardPfm {
    private let cardDto: CardDTO
    
    init(card: CardEntity) {
        self.cardDto = card.dto
    }
    
    var bankCode: String? {
        return cardDto.contract?.bankCode
    }
    
    var branchCode: String? {
        return cardDto.contract?.branchCode
    }
    
    var product: String? {
        return cardDto.contract?.product
    }
    
    var contractNumber: String? {
        return cardDto.contract?.contractNumber
    }
    
    var pan: String? {
        return cardDto.PAN
    }
}
