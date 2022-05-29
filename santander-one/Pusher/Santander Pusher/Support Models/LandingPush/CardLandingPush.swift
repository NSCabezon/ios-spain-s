struct CardLandingPush: Encodable {
    var cardName: String
    var bin: String
    var cardType: String
    var pan: String
    var date: String
    var currency: String
    var value: String
    var commerce: String
    let cardPlasticCode: String?
    let productCode: String?
    let subProductCode: String?
}

struct CardAlertInfo: Encodable {
    let name: CardLandingType
    let category: LandingPushCategory = .card
    let user: String
}

enum CardLandingType: String, Encodable {
    case payInCommerce = "0037"
    case cancelBuy = "0038"
    case tradeCommerce = "0038-1"
    case buy = "0039"
    case withDrawCode = "0040"
    case cancelWithDrawCode = "0042"
}
