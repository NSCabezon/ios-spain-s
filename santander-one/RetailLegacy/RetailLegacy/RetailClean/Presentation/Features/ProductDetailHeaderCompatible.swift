//

import Foundation

protocol ProductDetailHeaderCompatible {
    var cardImage: String? { get }
    var cardNumber: String? { get }
    var cardExpirationDate: String? { get }
    var cardUserName: String? { get }
    var cardType: CardType { get }
}
