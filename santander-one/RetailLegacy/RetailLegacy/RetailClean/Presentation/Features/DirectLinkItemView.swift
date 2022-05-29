import UIKit

class DirectLinkItemView: UIView {
    @IBOutlet private weak var iconImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var separator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        isOpaque = false
        backgroundColor = .clear
        separator.backgroundColor = .lisboaGray
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14), textAlignment: .center))
    }
    
    func configure(title: LocalizedStylableText, image: UIImage?, isSeparator: Bool) {
        titleLabel.set(localizedStylableText: title)
        iconImage.image = image
        separator.isHidden = !isSeparator
    }
}
