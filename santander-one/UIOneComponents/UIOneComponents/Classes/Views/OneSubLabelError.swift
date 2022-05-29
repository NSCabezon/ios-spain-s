import UIKit
import UI
import CoreFoundationLib

public class OneSubLabelError: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var errorImageView: UIImageView!
    @IBOutlet private weak var errorView: UIView! {
        didSet {
            self.errorView.isHidden = true
        }
    }
    @IBOutlet private weak var errorLabel: UILabel!
    public weak var errorProtocol: OneComponentStatusProtocol?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureError()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureError()
    }

    public func setContainer(_ view: UIView) {
        self.containerView.addSubview(view)
        view.fullFit()
        self.setAccessibilityIdentifiers()
    }
    
    public func hideError() {
        self.errorView.isHidden = true
        self.errorProtocol?.hideError()
    }

    public func showError(_ error: String?) {
        self.errorView.isHidden = (error == nil) ? true : false
        self.errorLabel.text = localized(error ?? "")
        self.errorProtocol?.showError(error)
    }
}

private extension OneSubLabelError {
    func configureError() {
        self.errorLabel.numberOfLines = 1
        self.errorLabel.adjustsFontSizeToFitWidth = true
        self.errorLabel.minimumScaleFactor = 0.5
        self.errorLabel.font = .typography(fontName: .oneB300Regular)
        self.errorLabel.textColor = .oneSantanderRed
        self.errorImageView.image = Assets.image(named: "icnAlert")
    }
    
    func setAccessibilityIdentifiers() {
        self.containerView.accessibilityIdentifier = AccessibilityOneComponents.oneErrorContainerView
        self.errorImageView.accessibilityIdentifier = AccessibilityOneComponents.oneIcnAlert
        self.errorLabel.accessibilityIdentifier = AccessibilityOneComponents.oneErrorLabel
    }
}

