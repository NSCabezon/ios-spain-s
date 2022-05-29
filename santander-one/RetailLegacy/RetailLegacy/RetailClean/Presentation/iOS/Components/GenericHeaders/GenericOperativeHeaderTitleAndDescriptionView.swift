//

import UIKit

class GenericOperativeHeaderTitleAndDescriptionView: BaseHeader, ViewCreatable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func setDescription(_ description: LocalizedStylableText) {
        descriptionLabel.set(localizedStylableText: description)
    }
    
    func setAccesibilityIds(_ accesibilityIds: GenericOperativeHeaderTitleAndDescriptionAccesibilityIds?) {
        guard let identifiers = accesibilityIds else { return }
        titleLabel.accessibilityIdentifier = identifiers.title
        descriptionLabel.accessibilityIdentifier = identifiers.description
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16)))
        descriptionLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14)))
    }
}
