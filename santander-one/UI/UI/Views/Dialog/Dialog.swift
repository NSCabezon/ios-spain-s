import UIKit
import CoreFoundationLib

public struct Dialog {
    let title: String?
    let image: String?
    let actionButton: Action?
    let items: [Item]
    let closeButton: CloseButton
    let accessibilityIdActionButton: String?
    let accessibilityIdTitle: String?
    let hasTitleAndNotAlignment: Bool
    
    public enum Item {
        
        public struct Margin {
            
            let top: Float
            let left: Float
            let right: Float
            
            public static func zero() -> Margin {
                return Margin(top: 0, left: 0, right: 0)
            }
        }
        
        case text(String)
        case styledText(LocalizedStylableText, identifier: String? = nil, hasTitleAndNotAlignment: Bool)
        case styledConfiguredText(LocalizedStylableText, configuration: LocalizedStylableTextConfiguration, identifier: String? = nil)
        case listItem(String, margin: Margin)
        
        public static func listItem(_ value: String) -> Item {
            return .listItem(value, margin: .zero())
        }
    }
    
    public struct Action {
        
        public let title: String
        public let action: () -> Void
        public let style: ActionStyle
        
        public init(title: String, action: @escaping () -> Void) {
            self.title = title
            self.action = action
            self.style = .white
        }
        
        public init(title: String, style: ActionStyle, action: @escaping () -> Void) {
            self.title = title
            self.style = style
            self.action = action
        }
    }
    
    public enum ActionStyle {
        case white
        case red
    }
    
    public enum CloseButton {
        case none
        case available
        case availableWithAction(_ action: () -> Void)
    }
    
    public init(
        title: String?,
        items: [Item],
        image: String?,
        actionButton: Action?,
        closeButton: CloseButton,
        accessibilityIdTitle: String = "",
        accessibilityIdActionButton: String = "",
        hasTitleAndNotAlignment: Bool
    ) {
        self.title = title
        self.image = image
        self.actionButton = actionButton
        self.items = items
        self.closeButton = closeButton
        self.accessibilityIdActionButton = accessibilityIdActionButton
        self.accessibilityIdTitle = accessibilityIdTitle
        self.hasTitleAndNotAlignment = hasTitleAndNotAlignment
    }
    
    public init(
        title: String?,
        items: [Item],
        image: String?,
        actionButton: Action?,
        isCloseButtonAvailable: Bool,
        accessibilityIdTitle: String = "",
        accessibilityIdActionButton: String = "",
        hasTitleAndNotAlignment: Bool = true
    ) {
        self.title = title
        self.image = image
        self.actionButton = actionButton
        self.items = items
        if isCloseButtonAvailable {
            self.closeButton = .available
        } else {
            self.closeButton = .none
        }
        self.accessibilityIdActionButton = accessibilityIdActionButton
        self.accessibilityIdTitle = accessibilityIdTitle
        self.hasTitleAndNotAlignment = hasTitleAndNotAlignment
    }
    
    public func show(in viewController: UIViewController) {
        let dialogViewController = DialogViewController(with: self, nibName: "Dialog", bundle: .module)
        dialogViewController.modalPresentationStyle = .overCurrentContext
        dialogViewController.modalTransitionStyle = .crossDissolve
        viewController.present(dialogViewController, animated: true, completion: nil)
    }
}

private class DialogViewController: UIViewController {
    private let dialog: Dialog
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bottomButtonContainerView: UIView!
    @IBOutlet private weak var bottomButton: WhiteLisboaButton!
    @IBOutlet private weak var redBottomButton: RedLisboaButton!
    @IBOutlet private weak var closeButtonContainerView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollViewHeight: NSLayoutConstraint!
    private var isReady: Bool = false
    private var action: (() -> Void)?
    
    init(with dialog: Dialog, nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.dialog = dialog
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupTitle(self.dialog.title)
        self.setupImage(self.dialog.image)
        self.setupActionButton(self.dialog.actionButton)
        self.setupCloseButton(self.dialog.closeButton)
        self.setupItems(self.dialog.items)
        self.contentView.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollViewHeight.constant = self.scrollView.contentSize.height
    }
}

// MARK: - Private functions
extension DialogViewController {
    private func setupImage(_ name: String?) {
        guard let name = name else { return self.imageContainerView.isHidden = true }
        self.imageView.image = Assets.image(named: name)
    }
    
    private func setupTitle(_ title: String?) {
        guard let title = title else {
            self.titleLabel.text = nil
            return
        }
        self.titleLabel.configureText(withKey: title)
        self.setAccessibilityIdentificatorTitle()
    }
    
    private func setupActionButton(_ actionButton: Dialog.Action?) {
        guard let actionButton = actionButton else { return self.bottomButtonContainerView.isHidden = true }
        self.action = actionButton.action
        switch actionButton.style {
        case .white:
            self.bottomButton.setTitle(localized(actionButton.title), for: .normal)
            self.bottomButton.addSelectorAction(target: self, #selector(bottomButtonSelected))
            self.bottomButton.isHidden = false
            self.redBottomButton.isHidden = true
            self.setAccessibilityIdentificatorBottomButton()
        case .red:
            self.redBottomButton.setTitle(localized(actionButton.title), for: .normal)
            self.redBottomButton.addSelectorAction(target: self, #selector(bottomButtonSelected))
            self.bottomButton.isHidden = true
            self.redBottomButton.isHidden = false
            self.setAccessibilityIdentificatorRedButton()
        }
    }
    
    private func setupItems(_ items: [Dialog.Item]) {
        items.forEach { item in
            switch item {
            case .text(let string): self.addText(string, hasTitleAndNotAlignment: true)
            case .listItem(let title, margin: let margin): self.addListItem(title, margin: margin)
            case .styledText(let title, let identifier, let hasTitleAndNotAlignment): self.addStyledText(title, identifier: identifier, hasTitleAndNotAlignment: hasTitleAndNotAlignment)
            case .styledConfiguredText(let title, let configuration, let identifier): self.addStyledText(title, configuration: configuration, identifier: identifier, hasTitleAndNotAlignment: true)
            }
        }
    }
    
    private func setupCloseButton(_ closeButton: Dialog.CloseButton) {
        switch closeButton {
        case .available, .availableWithAction:
            self.closeButton.isHidden = false
        case .none:
            self.closeButton.isHidden = true
        }
    }
    
    private func setupView() {
        self.contentView.isHidden = true
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.masksToBounds = true
        self.closeButton.tintColor = .santanderRed
        self.closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
        self.closeButton.addTarget(self, action: #selector(closeButtonSelected), for: .touchUpInside)
        self.titleLabel.font = .santander(family: .headline, type: .regular, size: 28)
        self.titleLabel.textColor = .black
    }
    
    private func addText(_ text: String, hasTitleAndNotAlignment: Bool) {
        self.addStyledText(localized(text), identifier: text, hasTitleAndNotAlignment: hasTitleAndNotAlignment)
    }
    
    private func addStyledText(_ localizedStylableText: LocalizedStylableText,
                               configuration: LocalizedStylableTextConfiguration? = nil,
                               identifier: String? = nil,
                               hasTitleAndNotAlignment: Bool) {
        let label = UILabel()
        if let font = configuration?.font {
            label.font = font
        } else {
            label.font = .santander(family: .text, type: .regular, size: 16)
        }
        if !hasTitleAndNotAlignment {
            label.textAlignment = .center
            setupCloseButton(.none)
        }
        label.textColor = .lisboaGray
        label.configureText(withLocalizedString: localizedStylableText, andConfiguration: configuration)
        label.numberOfLines = 0
        label.accessibilityIdentifier = identifier
        self.contentStackView.addArrangedSubview(label)
    }
    
    private func addListItem(_ text: String, margin: Dialog.Item.Margin) {
        let itemStackView = UIStackView()
        itemStackView.axis = .horizontal
        itemStackView.distribution = .fill
        let roundedViewContainerView = UIView()
        let roundedView = UIView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        roundedView.layer.cornerRadius = 3
        roundedView.backgroundColor = .black
        roundedViewContainerView.addSubview(roundedView)
        let label = UILabel()
        label.font = .santander(family: .text, type: .light, size: 15)
        label.configureText(withKey: text)
        label.numberOfLines = 0
        label.accessibilityIdentifier = text
        itemStackView.addArrangedSubview(roundedViewContainerView)
        itemStackView.addArrangedSubview(label)
        NSLayoutConstraint.activate([
            roundedView.topAnchor.constraint(equalTo: roundedViewContainerView.topAnchor, constant: 10 + CGFloat(margin.top)),
            roundedView.leftAnchor.constraint(equalTo: roundedViewContainerView.leftAnchor, constant: 10 + CGFloat(margin.left)),
            roundedView.rightAnchor.constraint(equalTo: roundedViewContainerView.rightAnchor, constant: -10 + CGFloat(margin.right)),
            roundedView.heightAnchor.constraint(equalToConstant: 6),
            roundedView.widthAnchor.constraint(equalToConstant: 6)
        ])
        self.contentStackView.addArrangedSubview(itemStackView)
    }
    
    @objc private func closeButtonSelected() {
        self.dismiss(animated: true) { [weak self] in
            switch self?.dialog.closeButton {
            case .availableWithAction(let action)?:
                action()
            case .none, .available?, .none?:
                break
            }
        }
    }
    
    @objc private func bottomButtonSelected() {
        self.dismiss(animated: true) { [weak self] in
            self?.action?()
        }
    }
    
    private func setAccessibilityIdentificatorBottomButton() {
        guard let accIdentText = dialog.accessibilityIdActionButton else {
            return
        }
        self.bottomButton.accessibilityIdentifier = accIdentText
    }
    
    private func setAccessibilityIdentificatorRedButton() {
        guard let accIdentText = dialog.accessibilityIdActionButton else {
            return
        }
        self.redBottomButton.accessibilityIdentifier = accIdentText
    }
    
    private func setAccessibilityIdentificatorTitle() {
        guard let accIdentText = dialog.accessibilityIdTitle else {
            return
        }
        self.titleLabel.accessibilityIdentifier = accIdentText
    }
}
