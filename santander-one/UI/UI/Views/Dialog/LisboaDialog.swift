import UIKit
import CoreFoundationLib

public struct LisboaDialog {
    let items: [LisboaDialogItem]
    let isCloseButtonAvailable: Bool
    let executeCancelActionOnClose: Bool?
    
    public init(items: [LisboaDialogItem], closeButtonAvailable: Bool, executeCancelActionOnClose: Bool? = nil) {
        self.items = items
        self.isCloseButtonAvailable = closeButtonAvailable
        self.executeCancelActionOnClose = executeCancelActionOnClose
    }
    
    public func showIn(_ viewController: UIViewController) {
        let dialogViewController = LisboaDialogViewController(self, nibName: "LisboaDialogViewController", bundle: .module)
        dialogViewController.modalPresentationStyle = .overCurrentContext
        dialogViewController.modalTransitionStyle = .crossDissolve
        viewController.present(dialogViewController, animated: true, completion: nil)
    }
}

// MARK: - LisboaDialogViewController

class LisboaDialogViewController: UIViewController {
    @IBOutlet private var scrolledStackview: Stackview!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var scrollviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var closeButtonContainerView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var bottomStackViewContainer: UIView!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    private let dialog: LisboaDialog
    private var dismissBlock: (() -> Void)?
    private var cancelAction: (() -> Void)?
    
    init(_ dialog: LisboaDialog, nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.dialog = dialog
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupCloseButton(isAvailable: dialog.isCloseButtonAvailable)
        self.scrolledStackview.delegate = self
        self.setupView()
        self.addItems(self.dialog.items)
    }
}

// MARK: - Private Methods

private extension LisboaDialogViewController {
    
    func setupCloseButton(isAvailable: Bool) {
        guard !isAvailable else {
            configureCloseButton()
            return
        }
        self.closeButtonContainerView.removeFromSuperview()
    }
    
    func setupView() {
        self.view.accessibilityIdentifier = LisboaDialogComponent.dialogContainerView
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.26)
        self.containerView.backgroundColor = UIColor.clear
        self.scrollView.backgroundColor = UIColor.white
        self.closeButtonContainerView.backgroundColor = .white
        self.scrolledStackview.backgroundColor = UIColor.clear
        self.scrollView.layer.cornerRadius = 5
        self.scrollView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.scrollView.layer.borderWidth =  1
        self.containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.containerView.layer.shadowRadius = 3
        self.containerView.layer.shadowOpacity = 0.2
        self.containerView.layer.shadowColor = UIColor.black.cgColor
    }
    
    @IBAction func closeView() {
        self.cancelAction?()
        self.dismiss(animated: true, completion: self.dismissBlock)
    }
    
    func addSpace(_ space: CGFloat) {
        let separatorView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.scrolledStackview.frame.size.width, height: space))
        separatorView.backgroundColor = UIColor.white
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.heightAnchor.constraint(equalToConstant: space).isActive = true
        self.addElement(separatorView)
    }
    
    func addElement(_ element: UIView) {
        self.scrolledStackview.addArrangedSubview(element)
    }
    
    func reset() {
        for element in self.scrolledStackview.arrangedSubviews {
            self.scrolledStackview.removeArrangedSubview(element)
            element.removeFromSuperview()
        }
    }
    
    func addItems(_ items: [LisboaDialogItem]) {
        var lastIndex: Int
        let lastSpace: CGFloat?
        if #available(iOS 11.0, *), items.count > 1, case .margin(let space) = items.last {
            lastIndex = items.count - 2
            lastSpace = space
        } else {
            lastIndex = items.count - 1
            lastSpace = nil
        }
        if items.count > 0 {
            for index in 0...lastIndex {
                let item = items[index]
                switch item {
                case .margin(let space):
                    if #available(iOS 11.0, *), index != items.count - 1, let lastView = self.scrolledStackview.arrangedSubviews.last {
                        self.scrolledStackview.setCustomSpacing(space, after: lastView)
                    } else {
                        self.addSpace(space)
                    }
                case .styledText(let styledItem):
                    let view = self.createStyledTextView(styledItem)
                    self.addElement(view)
                case .verticalAction(let action):
                    let view = self.createVerticalActionView(action)
                    self.addElement(view)
                case .horizontalActions(let actions):
                    self.createHorizontalActionViews(actions)
                case .closeAction(let block):
                    self.dismissBlock = block
                case .image(let imageItem):
                    let view = self.createImageView(imageItem)
                    self.addElement(view)
                case .view(let view):
                    self.addElement(view)
                }
            }
        }
        if let lastSpace = lastSpace {
            self.addSpace(lastSpace)
        }
        self.scrolledStackview.layoutIfNeeded()
    }
    
    func createStyledTextView(_ item: LisboaDialogTextItem) -> UIView {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.scrolledStackview.frame.size.width, height: 10))
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        let label: UILabel = UILabel(frame: CGRect(x: item.margins.left, y: 0, width: self.scrolledStackview.frame.size.width - item.margins.left - item.margins.right, height: 10))
        label.numberOfLines = 0
        label.textColor = item.color
        label.configureText(withLocalizedString: item.text,
                            andConfiguration: LocalizedStylableTextConfiguration(
                                font: item.font,
                                alignment: item.alignament,
                                lineHeightMultiple: item.lineHeightMultiple))
        label.accessibilityIdentifier = item.accesibilityIdentifier
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: item.margins.left).isActive = true
        NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -item.margins.right).isActive = true
        NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        return view
    }
    
    func createVerticalActionView(_ item: VerticalLisboaDialogAction) -> UIView {
        let action = item.lisboaDialogAction
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.scrolledStackview.frame.size.width, height: 40))
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        let button = createLisboaButton(with: action)
        button.accessibilityIdentifier = item.lisboaDialogAction.accesibilityIdentifier
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: action.margins.left).isActive = true
        NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -action.margins.right).isActive = true
        NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        if item.lisboaDialogAction.isCancelAction ?? false { self.cancelAction = item.lisboaDialogAction.action }
        return view
    }
    
    func createHorizontalActionViews(_ item: HorizontalLisboaDialogActions) {
        self.scrolledStackview.addArrangedSubview(bottomStackViewContainer)
        if item.leftAction.isCancelAction ?? false {
            self.cancelAction = item.leftAction.action
        } else if item.rightAction.isCancelAction ?? false {
            self.cancelAction = item.rightAction.action
        }
        let leftButton = createLisboaButton(with: item.leftAction)
        let rightButton = createLisboaButton(with: item.rightAction)
        leftButton.accessibilityIdentifier = item.leftAction.accesibilityIdentifier
        rightButton.accessibilityIdentifier = item.rightAction.accesibilityIdentifier
        [leftButton, rightButton].forEach { buttonsStackView.addArrangedSubview($0) }
    }
    
    func createImageView(_ item: LisboaDialogImageViewItem) -> UIView {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.scrolledStackview.frame.size.width, height: item.size.height))
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: item.image)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: item.size.height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: item.size.width).isActive = true
        return view
    }
    
    func configureCloseButton() {
        self.closeButton.tintColor = .santanderRed
        self.closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
        self.closeButton.addTarget(self, action: #selector(closeButtonSelected), for: .touchUpInside)
        self.closeButton.accessibilityIdentifier = "dialog_button_cancel"
    }
    
    @objc private func closeButtonSelected() {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.dismissBlock?()
            if self?.dialog.executeCancelActionOnClose == true {
                self?.cancelAction?()
            }
        })
    }
    
    func createLisboaButton(with action: LisboaDialogAction) -> LisboaButton {
        var button = LisboaButton()
        self.applyAppearance(to: &button, action)
        button.set(localizedStylableText: action.title, state: UIControl.State.normal)
        self.applyAction(to: &button, action)
        return button
    }
    
    func applyAction(to button: inout LisboaButton, _ item: LisboaDialogAction) {
        button.addAction({ [weak self] in
            self?.dismiss(animated: true, completion: {
                item.action()
                self?.dismissBlock?()
            })
        })
    }
    
    func applyAppearance(to button: inout LisboaButton, _ action: LisboaDialogAction) {
        switch action.type {
        case .red:
            button = RedLisboaButton(frame: CGRect(x: action.margins.left, y: 0.0, width: self.scrolledStackview.frame.size.width - action.margins.left - action.margins.right, height: 40.0))
        case .white:
            button = WhiteLisboaButton(frame: CGRect(x: action.margins.left, y: 0.0, width: self.scrolledStackview.frame.size.width - action.margins.right, height: 40.0))
        case .custom(backgroundColor: let backgroundColor, titleColor: let titleColor, font: let font):
            button = LisboaButton(frame: CGRect(x: action.margins.left, y: 0.0, width: self.scrolledStackview.frame.size.width - action.margins.right, height: 40.0))
            button.backgroundColor = backgroundColor
            button.setTitleColor(titleColor, for: .normal)
            button.titleLabel?.font = font
        }
    }
}

// MARK: - FullScreenToolTipViewController

extension LisboaDialogViewController: StackviewDelegate {
    func didChangeBounds(for stackview: UIStackView) {
        self.scrollviewHeightConstraint.constant = stackview.frame.size.height
    }
}

// MARK: - UIGestureRecognizerDelegate

extension LisboaDialogViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl) && (touch.view == view)
    }
}

// MARK: - Configuration Items

public enum LisboaDialogActionType {
    case white
    case red
    case custom(backgroundColor: UIColor, titleColor: UIColor, font: UIFont)
}

public struct LisboaDialogAction {
    let title: LocalizedStylableText
    let action: () -> Void
    let type: LisboaDialogActionType
    let margins: (left: CGFloat, right: CGFloat)
    let accesibilityIdentifier: String?
    let isCancelAction: Bool?
    
    public init(title: LocalizedStylableText, type: LisboaDialogActionType, margins: (left: CGFloat, right: CGFloat), accesibilityIdentifier: String? = nil, isCancelAction: Bool? = false, action: @escaping () -> Void) {
        self.title = title
        self.margins = margins
        self.action = action
        self.type = type
        self.accesibilityIdentifier = accesibilityIdentifier
        self.isCancelAction = isCancelAction
    }
}

public struct VerticalLisboaDialogAction {
    let lisboaDialogAction: LisboaDialogAction
    
    public init(title: LocalizedStylableText, type: LisboaDialogActionType, margins: (left: CGFloat, right: CGFloat), accesibilityIdentifier: String? = nil, isCancelAction: Bool? = false, action: @escaping () -> Void) {
        self.lisboaDialogAction = LisboaDialogAction(title: title,
                                                     type: type,
                                                     margins: margins,
                                                     accesibilityIdentifier: accesibilityIdentifier,
                                                     isCancelAction: isCancelAction,
                                                     action: action
        )
    }
}

public struct HorizontalLisboaDialogActions {
    let leftAction: LisboaDialogAction
    let rightAction: LisboaDialogAction
    
    public init(left: LisboaDialogAction, right: LisboaDialogAction) {
        self.leftAction = left
        self.rightAction = right
    }
}

public struct LisboaDialogTextItem {
    let text: LocalizedStylableText
    let font: UIFont
    let color: UIColor
    let alignament: NSTextAlignment
    let margins: (left: CGFloat, right: CGFloat)
    let accesibilityIdentifier: String?
    let lineHeightMultiple: CGFloat
    
    public init(text: LocalizedStylableText,
                font: UIFont,
                color: UIColor,
                alignament: NSTextAlignment,
                margins: (left: CGFloat, right: CGFloat),
                accesibilityIdentifier: String? = nil,
                lineHeightMultiple: CGFloat = 0.0) {
        self.text = text
        self.font = font
        self.color = color
        self.alignament = alignament
        self.margins = margins
        self.accesibilityIdentifier = accesibilityIdentifier
        self.lineHeightMultiple = lineHeightMultiple
    }
}

public struct LisboaDialogImageViewItem {
    let image: UIImage?
    let size: (width: CGFloat, height: CGFloat)
    let contentMode: UIView.ContentMode?
    
    public init(image: UIImage?,
                size: (CGFloat, CGFloat),
                contentMode: UIView.ContentMode? = .scaleAspectFit) {
        self.image = image
        self.size = size
        self.contentMode = contentMode
    }
}

public enum LisboaDialogItem {
    case styledText(LisboaDialogTextItem)
    case verticalAction(VerticalLisboaDialogAction)
    case margin(CGFloat)
    case horizontalActions(HorizontalLisboaDialogActions)
    case image(LisboaDialogImageViewItem)
    case closeAction(() -> Void)
    case view(UIView)
}
