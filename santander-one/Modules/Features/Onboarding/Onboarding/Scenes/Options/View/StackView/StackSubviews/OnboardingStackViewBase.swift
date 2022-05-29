import UIKit

class OnboardingStackViewBase: UIView {
    @IBOutlet weak var left: NSLayoutConstraint!
    @IBOutlet weak var right: NSLayoutConstraint!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var bottom: NSLayoutConstraint!

    func applyInsets(insets: OnboardingStackViewInsets) {
        left?.constant = CGFloat(insets.left)
        right?.constant = CGFloat(insets.right)
        top?.constant = CGFloat(insets.top)
        bottom?.constant = CGFloat(insets.bottom)
        layoutSubviews()
    }
}

struct OnboardingStackViewInsets {
    let left: Double
    let right: Double
    let top: Double
    let bottom: Double
}

class OnboardingStackSection {
    private(set) var items: [OnboardingStackItemProtocol]
    
    init() {
       items = []
    }
    
    func add(item: OnboardingStackItemProtocol) {
        items.append(item)
    }
    
    func add(items: [OnboardingStackItemProtocol]) {
        self.items.append(contentsOf: items)
    }
}

protocol OnboardingStackItemProtocol {
    var reuseIdentifier: String { get }
    func bind <ViewStackProtocol> (view: ViewStackProtocol)  where ViewStackProtocol: OnboardingStackViewBase
    var accessibilityIdentifier: String? { get set }
}

class OnboardingStackItem<ViewStack>: OnboardingStackItemProtocol where ViewStack: OnboardingStackViewBase {
    var reuseIdentifier: String {
        let parts = (String(describing: type(of: ViewStack.self))).split(separator: ".")
        return String(parts[0])
    }
    private let insets: OnboardingStackViewInsets
    var accessibilityIdentifier: String?

    init(insets: OnboardingStackViewInsets) {
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
