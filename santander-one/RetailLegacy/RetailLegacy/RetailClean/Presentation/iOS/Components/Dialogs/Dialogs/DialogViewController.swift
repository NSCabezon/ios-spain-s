import UI
import CoreFoundationLib

class Dialog {
    /**
     Genera un diálogo con dos botones, uno de cancelar y otro para aceptar.
     Si el componente de cancelar es nil, entonces el botón de cancelar desaparece.
     Si el título es nil, entonces el título desaparece.
     */
    static func alert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?, showsCloseButton closeButton: Bool = false, source: UIViewController, shouldTriggerHaptic: Bool = false, completion: (() -> Void)? = nil) {
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
    
    static func alert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?, showsCloseButton closeButton: Bool = false, source: ViewControllerProxy, shouldTriggerHaptic: Bool = false, completion: (() -> Void)? = nil) {
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

class DialogViewController: UIViewController {
    
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
            let appDelegate = UIApplication.shared.delegate //as? AppDelegate
            let sourceView = appDelegate?.window??.rootViewController
            return sourceView
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
        gradientView.backgroundColor = UIColor.lisboaGrayNew
        gradientView.alpha = 0.6
        
        dialogContainer.clipsToBounds = true
        dialogContainer.layer.cornerRadius = 5
        installContainerBackground()
        
        titleLabel.font = .latoBold(size: 18.0)
        titleLabel.textColor = .sanRed
        
        topSeparator.backgroundColor = .sanRed
        
        messageLabel.font = .latoLight(size: 14.0)
        messageLabel.textColor = .sanGreyDark
        
        messageFooterLabel.font = .latoLight(size: 14.0)
        messageFooterLabel.textColor = .sanGreyDark
        
        middleSeparator.backgroundColor = .lisboaGray
        
        bottomSeparator.backgroundColor = .lisboaGray
        bottomSeparator.layer.opacity = 1
        exitButton.setImage(Assets.image(named: "icnClosePopupWhite"), for: .normal)
        self.setAccessibilityIdentifiers()
    }
    
    //Añade la sombra de una alerta.
    private func installContainerBackground() {
        guard dialogBackground == nil, let superview = dialogContainer.superview else {
            return
        }
        
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = dialogContainer.backgroundColor
        background.layer.cornerRadius = 5
        background.layer.shadowOpacity = 0.5
        background.layer.shadowColor = UIColor.uiBlack.cgColor
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
        messageLabel.set(localizedStylableText: message)
        
        let cancelButton = WhiteButton(type: .custom)
        cancelButton.onTouchAction = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: cancel.action)
        }
        cancel.title.text = cancel.title.text
        cancelButton.accessibilityIdentifier = "btnCancel"
        cancelButton.set(localizedStylableText: cancel.title, state: .normal)
        cancelButton.configureHighlighted(font: .latoMedium(size: 14))
        cancelButton.adjustTextIntoButton()
        
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
        
        let acceptButton = RedButton(type: .custom)
        acceptButton.onTouchAction = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: accept.action)
        }
        accept.title.text = accept.title.text
        acceptButton.accessibilityIdentifier = "btnAccept"
        acceptButton.set(localizedStylableText: accept.title, state: .normal)
        acceptButton.configureHighlighted(font: .latoMedium(size: 14))
        acceptButton.adjustTextIntoButton()
        buttonsStack.addArrangedSubview(acceptButton)
        
        middleSeparator.isHidden = true
        messageFooterView.isHidden = true
        
        presentDialog()
    }
    
    func alertCancelLeftAlign(_ title: LocalizedStylableText?, _ message: LocalizedStylableText, _ accept: DialogButtonComponents, _ cancel: DialogButtonComponents, _ closeButton: Bool) {
        view.backgroundColor = .clear
        handleTitleLeftALign(title)
        messageLabel.set(localizedStylableText: message)
        
        let cancelButton = WhiteButton(type: .custom)
        cancelButton.onTouchAction = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: cancel.action)
        }
        cancel.title.text = cancel.title.text
        cancelButton.set(localizedStylableText: cancel.title, state: .normal)
        cancelButton.configureHighlighted(font: .latoMedium(size: 14))
        cancelButton.adjustTextIntoButton()
        
        buttonsStack.addArrangedSubview(cancelButton)
        
        if closeButton {
            exitButton.onTouchAction = { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true)
            }
        } else {
            exitButton.removeFromSuperview()
        }
        
        let acceptButton = RedButton(type: .custom)
        acceptButton.onTouchAction = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: accept.action)
        }
        accept.title.text = accept.title.text
        acceptButton.set(localizedStylableText: accept.title, state: .normal)
        acceptButton.configureHighlighted(font: .latoMedium(size: 14))
        acceptButton.adjustTextIntoButton()
        buttonsStack.addArrangedSubview(acceptButton)
        
        middleSeparator.isHidden = true
        messageFooterView.isHidden = true
        
        presentDialog()
    }
    
    func alertNormalButtons(_ title: LocalizedStylableText?, _ message: LocalizedStylableText, _ rightCompletion: DialogButtonComponents?, _ leftCompletion: DialogButtonComponents?, _ showCloseButton: Bool = false) {
        view.backgroundColor = .clear
        handleTitle(title)
        messageLabel.set(localizedStylableText: message)

        if let leftCompletion = leftCompletion {
            let leftButton = RedButton(type: .custom)
            leftButton.onTouchAction = { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true, completion: leftCompletion.action)
            }
            leftButton.set(localizedStylableText: leftCompletion.title, state: .normal)
            leftButton.configureHighlighted(font: .latoMedium(size: 14))
            leftButton.adjustTextIntoButton()
            leftButton.accessibilityIdentifier = AccessibilityDialog.btnCancel
            buttonsStack.addArrangedSubview(leftButton)
        }
        
        if let rightCompletion = rightCompletion {
            let rightButton = RedButton(type: .custom)
            rightButton.onTouchAction = { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true, completion: rightCompletion.action)
            }
            rightButton.set(localizedStylableText: rightCompletion.title, state: .normal)
            rightButton.configureHighlighted(font: .latoMedium(size: 14))
            rightButton.adjustTextIntoButton()
            rightButton.accessibilityIdentifier = AccessibilityDialog.btnAccept
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
        messageLabel.font = .latoRegular(size: 14.0)
        messageLabel.set(localizedStylableText: message)
        messageLabel.set(lineSpacing: 6.0)
        
        messageFooterLabel.set(localizedStylableText: subtext)
        
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
        messageLabel.font = .latoRegular(size: 14.0)
        messageLabel.set(localizedStylableText: message)
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
        messageLabel.font = .latoSemibold(size: 16)
        messageLabel.set(localizedStylableText: message)
        messageLabel.textAlignment = .center
        
        messageFooterLabel.set(localizedStylableText: subtext)
        messageFooterLabel.textAlignment = .center
        messageFooterLabel.font = UIFont.latoLight(size: 14)
        
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
            titleLabel.set(localizedStylableText: title)
            if UIScreen.main.isIphone4or5 {
                titleLabel.font = titleLabel.font.withSize(16)
            }
        } else {
            messageLabel.textAlignment = .center
            titleView.isHidden = true
            topSeparator.isHidden = true
        }
    }
    
    private func handleTitleLeftALign(_ text: LocalizedStylableText?) {
        if let title = text, !title.text.isEmpty {
            titleLabel.set(localizedStylableText: title)
            if UIScreen.main.isIphone4or5 {
                titleLabel.font = titleLabel.font.withSize(16)
            }
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
    
    private func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = "generic_alert_title_errorData"
        self.messageLabel.accessibilityIdentifier = "signing_alert_notMatch"
    }
}
