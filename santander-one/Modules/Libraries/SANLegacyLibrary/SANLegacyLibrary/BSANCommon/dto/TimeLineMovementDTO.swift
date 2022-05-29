//

import CoreDomain

public struct TimeLineResponseDTO: Codable {
   public var pagination: TimeLinePaginationDTO
   public var data: TimeLineMovementListDTO
   public var timestamp: String

    enum CodingKeys: String, CodingKey {
        case timestamp
        case pagination = "_links"
        case data = "data"
    }
}

public struct TimeLineMovementListDTO: Codable {
   public var customerId: String
   public var movements: [TimeLineMovementDTO]
}

public struct TimeLineMovementDTO: Codable {
   public var iban: String?
   public var partenon: String
   public var id: String
   public var product: TimeLineProductDTO
   public var merchant: TimeLineMerchantDTO
   public var amount: CurrencyAmountDTO
   public var transaction: TimeLineTransactionDTO
   public var periodicity: String
    
    enum CodingKeys: String, CodingKey {
        case iban
        case partenon
        case id = "movementId"
        case product
        case merchant
        case amount
        case transaction
        case periodicity
    }
    
}

public struct TimeLinePaginationDTO: Codable {
   public var next: String?
   public var prev: String?
   public var current: String?
    
    enum CodingKeys: String, CodingKey {
        case next
        case prev
        case current = "self"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        //next
        let nextLink = try values.decode([String:String]?.self, forKey: .next)
        if let nextParameters = nextLink?.values.first,  let offsetForNext = getOffsetFromUrlParameters(nextParameters) {
            self.next = offsetForNext
        }
            
        //prev
        let prevLink = try values.decode([String:String]?.self, forKey: .prev)
        if let prevParameters = prevLink?.values.first, let offsetForPrev = getOffsetFromUrlParameters(prevParameters) {
            self.prev = offsetForPrev
        }
        
        //current
        let currentLink = try values.decode([String:String]?.self, forKey: .current)
        if let currentParameters = currentLink?.values.first, let offsetForCurrent = getOffsetFromUrlParameters(currentParameters) {
            self.current = offsetForCurrent
        }
    }
    
    private func getOffsetFromUrlParameters(_ parameters: String) -> String? {
        let assembledUrlString = "http:/\(parameters)"
        let urlComponents = URLComponents(string: assembledUrlString)
        if let offsetParameter = urlComponents?.queryItems?.first(where: {$0.name == "offset"}) {
            return offsetParameter.value
        }
        return nil
    }
}

public struct CurrencyAmountDTO: Codable {
   public var value: Decimal
   public var currency: CurrencyDTO
    
    enum CodingKeys: String, CodingKey {
        case value
        case currency
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let amountValue = try values.decode(String.self, forKey: .value)
        let currencyValue = try values.decode(String.self, forKey: .currency)
        self.value = DTOParser.safeDecimal(amountValue) ?? 0.0
        self.currency = CurrencyDTO(currencyName: currencyValue, currencyType: CurrencyType.parse(currencyValue) )
    }
}
