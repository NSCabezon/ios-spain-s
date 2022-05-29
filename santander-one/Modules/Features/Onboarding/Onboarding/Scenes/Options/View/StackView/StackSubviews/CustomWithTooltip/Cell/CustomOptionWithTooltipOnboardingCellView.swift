import UIKit
import UI
import CoreFoundationLib

final class CustomOptionWithTooltipOnboardingCellView: XibView {
    @IBOutlet private weak var switchIconImageView: UIImageView!
    @IBOutlet private weak var tooltipIconImageView: UIImageView!
    @IBOutlet private weak var switchTextLabel: UILabel!
    @IBOutlet private weak var switchButton: UISwitch!
    @IBOutlet private weak var switchLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var infoButton: UIButton!
    private var tooltipText: LocalizedStylableText?
    private weak var presenter: ToolTipablePresenter?
    var viewModel: CustomOptionWithTooltipOnboardingCellViewModel?
    var switchValueDidChange: ((Bool) -> Void)?
    var isSwitchOn: Bool {
        get {
            return switchButton.isOn
        }
        set {
            switchButton.isOn = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureViews()
    }
    
    func setViewModel(_ viewModel: CustomOptionWithTooltipOnboardingCellViewModel) {
        self.switchLabel.configureText(withKey: viewModel.iconTextKey)
        self.switchIconImageView.image = Assets.image(named: viewModel.iconName)
        self.tooltipText = localized(viewModel.tooltipKey)
        self.tooltipIconImageView.image = Assets.image(named: viewModel.tooltipImage)
        self.isSwitchOn = viewModel.switchState
        self.separatorView.isHidden = !viewModel.separatorViewVisible
        self.tooltipIconImageView.isHidden = !viewModel.content.tooltipActive
        self.infoButton.isHidden = !viewModel.content.tooltipActive
        self.presenter = viewModel.presenter
        self.viewModel = viewModel
        self.setAccesibilityIdentifers(viewModel: viewModel)
    }
}

private extension CustomOptionWithTooltipOnboardingCellView {
    func configureViews() {
        self.backgroundColor = .clear
        self.separatorView.backgroundColor = .skyGray
        self.switchLabel.applyStyle(LabelStylist(textColor: .black,
                                                 font: .santander(family: .text, type: .regular, size: 17),
                                                 textAlignment: .left))
        self.switchTextLabel.applyStyle(LabelStylist(textColor: .black,
                                                     font: .santander(family: .text, type: .regular, size: 16),
                                                     textAlignment: .left))
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        self.switchValueDidChange?(sender.isOn)
    }
    
    @IBAction func tooltipAction() {
        guard let tooltipText = self.tooltipText,
              let presenter = self.presenter else {
            return
        }
        ToolTip.displayToolTip(title: nil,
                               description: nil,
                               descriptionLocalized: tooltipText,
                               sourceView: self.tooltipIconImageView,
                               sourceRect: self.tooltipIconImageView.bounds,
                               backView: presenter.toolTipBackView,
                               forcedDirection: nil)
    }
    
    func setAccesibilityIdentifers(viewModel: CustomOptionWithTooltipOnboardingCellViewModel) {
        self.switchIconImageView.accessibilityIdentifier = viewModel.iconName
        self.switchLabel.accessibilityIdentifier = viewModel.iconTextKey
        self.infoButton.accessibilityIdentifier = viewModel.tooltipKey
        self.switchButton.accessibilityIdentifier = "button_" + viewModel.iconTextKey
    }
}
