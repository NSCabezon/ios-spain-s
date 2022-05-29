import UIKit
import UI
import CoreFoundationLib

public protocol HelpCenterImageLabelCallViewDelegate: AnyObject {
    func didSelectPhoneCall(_ viewModel: HelpCenterImageLabelCallViewModel)
}

public final class HelpCenterImageLabelCallView: XibView {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var phoneImageView: UIImageView!
    public weak var delegate: HelpCenterImageLabelCallViewDelegate?
    @IBOutlet weak private var containerView: UIView!
    private var viewModel: HelpCenterImageLabelCallViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        titleLabel?.textColor = .white
        titleLabel?.font = .santander(family: .text, type: .light, size: 16.0)
        phoneImageView?.image = Assets.image(named: "icnPhoneWhite")
        containerView.drawRoundedAndShadowedNew()
    }
    
    public func setViewModel(_ viewModel: HelpCenterImageLabelCallViewModel) {
        self.viewModel = viewModel
        self.titleLabel.configureText(withLocalizedString: viewModel.phone)
        setAccessibilityIdentifiers()
    }
    
    public func setConfigurationForTitleLabel(_ viewModel: HelpCenterImageLabelCallViewModel) {
        setViewModel(viewModel)
        guard let titleLabel = titleLabel else { return }
        titleLabel.numberOfLines = 0
        titleLabel.font = .santander(family: .text, type: .light, size: viewModel.titleLabelSize)
        titleLabel.configureText(withLocalizedString: viewModel.phone)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func didTapOnPhone() {
        guard let viewModel = viewModel else { return }
        self.delegate?.didSelectPhoneCall(viewModel)
    }
    
    func setAccessibilityIdentifiers(suffix: String = "") {
        if let action = viewModel?.action {
            self.accessibilityIdentifier = "helpCenter_callView_view_\(action)\(suffix)"
            titleLabel.accessibilityIdentifier = "helpCenter_callView_title_\(action)\(suffix)"
            phoneImageView.isAccessibilityElement = true
            setAccessibility { self.phoneImageView.isAccessibilityElement = false }
            phoneImageView.accessibilityIdentifier = "helpCenter_callView_image_\(action)\(suffix)"
        }
    }
}

extension HelpCenterImageLabelCallView: AccessibilityCapable { }
