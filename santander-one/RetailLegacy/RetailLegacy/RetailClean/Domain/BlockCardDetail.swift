import SANLegacyLibrary

struct BlockCardDetail {
    private(set) var cardDTO: CardDTO
    private(set) var card: Card
    
    private init(dto: CardDTO, cardSelected: Card) {
        cardDTO = dto
        card = cardSelected
    }
    
    static func create(_ dto: CardDTO, card: Card) -> BlockCardDetail {
        return BlockCardDetail(dto: dto, cardSelected: card)
    }
    
    var getDetailUI: String {
        return card.getDetailUI()
    }
    
    var isCreditCard: Bool {
        return card.isCreditCard
    }
    
    var isDebitCard: Bool {
        return card.isDebitCard
    }
    
    var isPrepaidCard: Bool {
        return card.isPrepaidCard
    }
    
    var trackId: String {
        if isCreditCard {
            return "credito"
        } else if isPrepaidCard {
            return "prepago"
        } else {
            return "debito"
        }
    }
    
    var getAlias: String {
        return card.getAlias().camelCasedString
    }
    
    var buildImageRelative: String {
        return card.buildImageRelativeUrl(false)
    }
    
    var getCreditBalance: String {
        let creditCard = (card as? CreditCard)
        return creditCard?.getCreditBalance().getFormattedAmountUI() ?? ""
    }
    
    var amountUI: String {
        return card.getAmountUI()
    }
    
    func buildImageRelativeUrl(_ miniature: Bool) -> String? {
        return card.buildImageRelativeUrl(miniature)
    }
    
}

extension BlockCardDetail: OperativeParameter {}
