import UIKit

class FavoriteRecipientStackView: StackItemView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var aliasLabel: UILabel!
    
    func setTitle(_ title: LocalizedStylableText?) {
        guard let title = title else {
            titleLabel.text = nil
            return
        }
        titleLabel.set(localizedStylableText: title)
    }
    
    func setText(_ text: String?) {
        guard let text = text else {
            aliasLabel.text = nil
            return
        }
        aliasLabel.text = text
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium,
                                           font: UIFont.latoRegular(size: 14),
                                           textAlignment: .left))
        aliasLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                           font: UIFont.latoRegular(size: 16),
                                           textAlignment: .left))
        contentView.drawRoundedAndShadowed()
    }
}
