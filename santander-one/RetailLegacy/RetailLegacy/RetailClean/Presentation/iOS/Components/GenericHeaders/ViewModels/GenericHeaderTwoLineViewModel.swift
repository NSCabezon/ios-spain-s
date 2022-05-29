//

import Foundation

class GenericHeaderTwoLineViewModel: HeaderViewModel<GenericOperativeHeaderTwoLineView> {
    let title: LocalizedStylableText?
    let subtitle: LocalizedStylableText?
    let infoText: LocalizedStylableText?
    
    init(title: LocalizedStylableText?, subtitle: LocalizedStylableText?, infoText: LocalizedStylableText?) {
        self.title = title
        self.subtitle = subtitle
        self.infoText = infoText
    }
    
    override func configureView(_ view: GenericOperativeHeaderTwoLineView) {
        view.titleLabel.set(localizedStylableText: title ?? LocalizedStylableText.empty)
        if let subtitle = subtitle {
            view.amountLabel.set(localizedStylableText: subtitle)
        } else {
            view.amountLabel.isHidden = true
        }
        if let infoText = infoText {
            view.infoLabel.set(localizedStylableText: infoText)
        } else {
            view.infoLabel.isHidden = true
        }
    }
}
