//

import Foundation

class GenericHeaderDetailCardViewModel: HeaderViewModel<DetailCardView> {
    let userName: LocalizedStylableText?
    let cardNumber: LocalizedStylableText?
    let cardExpiration: LocalizedStylableText?
    let imageURL: String?
    let imageLoader: ImageLoader?
    let cardType: CardType?
    
    init(userName: LocalizedStylableText?, cardNumber: LocalizedStylableText?, cardExpiration: LocalizedStylableText?, imageURL: String?, imageLoader: ImageLoader?, cardType: CardType?) {
        self.userName = userName
        self.cardNumber = cardNumber
        self.cardExpiration = cardExpiration
        self.imageURL = imageURL
        self.imageLoader = imageLoader
        self.cardType = cardType
    }
    
    override func configureView(_ view: DetailCardView) {
        view.cardUserNameLabel.set(localizedStylableText: userName?.uppercased() ?? LocalizedStylableText.empty)
        view.cardNumberLabel.set(localizedStylableText: cardNumber ?? LocalizedStylableText.empty)
        view.cardExpirationLabel.set(localizedStylableText: cardExpiration ?? LocalizedStylableText.empty)
        imageLoader?.load(relativeUrl: imageURL ?? "", imageView: view.cardImageView, placeholder: "defaultCard")
        
        if let type = cardType {
            switch type {
            case .creditCard:
                view.applyShadow()
            case .prepaidCard:
                view.prepaidCardConfig()
            default: break
            }
        }
    }
}
