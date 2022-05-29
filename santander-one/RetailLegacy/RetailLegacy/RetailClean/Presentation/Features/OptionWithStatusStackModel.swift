import Foundation

class OptionWithStatusStackModel: StackItem<OptionWithStatusStackView> {
    // MARK: - Private attributes
    
    private let title: LocalizedStylableText
    private let subtitle: LocalizedStylableText
    private let isChecked: Bool
    private let isFirst: Bool
    private let isLast: Bool
    var action: (() -> Void)?
    
    // MARK: - Public methods
    
    init(title: LocalizedStylableText, subtitle: LocalizedStylableText, isChecked: Bool, isFirst: Bool, isLast: Bool, insets: Insets = Insets(left: 10, right: 10, top: 0, bottom: 0)) {
        self.title = title
        self.subtitle = subtitle
        self.isChecked = isChecked
        self.isFirst = isFirst
        self.isLast = isLast
        super.init(insets: insets)
    }
    
    override func bind(view: OptionWithStatusStackView) {
        view.setTitle(title)
        view.setSubtitle(subtitle)
        view.isFirst = isFirst
        view.isLast = isLast
        view.setChecked(isChecked)
        view.executeAction = { [weak self] in
            self?.action?()
        }
    }
}
