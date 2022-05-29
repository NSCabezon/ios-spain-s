import UIKit
import CoreFoundationLib

public protocol LoadingActionProtocol: LoadingProtocol {
    func hideLoading(completion: (() -> Void)?)
}

public protocol LoadingProtocol: AnyObject {
    func setPlaceholder(placeholder: [Placeholder], topInset: CGFloat, background: UIColor?)
    func setText(text: LoadingText)
    var isLoading: Bool { get }
}

public protocol ShakeDelegate: AnyObject {
    func shakeWasOccurred ()
}

public enum LoadingViewTypeOnViewPosition {
    case top
    case center
    case betweenTopAndCenter
}

public enum LoadingViewType {
    case onDrawer(completion: (() -> Void)?, shakeDelegate: ShakeDelegate?)
    case onScreen(controller: UIViewController, completion: (() -> Void)?)
    case onScreenCentered(controller: UIViewController, completion: (() -> Void)?)
    case onView(view: UIView, frame: CGRect?, position: LoadingViewTypeOnViewPosition, controller: UIViewController)
}

// MARK: - Type of animation loading
public enum LoadingImageType {
    case points, spin, jumps
}

public enum LoadingStyle {
    case global, onView, bold
}

public enum LoadingGradientViewStyle {
    case global, topToBottom, solid
}

public enum LoadingSpacingType {
    case zero, basic
}

final class LoadingViewController: UIViewController {
    
    private struct Settings {
        let loadingText: LoadingText?
        let placeholders: [Placeholder]?
        let topInset: CGFloat
        let background: UIColor?
        let loadingImageType: LoadingImageType?
        let style: LoadingStyle?
        let gradientViewStyle: LoadingGradientViewStyle?
        let spacingType: LoadingSpacingType
        let loaderAccessibilityIdentifier: String?
        let titleAccessibilityIdentifier: String?
        let subtitleAccessibilityIdentifier: String?
    }

    var isLoading: Bool {
        return parent != nil || presentingViewController != nil
    }
    
    enum LoadingType {
        case full
        case fullCentered
        case inViewTop
        case inViewCenter
        case inViewBetweenTopAndCenter
        case none
    }
    
    @IBOutlet private weak var containerTopDistance: NSLayoutConstraint!
    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var loadingContainer: UIView!
    @IBOutlet private weak var loadingView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var secureConnectionLabel: UILabel!
    
    private weak var shakeDelegate: ShakeDelegate?
    private var type: LoadingType = .none
    private var settings: Settings?
    private var isShowingOnViewController: Bool {
        return parent != nil
    }
    private var pendingDismiss: Bool = false
    private var pendingCompletion: (() -> Void)?
    private var layoutFinished: Bool = false
    private var placeholderView: PlaceholderView?
    private let gradient = CAGradientLayer()
    private let indexLabel = "[index]"
    
    // MARK: - LifeCycle
    
    init() {
        super.init(nibName: "LoadingViewController", bundle: .module)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTopDistanceConstraint()
        setContainerStackViewSpacing()
        setAccessibilityIdentifiers()
        gradient.frame = gradientView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySettings(imageType: settings?.loadingImageType ?? .spin)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutFinished = true
        if pendingDismiss {
            pendingDismiss = false
            hideLoading(completion: pendingCompletion)
        }
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake, let shakeDelegate = shakeDelegate {
            shakeDelegate.shakeWasOccurred()
        }
    }
    
    func showLoading(info: LoadingInfo) {
        guard
            let presentationType = setPresentationType(with: info)
        else { return }
        settings = Settings(
            loadingText: info.loadingText,
            placeholders: info.placeholders,
            topInset: CGFloat(info.topInset ?? 0.0),
            background: info.background,
            loadingImageType: info.loadingImageType,
            style: info.style,
            gradientViewStyle: info.gradientViewStyle,
            spacingType: info.spacingType,
            loaderAccessibilityIdentifier: info.loaderAccessibilityIdentifier,
            titleAccessibilityIdentifier: info.titleAccessibilityIdentifier,
            subtitleAccessibilityIdentifier: info.subtitleAccessibilityIdentifier
        )
        switch presentationType {
        case .over(let controller, let completion):
            controller.view.isUserInteractionEnabled = false
            addPresentController(
                controller: controller,
                completion: completion
            )
        case .inside(let controller, let hostView, let frame):
            controller.view.isUserInteractionEnabled = false
            addInternalView(
                hostView: hostView,
                frame: frame,
                controller: controller
            )
        }
    }
}

private extension LoadingViewController {
    private enum PresentationType {
        case over(viewController: UIViewController, completion: (() -> Void)?)
        case inside(viewController: UIViewController, hostView: UIView, frame: CGRect?)
    }
    
    private func setPresentationType(with info: LoadingInfo) -> PresentationType? {
        switch info.type {
        case .onDrawer(let completion, let shakeDelegate):
            guard let drawerController = UIApplication.shared.keyWindow?.rootViewController else {
                return nil
            }
            self.shakeDelegate = shakeDelegate
            if let bounds = UIApplication.shared.keyWindow?.bounds {
                view.frame = bounds
            }
            type = .full
            return .over(viewController: drawerController, completion: completion)
        case .onScreen(let controller, let completion):
            guard !isShowingOnViewController else {
                return nil
            }
            shakeDelegate = nil
            type = .full
            return .over(viewController: controller, completion: completion)
        case .onScreenCentered(let controller, let completion):
            guard !isShowingOnViewController else {
                return nil
            }
            shakeDelegate = nil
            type = .fullCentered
            return .over(viewController: controller, completion: completion)
        case .onView(let view, let frame, let position, let controller):
            shakeDelegate = nil
            switch position {
            case .top:
                type = .inViewTop
            case .center:
                type = .inViewCenter
            case .betweenTopAndCenter:
                type = .inViewBetweenTopAndCenter
            }
            return .inside(viewController: controller, hostView: view, frame: frame)
        }
    }
    
    func setTopDistanceConstraint() {
        switch type {
        case .inViewTop:
            containerTopDistance.constant = 0.0
        case .full, .inViewCenter:
            containerTopDistance.constant = view.frame.height * 0.22
        case .fullCentered:
            containerTopDistance.constant = (view.frame.height - containerStackView.frame.height) / 2
        case .inViewBetweenTopAndCenter:
            containerTopDistance.constant = 117
        default:
            break
        }
    }
    
    func setContainerStackViewSpacing() {
        switch settings?.spacingType {
        case .basic:
            containerStackView.spacing = 8.0
        default: return
        }
    }

    func setup() {
        self.setGradientView()
        self.setLabels()
    }
    
    func setGradientView() {
        switch settings?.gradientViewStyle {
        case .global:
            self.setDefaultGradientView()
        case .topToBottom:
            gradientView.backgroundColor = settings?.background ?? .white
            guard settings?.background != .clear else { return }
            gradientView.alpha = 1
            gradient.frame = gradientView.bounds
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
            gradient.colors = [
                UIColor(white: 255.0 / 255.0, alpha: 1.0).cgColor,
                UIColor(red: 244.0 / 255.0, green: 246.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0).cgColor
            ]
            if gradient.superlayer == nil {
                gradientView.layer.insertSublayer(gradient, at: 0)
            }
        case .solid:
            gradientView.backgroundColor = settings?.background ?? .clear
            gradientView.alpha = 1
        case .none:
            self.setDefaultGradientView()
        }
    }
    
    func setDefaultGradientView() {
        gradientView.backgroundColor = settings?.background ?? .white
        guard settings?.background != .clear else { return }
        gradientView.alpha = 0.85
        gradient.frame = gradientView.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.colors = [UIColor.white.cgColor, UIColor(white: 241.0 / 255.0, alpha: 1.0).cgColor]
        if gradient.superlayer == nil {
            gradientView.layer.insertSublayer(gradient, at: 0)
        }
    }
    
    func setLabels() {
        secureConnectionLabel.configureText(withKey: "generic_label_secureConnection")
        switch settings?.style {
        case .global:
            self.setDefaultLabelsFont()
        case .onView:
            titleLabel.font = .santander(family: .text, type: .regular, size: 20.0)
            subtitleLabel.font = .santander(family: .text, type: .regular, size: 14.0)
            secureConnectionLabel.font = .santander(family: .headline, type: .regular, size: 13.0)
            titleLabel.textColor = .lisboaGray
            subtitleLabel.textColor = .grafite
            secureConnectionLabel.isHidden = true
        case .bold:
            titleLabel.font = .santander(family: .headline, type: .bold, size: 18.0)
            subtitleLabel.font = .santander(family: .micro, type: .regular, size: 16.0)
            secureConnectionLabel.font = .santander(family: .headline, type: .regular, size: 13.0)
            titleLabel.textColor = .lisboaGray
            subtitleLabel.textColor = .lisboaGray
            secureConnectionLabel.isHidden = true
        case .none:
            self.setDefaultLabelsFont()
        }
    }
    
    func setDefaultLabelsFont() {
        titleLabel.font = .santander(family: .text, type: .bold, size: 24.0)
        subtitleLabel.font = .santander(family: .headline, type: .regular, size: 16)
        secureConnectionLabel.font = .santander(family: .headline, type: .regular, size: 14.0)
        titleLabel.textColor = .lisboaGray
        subtitleLabel.textColor = .grafite
        secureConnectionLabel.textColor = .lisboaGray
    }
    
    func applySettings(imageType: LoadingImageType) {
        guard let settings = settings else {
            return
        }
        let loadingViewWidth: NSLayoutConstraint
        switch imageType {
        case .spin:
            loadingViewWidth = loadingView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35)
            loadingView.setPrimaryLoader(accessibilityIdentifier: settings.loaderAccessibilityIdentifier)
        case .points:
            let multiplier: CGFloat = settings.style == .onView ? 0.3 : 0.12
            loadingViewWidth = loadingView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier)
            loadingView.setPointsLoader(accessibilityIdentifier: settings.loaderAccessibilityIdentifier)
        case .jumps:
            let multiplier: CGFloat = settings.style == .onView ? 0.3 : 0.12
            loadingViewWidth = loadingView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier)
            loadingView.setNewJumpingLoader(accessibilityIdentifier: settings.loaderAccessibilityIdentifier)
        }
        loadingViewWidth.priority = .required
        loadingViewWidth.isActive = true
        
        loadingView.startAnimating()
        
        if let text = settings.loadingText {
            setText(text: text)
        }
        if let placeholders = settings.placeholders {
            setUpPlaceholder(placeholders, settings.topInset, settings.background)
        }
    }
    
    func addInternalView(hostView: UIView, frame: CGRect?, controller: UIViewController) {
        view.frame = frame ?? hostView.bounds
        hostView.addSubview(view)
        controller.addChild(self)
        didMove(toParent: controller)
        controller.view.isUserInteractionEnabled = true
    }
    
    func addPresentController(controller: UIViewController, completion: (() -> Void)?) {
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
        controller.present(self, animated: true, completion: {
            completion?()
            controller.view.isUserInteractionEnabled = true
        })
    }
    
    func setUpPlaceholder(_ placeholders: [Placeholder], _ topInset: CGFloat, _ background: UIColor? = nil) {
        if let placeholderView = self.placeholderView {
            placeholderView.setPlaceholder(placeholderImages: placeholders, topInset: topInset)
        } else {
            self.placeholderView = PlaceholderView(size: CGSize(width: self.view.frame.size.width, height: view.frame.size.height), placeholderImages: placeholders, topInset: topInset)
        }
        if let placeholderView = self.placeholderView {
            var frame = placeholderView.frame
            frame.origin.y = topInset
            let placeholderContainer = UIView(frame: frame)
            
            if let color = background {
                placeholderContainer.backgroundColor = color
            }
            placeholderContainer.addSubview(placeholderView)
            self.view.insertSubview(placeholderContainer, at: 0)
        }
        placeholderView?.translatesAutoresizingMaskIntoConstraints = false
        gradientView.alpha = 0.7
    }
    
    func setAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = settings?.titleAccessibilityIdentifier
        subtitleLabel.accessibilityIdentifier = settings?.subtitleAccessibilityIdentifier
    }
}

// MARK: - LoadingActionProtocol

extension LoadingViewController: LoadingActionProtocol {
    func hideLoading(completion: (() -> Void)? = nil) {
        if !layoutFinished {
            pendingDismiss = true
            pendingCompletion = completion
            return
        }
        switch type {
        case .full, .fullCentered:
            dismiss(animated: true) {
                completion?()
            }
        case .inViewTop, .inViewCenter, .inViewBetweenTopAndCenter:
            willMove(toParent: nil)
            self.view.removeFromSuperview()
            removeFromParent()
            completion?()
        default:
            break
        }
        type = .none
    }
}

// MARK: - LoadingProtocol

extension LoadingViewController: LoadingProtocol {
    
    func setText(text: LoadingText) {
        guard titleLabel != nil, subtitleLabel != nil else {
            return
        }
        titleLabel.configureText(withLocalizedString: text.title)
        subtitleLabel.configureText(withLocalizedString: text.subtitle)
    }
    
    func setPlaceholder(placeholder: [Placeholder], topInset: CGFloat, background: UIColor? = nil) {
        setUpPlaceholder(placeholder, topInset, background)
    }
}
