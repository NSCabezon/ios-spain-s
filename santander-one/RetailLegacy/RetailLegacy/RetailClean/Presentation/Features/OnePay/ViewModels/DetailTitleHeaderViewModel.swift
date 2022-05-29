import Foundation

enum BackgroundColorCell {
    case clear
    case opaque
}

class DetailTitleHeaderViewModel: TableModelViewHeader<DetailTitleHeader> {
    let title: LocalizedStylableText?
    let color: BackgroundColorCell?
    let titleAccessibilityIdentifier: String?
    
    init(title: LocalizedStylableText?, color: BackgroundColorCell? = .clear, titleAccessibilityIdentifier: String? = nil) {
        self.title = title
        self.color = color
        self.titleAccessibilityIdentifier = titleAccessibilityIdentifier
    }
    
    override func bind(viewHeader: DetailTitleHeader) {
        viewHeader.setTitle(title)
        viewHeader.setColor(color)
        viewHeader.setAccessibilityIdentifiers(titleAccessibilityIdentifier)
    }
}
