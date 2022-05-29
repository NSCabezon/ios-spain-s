//

import Foundation

class GenericHeaderCardViewModel: HeaderViewModel<GenericOperativeCardHeaderView> {
    let title: LocalizedStylableText?
    let subtitle: LocalizedStylableText?
    let rightTitle: LocalizedStylableText?
    let amount: LocalizedStylableText?
    let imageURL: String?
    let imageLoader: ImageLoader?
    
    init(title: LocalizedStylableText?, subtitle: LocalizedStylableText?, rightTitle: LocalizedStylableText?, amount: LocalizedStylableText?, imageURL: String?,
         imageLoader: ImageLoader?) {
        self.title = title
        self.subtitle = subtitle
        self.rightTitle = rightTitle
        self.amount = amount
        self.imageURL = imageURL
        self.imageLoader = imageLoader
    }
    
    override func configureView(_ view: GenericOperativeCardHeaderView) {
        view.titleLabel.set(localizedStylableText: title?.uppercased() ?? LocalizedStylableText.empty)
        view.subtitleLabel.set(localizedStylableText: subtitle ?? LocalizedStylableText.empty)
        view.rightInfoLabel.set(localizedStylableText: rightTitle ?? LocalizedStylableText.empty)
        view.amountLabel.set(localizedStylableText: amount ?? LocalizedStylableText.empty)
        imageLoader?.load(relativeUrl: imageURL ?? "", imageView: view.cardImageView, placeholder: "defaultCard")
    }
}
