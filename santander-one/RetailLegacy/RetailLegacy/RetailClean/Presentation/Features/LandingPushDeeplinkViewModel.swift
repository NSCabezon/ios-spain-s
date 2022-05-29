import Foundation
import CoreFoundationLib

class LandingPushDeeplinkViewModel: TableModelViewItem<LandingPushDeeplinkTableViewCell> {
    private let deeplinkName: LocalizedStylableText
    private let icnImage: String
    private let isBold: Bool?
    let deeplink: DeepLink
    
    init(deeplinkName: LocalizedStylableText, icnImage: String, isBold: Bool? = false, deeplink: DeepLink, dependencies: PresentationComponent) {
        self.deeplinkName = deeplinkName
        self.icnImage = icnImage
        self.isBold = isBold
        self.deeplink = deeplink
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: LandingPushDeeplinkTableViewCell) {
        viewCell.setDeeplinkName(name: deeplinkName)
        viewCell.setImage(image: icnImage)
        viewCell.setBold(isBold: isBold)
    }
}
