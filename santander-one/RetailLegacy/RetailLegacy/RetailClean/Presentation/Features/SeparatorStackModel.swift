import Foundation

class SeparatorStackModel: StackItem<SeparatorItemView> {
    private let size: Double
    // Nothing to set here
    
    init(size: Double, insets: Insets = Insets(left: 14, right: 14, top: 0, bottom: 0)) {
        self.size = size
        super.init(insets: insets)
    }
    
    override func bind(view: SeparatorItemView) {
        view.applyHeight(height: size)
    }
}
