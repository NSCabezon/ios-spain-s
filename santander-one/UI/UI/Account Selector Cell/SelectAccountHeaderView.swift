import UIKit
import CoreFoundationLib

public class SelectAccountHeaderView: UIView {
    
    private var view: UIView?
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var accountLabel: UILabel!
    @IBOutlet private weak var accountAvailableAmountLabel: UILabel!
    @IBOutlet private weak var changeAccountButton: UIButton!
    @IBOutlet private weak var verticalSeparator: UIView!
    @IBOutlet private weak var editImageView: UIImageView!
    @IBOutlet private weak var changeLabel: UILabel!
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private weak var buttonContainerStackView: UIStackView!
    
    private var viewModel: SelectAccountHeaderViewModel?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setup(with viewModel: SelectAccountHeaderViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.title
        self.accountLabel.text = viewModel.alias
        self.accountAvailableAmountLabel.text = viewModel.currentBalanceAmount?.getStringValue() ?? ""
        // Hides the button when action is nil
        self.changeAccountButton.isHidden = viewModel.action == nil
        self.buttonContainerStackView.isHidden = viewModel.action == nil
    }
    
    private func setupView() {
        self.xibSetup()
        guard let viewFromNib = self.view else { return }
        viewFromNib.backgroundColor = .skyGray
        self.titleLabel.setSantanderTextFont(type: .bold, size: 12, color: .grafite)
        self.accountLabel.setSantanderTextFont(size: 15, color: .lisboaGray)
        self.accountAvailableAmountLabel.setSantanderTextFont(size: 15, color: .grafite)
        self.verticalSeparator.backgroundColor = .mediumSkyGray
        self.bottomSeparator.backgroundColor = .mediumSkyGray
        self.editImageView.image = Assets.image(named: "icnEdit")
        self.changeLabel.setSantanderTextFont(size: 10, color: .darkTorquoise)
        self.changeLabel.configureText(withKey: "generic_button_changeAccount", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        self.changeLabel.textAlignment = .center
        self.changeAccountButton.backgroundColor = .clear
        self.changeAccountButton.addTarget(self, action: #selector(changeAccountButtonSelected), for: .touchUpInside)
        self.setAccessibilityIdentifiers()
    }
    
    private func xibSetup() {
        let viewFromNib = self.loadViewFromNib()
        self.view = viewFromNib
        self.addSubview(viewFromNib)
        viewFromNib.fullFit()
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    @objc private func changeAccountButtonSelected() {
        self.viewModel?.action?()
    }
    
    private func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = self.viewModel?.accessibilityIdTitle
        self.accountLabel.accessibilityIdentifier = AccessibilityTransfers.accountNumberLabel
        self.accountAvailableAmountLabel.accessibilityIdentifier = AccessibilityTransfers.availableAmountTitleLabel
        self.editImageView.accessibilityIdentifier = AccessibilityTransfers.icnEdit
        self.changeLabel.accessibilityIdentifier = AccessibilityTransfers.genericButtonChangeAccount
        self.changeAccountButton.accessibilityIdentifier = AccessibilityTransfers.btnChangeAccount.rawValue
    }
}
