import UIKit

class FavoriteRecipientStackModel: StackItem<FavoriteRecipientStackView> {
    private let title: LocalizedStylableText?
    private let text: String?
    
    init(title: LocalizedStylableText?, text: String?, insets: Insets = Insets(left: 11, right: 10, top: 15, bottom: 4)) {
        self.title = title
        self.text = text
        super.init(insets: insets)
    }
    
    override func bind(view: FavoriteRecipientStackView) {
        view.setTitle(title)
        view.setText(text)
    }
}
