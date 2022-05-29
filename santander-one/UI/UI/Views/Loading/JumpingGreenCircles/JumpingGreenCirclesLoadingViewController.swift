import CoreFoundationLib
import UIKit

public final class JumpingGreenCirclesLoadingViewController: UIViewController {
    public struct Settings {
        let controller: UIViewController
        let completion: (() -> Void)?
        
        public init(controller: UIViewController, completion: (() -> Void)?) {
            self.controller = controller
            self.completion = completion
        }
    }
    
    var isLoading: Bool {
        return parent != nil || presentingViewController != nil
    }
    
    private lazy var loadingImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.setNewJumpingLoader()
        view.addSubview(image)
        image.heightAnchor.constraint(equalToConstant: 61).isActive = true
        image.widthAnchor.constraint(equalToConstant: 61).isActive = true
        return image
    }()
    
    private var pendingDismiss: Bool = false
    private var pendingCompletion: (() -> Void)?
    private var layoutFinished: Bool = false
    
    // MARK: - LifeCycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        loadingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySettings()
    }
    
    func applySettings() {
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingImageView.startAnimating()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutFinished = true
        if pendingDismiss {
            pendingDismiss = false
            hideLoading(completion: pendingCompletion)
        }
    }
    
    func showLoading(settings: Settings) {
        settings.controller.view.isUserInteractionEnabled = false
        addPresentController(
            controller: settings.controller,
            completion: settings.completion
        )
    }
}

private extension JumpingGreenCirclesLoadingViewController {
    func addPresentController(controller: UIViewController, completion: (() -> Void)?) {
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
        controller.present(self, animated: true, completion: {
            completion?()
            controller.view.isUserInteractionEnabled = true
        })
    }
}

// MARK: - LoadingActionProtocol
extension JumpingGreenCirclesLoadingViewController {
    func hideLoading(completion: (() -> Void)? = nil) {
        if !layoutFinished {
            pendingDismiss = true
            pendingCompletion = completion
            return
        }
        dismiss(animated: true) {
            completion?()
        }
    }
}
