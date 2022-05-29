//
import UIKit

class ProductDetailCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardExpirationLabel: UILabel!
    @IBOutlet weak var cardUserNameLabel: UILabel!
    @IBOutlet weak var bottomSeparator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bottomSeparator.backgroundColor = .lisboaGray
    }
    
}

extension ProductDetailCardCollectionViewCell: ConfigurableCell {
    
    func configure(data: ProductDetailHeader) {
        if let cardImageUrl = data.cardImage {
            data.dependencies.imageLoader.load(relativeUrl: cardImageUrl, imageView: cardImageView, placeholderIfDoesntExist: "defaultCard")
        }
        cardNumberLabel.text = data.cardNumber
        cardExpirationLabel.text = data.cardExpirationDate
        cardUserNameLabel.text = data.cardUserName
        if [.creditCard, .prepaidCard].contains(data.cardType) {
            applyShadow()
        }
    }
    
    private func applyShadow() {
        cardNumberLabel.addShadow(offset: CGSize(width: 1, height: 1), radius: 0, color: .uiBlack, opacity: 0.7)
        cardExpirationLabel.addShadow(offset: CGSize(width: 1, height: 1), radius: 0, color: .uiBlack, opacity: 0.7)
        cardUserNameLabel.addShadow(offset: CGSize(width: 1, height: 1), radius: 0, color: .uiBlack, opacity: 0.7)
    }
    
}
