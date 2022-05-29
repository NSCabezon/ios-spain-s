import UIKit

class SelectorStackModel: StackItem<SelectorStackView> {
    private let placeholder: LocalizedStylableText?
    var title: String? {
        didSet {
            setTitleOnView?(title)
        }
    }
    private var setTitleOnView: ((String?) -> Void)?
    var onSelection: (() -> Void)?
    
    init(placeholder: LocalizedStylableText?, title: String?, insets: Insets = Insets(left: 11, right: 10, top: 15, bottom: 4)) {
        self.placeholder = placeholder
        self.title = title
        super.init(insets: insets)
    }
        
    override func bind(view: SelectorStackView) {
        view.didSelect = onSelection
        setTitleOnView = view.setTitle
        if let title = title {
            view.setTitle(title)
        } else {
            view.setPlaceholder(placeholder ?? .empty)
        }
    }
}
