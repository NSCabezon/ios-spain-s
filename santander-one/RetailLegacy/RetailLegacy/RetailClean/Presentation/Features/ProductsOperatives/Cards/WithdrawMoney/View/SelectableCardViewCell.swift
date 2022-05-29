//

import UIKit

class SelectableCardViewCell: BaseViewCell {
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var cardName: UILabel!
    @IBOutlet weak var cardAccount: UILabel!
    @IBOutlet weak var cardItemQuantityTitle: UILabel!
    @IBOutlet weak var cardItemQuantity: UILabel!
    @IBOutlet weak var cardItemImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoContainer.drawRoundedAndShadowed()
        infoContainer.backgroundColor = .uiWhite
        cardName.applyStyle(LabelStylist.pgProductName)
        cardAccount.applyStyle(LabelStylist.pgProductSubName)
        cardItemQuantityTitle.applyStyle(LabelStylist.pgProductSubName)
        cardItemQuantity.applyStyle(LabelStylist.pgProductAmount)
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    var cardItemImage: UIImageView? {
        get {
            return cardItemImageView
        }
        set {
            cardItemImageView = newValue
        }
    }
    
    var name: String? {
        get {
            return cardName.text
        }
        set {
            cardName.text = newValue
        }
    }
    
    var subname: String? {
        get {
            return cardAccount.text
        }
        set {
            cardAccount.text = newValue
        }
    }
    
    var quantity: String? {
        get {
            return cardItemQuantity.text
        }
        set {
            cardItemQuantity.text = newValue
            cardItemQuantity.scaleDecimals()
            cardItemQuantity.isHidden = false
        }
    }
    
    var quantityTitle: String? {
        get {
            return cardItemQuantityTitle.text
        }
        set {
            cardItemQuantityTitle.text = newValue
            cardItemQuantityTitle.isHidden = false
        }
    }
    
    func hideAvailableMoney() {
        cardItemQuantity.text = ""
        cardItemQuantityTitle.text = ""
        cardItemQuantity.isHidden = true
        cardItemQuantityTitle.isHidden = true
    }
}
