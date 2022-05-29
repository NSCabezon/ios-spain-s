import Foundation

class TitleWithDescriptionStackModel: StackItem<TitleWithDescriptionStackView> {
    // MARK: - Private attributes
    
    private let title: LocalizedStylableText
    private let subtitle: LocalizedStylableText
    
    // MARK: - Public methods
    
    init(title: LocalizedStylableText, subtitle: LocalizedStylableText, insets: Insets = Insets(left: 14, right: 20, top: 20, bottom: 0)) {
        self.title = title
        self.subtitle = subtitle
        super.init(insets: insets)
    }
    
    override func bind(view: TitleWithDescriptionStackView) {
        view.setTitle(title)
        view.setSubtitle(subtitle)
    }
}
