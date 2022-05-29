import UIKit

class TitleWithDescriptionStackView: StackItemView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        separatorView.backgroundColor = .lisboaGray
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16)))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14)))
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func setSubtitle(_ subtitle: LocalizedStylableText) {
        subtitleLabel.set(localizedStylableText: subtitle)
    }
}
