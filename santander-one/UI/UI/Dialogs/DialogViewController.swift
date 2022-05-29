import UIKit
import CoreFoundationLib

public protocol ViewControllerProxy {
    var viewController: UIViewController { get }
}

extension UIViewController: ViewControllerProxy {
    public var viewController: UIViewController {
        return self
    }
}

public protocol OldDialogViewPresentationCapable: GenericErrorDialogPresentationCapable {
    var associatedOldDialogView: UIViewController { get }
    func showOldDialog<Error: StringErrorOutput>(
        withDependenciesResolver dependenciesResolver: DependenciesResolver,
        for error: UseCaseError<Error>,
        acceptAction: DialogButtonComponents,
        cancelAction: DialogButtonComponents?,
        isCloseOptionAvailable: Bool
    )
    func showOldDialog(
        title: LocalizedStylableText?,
        description: LocalizedStylableText,
        acceptAction: DialogButtonComponents,
        cancelAction: DialogButtonComponents?,
        isCloseOptionAvailable: Bool
    )
}

public extension OldDialogViewPresentationCapable where Self: UIViewController {
    
    var associatedOldDialogView: UIViewController {
        return self
    }
}

public extension OldDialogViewPresentationCapable {
    
    func showOldDialog<Error: StringErrorOutput>(
        withDependenciesResolver dependenciesResolver: DependenciesResolver,
        for error: UseCaseError<Error>,
        acceptAction: DialogButtonComponents,
        cancelAction: DialogButtonComponents?,
        isCloseOptionAvailable: Bool
    ) {
        switch error {
        case .error(error: let error):
            guard let errorDesc = error?.getErrorDesc() else { return self.showGenericErrorDialog(withDependenciesResolver: dependenciesResolver) }
            self.showOldDialog(
                title: nil,
                description: localized(errorDesc),
                acceptAction: acceptAction,
                cancelAction: cancelAction,
                isCloseOptionAvailable: isCloseOptionAvailable
            )
        default:
            self.showGenericErrorDialog(withDependenciesResolver: dependenciesResolver)
        }
    }
    
    func showOldDialog(
        title: LocalizedStylableText?,
        description: LocalizedStylableText,
        acceptAction: DialogButtonComponents,
        cancelAction: DialogButtonComponents?,
        isCloseOptionAvailable: Bool
    ) {
        OldDialog.alert(
            title: title,
            body: description,
            withAcceptComponent: acceptAction,
            withCancelComponent: cancelAction,
            showsCloseButton: isCloseOptionAvailable,
            source: self.associatedOldDialogView,
            completion: cancelAction?.action
        )
    }
}

public class OldDialog {
    /**
     Genera un diálogo con dos botones, uno de cancelar y otro para aceptar.
     Si el componente de cancelar es nil, entonces el botón de cancelar desaparece.
     Si el título es nil, entonces el título desaparece.
     */
    static public func alert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?, showsCloseButton closeButton: Bool = false, source: UIViewController, shouldTriggerHaptic: Bool = false, completion: (() -> Void)? = nil) {
        let dialog = DialogViewController(source: source)
        if let cancel = cancel {
            dialog.alertCancel(title, message, accept, cancel, closeButton, completion: completion)
        } else {
            dialog.alertNormalButtons(title, message, accept, nil, closeButton)
        }
        if shouldTriggerHaptic {
            HapticTrigger.alert()
        }
    }
    
    static public func alert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?, showsCloseButton closeButton: Bool = false, source: ViewControllerProxy, shouldTriggerHaptic: Bool = false, completion: (() -> Void)? = nil) {
        let dialog = DialogViewController(source: source.viewController)
        if let cancel = cancel {
            dialog.alertCancel(title, message, accept, cancel, closeButton, completion: completion)
        } else {
            dialog.alertNormalButtons(title, message, accept, nil, closeButton)
        }
        if shouldTriggerHaptic {
            HapticTrigger.alert()
        }
    }
    
    static func alertLeftALign(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?, showsCloseButton closeButton: Bool = false, source: ViewControllerProxy, shouldTriggerHaptic: Bool = false) {
        let dialog = DialogViewController(source: source.viewController)
        if let cancel = cancel {
            dialog.alertCancelLeftAlign(title, message, accept, cancel, closeButton)
        } else {
            dialog.alertNormalButtons(title, message, accept, nil, closeButton)
        }
        if shouldTriggerHaptic {
            HapticTrigger.alert()
        }
    }
    
    /**
     Genera un diálogo con dos posibles acciones. Para salir, se usa la cruz.
     Si el componente de cualquiera de ellos es nil, entonces ese botón desaparece. Si los dos lo son, entonces no hay botones.
     Si el título es nil, el título desaparece.
     */
    static func alert(title: LocalizedStylableText?, body message: LocalizedStylableText, rightButton: DialogButtonComponents?, leftButton: DialogButtonComponents?, source: ViewControllerProxy, shouldTriggerHaptic: Bool = false) {
        let dialog = DialogViewController(source: source.viewController)
        dialog.alertNormalButtons(title, message, rightButton, leftButton)
        if shouldTriggerHaptic {
            HapticTrigger.alert()
        }
    }
    
    /**
     Genera un diálogo con dos posibles acciones. Para salir, se usa la cruz.
     Si el componente de cualquiera de ellos es nil, entonces ese botón desaparece. Si los dos lo son, entonces no hay botones.
     Si el título es nil, el título desaparece.
     */
    static func alert(title: LocalizedStylableText?, body message: LocalizedStylableText, rightButton: DialogButtonComponents?, leftButton: DialogButtonComponents?, source: ViewControllerProxy, showCloseButton: Bool, shouldTriggerHaptic: Bool = false) {
        let dialog = DialogViewController(source: source.viewController)
        dialog.alertNormalButtons(title, message, rightButton, leftButton, showCloseButton)
        if shouldTriggerHaptic {
            HapticTrigger.alert()
        }
    }
    
    /**
     Genera un diálogo sin acciones ni botones. Para salir, se usa la cruz.
     Al no tener botones, tiene debajo del separador una label.
     Si el título es nil, el título desaparece.
     */
    static func alert(title: LocalizedStylableText?, body message: LocalizedStylableText, footer subtext: LocalizedStylableText, source: ViewControllerProxy, shouldTriggerHaptic: Bool = false, completion: (() -> Void)? = nil) {
        let dialog = DialogViewController(source: source.viewController)
        dialog.alertWithFooter(title, message, subtext, completion)
        if shouldTriggerHaptic {
            HapticTrigger.alert()
        }
    }
    
    /**
     Genera un diálogo sin acciones ni botones. Para salir, se usa la cruz.
     Si el título es nil, el título desaparece.
     */
    static func alert(title: LocalizedStylableText?, body message: LocalizedStylableText, source: ViewControllerProxy, shouldTriggerHaptic: Bool = false) {
        let dialog = DialogViewController(source: source.viewController)
        dialog.alertWithoutFooter(title, message)
        if shouldTriggerHaptic {
            HapticTrigger.alert()
        }
    }
    
    /**
     Genera un diálogo sin acciones ni botones. Para salir, se usa la cruz.
     Este diálogo contiene una imagen en la parte superior y después incluye un título de mensaje y un subtexto.
     Si el título es nil, el título desaparece.
     */
    static func alert(title: LocalizedStylableText?, messageTitle message: LocalizedStylableText, subtext: LocalizedStylableText, withImage image: UIImage, source: ViewControllerProxy, shouldTriggerHaptic: Bool = false, completion: (() -> Void)? = nil) {
        let dialog = DialogViewController(source: source.viewController)
        dialog.alertWithImage(title, message, subtext, image, completion: completion)
        if shouldTriggerHaptic {
            HapticTrigger.alert()
        }
    }
    
    static func dismiss(_ completion: @escaping (Bool) -> Void) {
        guard let topViewController = UIApplication.topViewController() as? DialogViewController else { return completion(false) }
        topViewController.dismiss(animated: true) {
            completion(true)
        }
    }
}

private class DialogViewController: UIViewController {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var dialogContainer: UIView!
    @IBOutlet weak var dialogStack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerImageView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var exitButton: ResponsiveButton!    
    @IBOutlet weak var middleSeparator: UIView!
    @IBOutlet weak var messageFooterLabel: UILabel!
    @IBOutlet weak var messageFooterView: UIView!
    @IBOutlet weak var imageStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageStackViewBottomConstraint: NSLayoutConstraint!
    
    weak var dialogBackground: UIView!
    private var source: UIViewController? {
        if sourceViewController?.isViewLoaded == true {
            return sourceViewController
        } else {
            return UIApplication.shared.delegate?.window??.rootViewController
        }
    }
    private weak var sourceViewController: UIViewController?
    
    fileprivate init(source: UIViewController) {
        self.sourceViewController = source
        super.init(nibName: "DialogViewController", bundle: .module)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGUI()
    }
    
    internal func setupGUI() {
        gradientView.backgroundColor = .black
        gradientView.alpha = 0.26
        
        dialogContainer.clipsToBounds = true
        dialogContainer.layer.cornerRadius = 5
        installContainerBackground()
        
        titleLabel.font = UIFont(name: "Lato-Bold", size: 18.0)
        titleLabel.textColor = .santanderRed
        
        exitButton.setImage(Assets.image(named: "icnClosePopupWhite"), for: .normal)
        topSeparator.backgroundColor = .santanderRed
        
        messageLabel.font = UIFont(name: "Lato-Light", size: 14.0)
        messageLabel.textColor = UIColor(white: 74.0 / 255.0, alpha: 1.0)
        
        messageFooterLabel.font = UIFont(name: "Lato-Light", size: 14.0)
        messageFooterLabel.textColor = UIColor(white: 74.0 / 255.0, alpha: 1.0)
        
        middleSeparator.backgroundColor = UIColor(white: 216.0 / 255.0, alpha: 1.0)
        
        bottomSeparator.backgroundColor = UIColor(white: 216.0 / 255.0, alpha: 1.0)
        bottomSeparator.layer.opacity = 1
    }
    
    // Añade la sombra de una alerta.
    private func installContainerBackground() {
        guard dialogBackground == nil, let superview = dialogContainer.superview else { return }
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = dialogContainer.backgroundColor
        background.layer.cornerRadius = 5
        background.layer.shadowOpacity = 0.5
        background.layer.shadowColor = UIColor.black.cgColor
        background.layer.shadowRadius = 14.0
        
        let builder = NSLayoutConstraint.Builder()
            .add(background.topAnchor.constraint(equalTo: dialogContainer.topAnchor))
            .add(background.leadingAnchor.constraint(equalTo: dialogContainer.leadingAnchor))
            .add(background.widthAnchor.constraint(equalTo: dialogContainer.widthAnchor))
            .add(background.heightAnchor.constraint(equalTo: dialogContainer.heightAnchor))
        
        superview.insertSubview(background, belowSubview: dialogContainer)
        
        builder.activate()
        
        dialogBackground = background
    }
    
    func alertCancel(_ title: LocalizedStylableText?, _ message: LocalizedStylableText, _ accept: DialogButtonComponents, _ cancel: DialogButtonComponents, _ closeButton: Bool, completion: (() -> Void)? = nil) {
        view.backgroundColor = .clear
        handleTitle(title)
        messageLabel.configureText(withLocalizedString: message)
        
        let cancelButton =  WhiteLisboaButton(frame: .zero)
        cancelButton.addAction { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: cancel.action)
        }
        cancel.title.text = cancel.title.text
        cancelButton.accessibilityIdentifier = "btnCancel"
        cancelButton.set(localizedStylableText: cancel.title, state: .normal)
        
        buttonsStack.addArrangedSubview(cancelButton)
        
        if closeButton {
            exitButton.onTouchAction = { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true)
                completion?()
            }
        } else {
            exitButton.removeFromSuperview()
        }
        
        let acceptButton = RedLisboaButton(frame: .zero)
        acceptButton.addAction { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: accept.action)
        }
        accept.title.text = accept.title.text
        acceptButton.titleLabel?.textColor = .white
        acceptButton.set(localizedStylableText: accept.title, state: .normal)
        buttonsStack.addArrangedSubview(acceptButton)
        
        middleSeparator.isHidden = true
        messageFooterView.isHidden = true
        
        presentDialog()
    }
    
    func alertCancelLeftAlign(_ title: LocalizedStylableText?, _ message: LocalizedStylableText, _ accept: DialogButtonComponents, _ cancel: DialogButtonComponents, _ closeButton: Bool) {
        view.backgroundColor = .clear
        handleTitleLeftALign(title)
        messageLabel.configureText(withLocalizedString: message)
        let cancelButton = WhiteLisboaButton(frame: .zero)
        cancelButton.addAction { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: cancel.action)
        }
        cancel.title.text = cancel.title.text
        cancelButton.set(localizedStylableText: cancel.title, state: .normal)
        buttonsStack.addArrangedSubview(cancelButton)
        if closeButton {
            exitButton.onTouchAction = { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true)
            }
        } else {
            exitButton.removeFromSuperview()
        }
        let acceptButton = RedLisboaButton(frame: .zero)
        acceptButton.addAction { [weak self]  in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: accept.action)
        }
        accept.title.text = accept.title.text
        acceptButton.set(localizedStylableText: accept.title, state: .normal)
        acceptButton.titleLabel?.textColor = .white
        buttonsStack.addArrangedSubview(acceptButton)
        middleSeparator.isHidden = true
        messageFooterView.isHidden = true
        presentDialog()
    }
    
    func alertNormalButtons(_ title: LocalizedStylableText?, _ message: LocalizedStylableText, _ rightCompletion: DialogButtonComponents?, _ leftCompletion: DialogButtonComponents?, _ showCloseButton: Bool = false) {
        view.backgroundColor = .clear
        handleTitle(title)
        messageLabel.configureText(withLocalizedString: message)
        if let leftCompletion = leftCompletion {
            let leftButton = RedLisboaButton(frame: .zero)
            leftButton.addAction { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true, completion: leftCompletion.action)
            }
            leftButton.set(localizedStylableText: leftCompletion.title, state: .normal)
            leftButton.titleLabel?.textColor = .white
            buttonsStack.addArrangedSubview(leftButton)
        }
        if let rightCompletion = rightCompletion {
            let rightButton = RedLisboaButton(frame: .zero)
            rightButton.addAction { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true, completion: rightCompletion.action)
            }
            rightButton.set(localizedStylableText: rightCompletion.title, state: .normal)
            rightButton.titleLabel?.textColor = .white
            buttonsStack.addArrangedSubview(rightButton)
        }
        if rightCompletion != nil && leftCompletion != nil {
            exitButton.onTouchAction = { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true)
            }
        } else if rightCompletion == nil && leftCompletion == nil {
            bottomSeparator.isHidden = true
            buttonsContainer.isHidden = true
            
            exitButton.onTouchAction = { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true)
            }
        } else {
            if showCloseButton {
                exitButton.onTouchAction = { _ in
                    self.dismiss(animated: true)
                }
            } else {
                exitButton.removeFromSuperview()
            }
        }
        middleSeparator.isHidden = true
        messageFooterView.isHidden = true
        presentDialog()
    }
    
    func alertWithFooter(_ title: LocalizedStylableText?, _ message: LocalizedStylableText, _ subtext: LocalizedStylableText, _ completion: (() -> Void)?) {
        view.backgroundColor = .clear
        handleTitle(title)
        messageLabel.configureText(withLocalizedString: message, andConfiguration: LocalizedStylableTextConfiguration(font: UIFont(name: "Lato-Regular", size: 14)))
        messageLabel.set(lineSpacing: 6.0)
        messageFooterLabel.configureText(withLocalizedString: subtext)
        bottomSeparator.isHidden = true
        buttonsContainer.isHidden = true
        exitButton.onTouchAction = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: completion)
        }
        DispatchQueue.main.async {
            self.presentDialog()
        }
    }
    
    func alertWithoutFooter(_ title: LocalizedStylableText?, _ message: LocalizedStylableText) {
        view.backgroundColor = .clear
        handleTitle(title)
        messageLabel.configureText(withLocalizedString: message, andConfiguration: LocalizedStylableTextConfiguration(font: UIFont(name: "Lato-Regular", size: 14)))
        messageLabel.set(lineSpacing: 6.0)
        bottomSeparator.isHidden = true
        buttonsContainer.isHidden = true
        middleSeparator.isHidden = true
        messageFooterView.isHidden = true
        exitButton.onTouchAction = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true)
        }
        DispatchQueue.main.async {
            self.presentDialog()
        }
    }
    
    func alertWithImage(_ title: LocalizedStylableText?, _ message: LocalizedStylableText, _ subtext: LocalizedStylableText, _ image: UIImage, completion: (() -> Void)?) {
        view.backgroundColor = .clear
        handleTitle(title)
        messageLabel.configureText(withLocalizedString: message, andConfiguration: LocalizedStylableTextConfiguration(font: UIFont(name: "Lato-semibold", size: 16), alignment: .center))
        messageFooterLabel.configureText(withLocalizedString: subtext, andConfiguration: LocalizedStylableTextConfiguration(font: UIFont(name: "Lato-Light", size: 14)))
        imageView.image = image
        imageView.isHidden = false
        containerImageView.isHidden = false
        bottomSeparator.isHidden = true
        buttonsContainer.isHidden = true
        middleSeparator.isHidden = true
        exitButton.onTouchAction = { [weak self] _ in
            self?.dismiss(animated: true) {
                completion?()
            }
        }
        DispatchQueue.main.async {
            self.presentDialog()
        }
    }
    
    private func handleTitle(_ text: LocalizedStylableText?) {
        if let title = text, !title.text.isEmpty {
            titleLabel.configureText(withLocalizedString: title)
        } else {
            messageLabel.textAlignment = .center
            titleView.isHidden = true
            topSeparator.isHidden = true
        }
    }
    
    private func handleTitleLeftALign(_ text: LocalizedStylableText?) {
        if let title = text, !title.text.isEmpty {
            titleLabel.configureText(withLocalizedString: title)
        } else {
            messageLabel.textAlignment = .left
            titleView.isHidden = true
            topSeparator.isHidden = true
        }
    }
    
    private func presentDialog() {
        guard parent == nil else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.source?.present(self, animated: true)
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            completion?()
            self.view = nil
        }
    }
}

private extension UILabel {
    
    func set(lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let attributed = attributedText ?? NSAttributedString(string: text ?? "")
        let mutable = NSMutableAttributedString(attributedString: attributed)
        mutable.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributed.string.count))
        
        let alignment = textAlignment
        attributedText = mutable
        
        textAlignment = alignment
    }
}

extension UIApplication {
    
    public class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
