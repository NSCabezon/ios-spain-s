import UI
import CoreFoundationLib

protocol CollapsibleBehavior: class {
    var stackView: UIStackView! { get }
    func collapse()
    func expand()
}

extension CollapsibleBehavior {
    func collapse() {
        guard stackView.subviews.count > 1 else { return }
        stackView.subviews.enumerated().forEach { index, view in
            guard index > 0 else { return }
            view.isHidden = true
        }
    }
    
    func expand() {
        stackView.subviews.forEach { view in
            view.isHidden = false
        }
    }
}

final class ReceiverDetailViewContainer: XibView {
    @IBOutlet weak private var destinationLabel: UILabel! {
        didSet {
            self.destinationLabel.font = .santander(family: .text, type: .regular, size: 13)
            self.destinationLabel.textColor = .grafite
        }
    }
    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            stackView.accessibilityIdentifier = AccessibilityBizumDetail.bizumDetailListReceiver
        }
    }
    
    convenience init(_ receivers: [ReceiverDetailViewModel], title: TextWithAccessibility) {
        self.init(frame: .zero)
        self.setupViewModel(receivers)
        self.destinationLabel.text = localized(title.text)
        self.destinationLabel.accessibilityIdentifier = title.accessibility
    }
}

private extension ReceiverDetailViewContainer {
    func setupViewModel(_ receivers: [ReceiverDetailViewModel]) {
        receivers.forEach { viewModel in
            let containerView = ReceiverDetailView()
            containerView.setupViewModel(viewModel)
            self.stackView.addArrangedSubview(containerView)
        }
    }
}

extension ReceiverDetailViewContainer: CollapsibleBehavior {}
