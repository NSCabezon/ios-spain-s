//

import Foundation

enum CardType {
    case creditCard
    case debitCard
    case prepaidCard
}

struct ProductDetailHeader: ProductDetailHeaderCompatible {
    var cardImage: String?
    var cardNumber: String?
    var cardExpirationDate: String?
    var cardUserName: String?
    var dependencies: PresentationComponent
    var cardType: CardType
}
