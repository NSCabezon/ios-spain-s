protocol StackItemProtocol {
    var reuseIdentifier: String { get }
    func bind <ViewStackProtocol> (view: ViewStackProtocol)  where ViewStackProtocol: StackItemView
    var accessibilityIdentifier: String? { get set }
}

class StackItem<ViewStack>: StackItemProtocol where ViewStack: StackItemView {
    var reuseIdentifier: String {
        let parts = (String(describing: type(of: ViewStack.self))).split(separator: ".")
        return String(parts[0])
    }
    private let insets: Insets
    var accessibilityIdentifier: String?

    init(insets: Insets) {
        self.insets = insets
    }
    
    func bind<ViewStackProtocol>(view: ViewStackProtocol) {
        if let view = view as? ViewStack {
            view.applyInsets(insets: insets)
            bind(view: view)
        }
    }
    
    func bind(view: ViewStack) {
        fatalError()
    }
}
