import SANLegacyLibrary
import Foundation
import CoreFoundationLib

struct CardDetail {
    struct Constants {
        static let CardHolderNameMaxChars = 26
    }

    static func create(_ from: CardDetailDTO, cardDataDTO: CardDataDTO?, clientName: String) -> CardDetail {
        return CardDetail(dto: from, cardDataDTO: cardDataDTO, clientName: clientName)
    }
    
    var currentBalance: Amount {
        return Amount.createFromDTO(cardDetailDTO?.currentBalance)
    }
    
    let clientName: String
    private(set) var cardDetailDTO: CardDetailDTO?
    private var cardDataDTO: CardDataDTO?

    private init(dto: CardDetailDTO, cardDataDTO: CardDataDTO?, clientName: String) {
        cardDetailDTO = dto
        self.cardDataDTO = cardDataDTO
        self.clientName = clientName
    }
    
    var entity: CardDetailEntity? {
        return cardDetailDTO.map(CardDetailEntity.init)
    }
    
    var holder: String? {
         return cardDetailDTO?.holder
    }
    
    var beneficiary: String? {
        return cardDetailDTO?.beneficiary
    }

    var allowsCesSignup: Bool {
        return isCardBeneficiary
    }

    var allowsWithdrawMoney: Bool {
        return isCardBeneficiary
    }
    
    var linkedAccount: String? {
        return cardDetailDTO?.linkedAccountDescription
    }
    
    var expirationDate: Date? {
        return cardDetailDTO?.expirationDate
    }
    
    var cardType: String? {
        return cardDetailDTO?.cardTypeDescription
    }
    
    var linkedAccountOldContract: String? {
        return cardDetailDTO?.linkedAccountOldContract?.contractNumber
    }

    var isCardBeneficiary: Bool {
        if let cardDetail = cardDetailDTO, let beneficiary = cardDetail.beneficiary, clientName.trim() == beneficiary.trim() {
            return true
        }
        return false
    }

    var stampedName: String {
        var owner: String?
        if let dto = cardDataDTO {
            if let stampedName = dto.stampedName, !stampedName.isEmpty {
                // Caso 1: Nombres de beneficiarios recuperados a partir del nuevo servicio de tarjetas
                owner = stampedName.substring(0, min(CardDetail.Constants.CardHolderNameMaxChars, stampedName.count))
            }
        }
        
        if let cardDetail = cardDetailDTO, owner == nil {
            // Caso 2: Nombres de beneficiarios recuperados a partir del campo "beneficiario" del servicio detalleTarjeta
            owner = toCardNameCase(name: cardDetail.beneficiary ?? "", maxSize: CardDetail.Constants.CardHolderNameMaxChars, permute: true)
        }

        return owner ?? ""
    }
    
    var contract: ContractDO {
        guard let dto = cardDetailDTO?.linkedAccountOldContract else { return ContractDO() }
        return ContractDO(contractDTO: dto)
    }

    private func toCardNameCase(name: String, maxSize: Int, permute: Bool) -> String {
        let text = name.uppercased().trim()
        let tokens = text.split(" ")
        if text.count <= maxSize {
            if tokens.count == 3 {
                return permute ? tokens[2] + " " + tokens[0] + " " + tokens[1] : text
            }
            return text
        }

        let reduced = reduceCardName(name: text)
        if tokens.count == 3 {
            return toCardNameCase(name: reduced, maxSize: maxSize, permute: permute)
        }

        if reduced.count >= text.count && reduced.count >= maxSize {
            return reduced.substring(0, maxSize)!
        }

        return toCardNameCase(name: reduced, maxSize: maxSize, permute: false)
    }

    private func reduceCardName(name: String) -> String {
        var tokens = name.split(" ")
        for i in stride(from: tokens.count - 1, to: 0, by: -1) {
            let token = tokens[i]
            if token.count > 2 {
                tokens[i] = token.substring(0, 1)! + "."
                break
            }
        }
        var result = ""
        for token in tokens {
            result += "\(token) "
        }
        return result.trim()
    }

    /**
      * Detalle tarjeta tiene que estar llamado para que este método tenga validez
      *
      * Indica si la tarjeta permite la consulta de PIN
      */
    var allowDirectMoney: Bool {
        return isCardBeneficiary
    }

    /**
	 * Indica si la tarjeta permite la consulta de CCV
	 */
    var allowsChangePaymentMethod: Bool {
        return isCardBeneficiary
    }
}

extension CardDetail: OperativeParameter {}
