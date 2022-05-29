import UIKit
import UI
import CoreFoundationLib

public enum BottomSheetComponent {
    case close, pan, all, unowned
}

public struct BottomSheet {
    public init() {}
    
    public func show(in viewController: UIViewController,
              type: SizablePresentationType = .half(),
              component: BottomSheetComponent = .all,
              view: UIView,
              imageAccessibilityLabel: String? = nil,
              btnCloseAccessibilityLabel: String? = nil,
              delegate: BottomSheetViewProtocol? = nil) {
        let transicionDelegate = SizablePresentationManager()
        let tapOutsideDismiss = component == .all || component == .close
        let newType = self.customHeight(of: view, in: viewController, with: type, tapOutsideDismiss: tapOutsideDismiss)
        transicionDelegate.setPresentation(newType)
        let bottomSheetViewController = BottomSheetViewController(nibName: "BottomSheetViewController", bundle: .module)
        if let delegate = delegate {
            bottomSheetViewController.delegate = delegate
        }
        bottomSheetViewController.transitioningDelegate = transicionDelegate
        bottomSheetViewController.modalPresentationStyle = .custom
        bottomSheetViewController.modalTransitionStyle = .coverVertical
        bottomSheetViewController.delegate = delegate
        bottomSheetViewController.setBottomSheet(component: component, view: view)
        bottomSheetViewController.setCustomAccessibility(imageAccessibilityLabel: imageAccessibilityLabel,
                                                        btnCloseAccessibilityLabel: btnCloseAccessibilityLabel)
        viewController.present(bottomSheetViewController, animated: true)
    }
    
    public func close(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

public protocol BottomSheetViewProtocol: AnyObject {
    func didShow()
    func didTapCloseButton()
}

public extension BottomSheetViewProtocol {
    func didShow() { }
}

private extension BottomSheet {
    func customHeight(of view: UIView, in container: UIViewController, with type: SizablePresentationType, tapOutsideDismiss: Bool) -> SizablePresentationType {
        if case let .custom(height, _, _, _) = type, height == nil {
            let targetSize = CGSize(width: container.view.bounds.width, height: UIView.layoutFittingExpandedSize.height)
            let viewSize = view.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: UILayoutPriority.required,
                verticalFittingPriority: UILayoutPriority.fittingSizeLevel
            )
            return .custom(height: viewSize.height,
                           isPan: type.isPan(),
                           bottomVisible: type.isBottomVisible(),
                           tapOutsideDismiss: tapOutsideDismiss)
        }
        return SizablePresentationType(type: type, tapOutsideDismiss: tapOutsideDismiss)
    }
}

final class BottomSheetViewController: UIViewController {
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak private var lineImageView: UIImageView!
    @IBOutlet weak private var topBarView: UIView!
    private var customView: UIView?
    private var component: BottomSheetComponent?
    private var imageAccessibilityLabel: String?
    private var closeButtonAccessibilityLabel: String?
    weak var delegate: BottomSheetViewProtocol?
    
    override func viewDidLoad() {
        guard let customView = customView,
              let component = self.component else { return }
        self.closeButton.setImage(Assets.image(named: "icnCloseModal")?.withRenderingMode(.alwaysOriginal), for: .normal)
        switch component {
        case .all:
            self.lineImageView.image = Assets.image(named: "line")
        case .close:
            self.lineImageView.isHidden = true
        case .pan:
            self.closeButton.isHidden = true
            self.lineImageView.image = Assets.image(named: "line")
        case .unowned:
            self.closeButton.isHidden = true
            self.lineImageView.isHidden = true
        }
        self.addView(customView)
        self.setAccessibilityIdentifiers()
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        self.delegate?.didShow()
    }
    
    func setBottomSheet(component: BottomSheetComponent, view: UIView) {
        self.customView = view
        self.component = component
    }
    
    func setAccessibilityInfo() {
        self.closeButton.accessibilityLabel = self.closeButtonAccessibilityLabel ?? localized("voiceover_close")
        if let _ = self.customView?.subviews[0] as? UIImageView {
            self.customView?.isAccessibilityElement = true
            self.customView?.accessibilityLabel = self.imageAccessibilityLabel
            UIAccessibility.post(notification: .layoutChanged, argument: self.customView)
        } else {
            guard let view = customView, !view.subviews.isEmpty else {
                UIAccessibility.post(notification: .layoutChanged, argument: self.closeButton)
                return
            }
            UIAccessibility.post(notification: .layoutChanged, argument: self.customView)
        }
    }
    
    func setCustomAccessibility(imageAccessibilityLabel: String?, btnCloseAccessibilityLabel: String?) {
        self.imageAccessibilityLabel = imageAccessibilityLabel
        self.closeButtonAccessibilityLabel = btnCloseAccessibilityLabel
    }
}

private extension BottomSheetViewController {
    func addView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        view.topAnchor.constraint(equalTo: topBarView.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            view.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor).isActive = true
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.didTapCloseButton()
        }
    }
    
    func setAccessibilityIdentifiers() {
        self.lineImageView.accessibilityIdentifier = AccessibilityOneComponents.oneBottomSheetLine
        self.closeButton.accessibilityIdentifier = AccessibilityOneComponents.oneBottomSheetClose
    }
}

extension BottomSheetViewController: AccessibilityCapable {}
