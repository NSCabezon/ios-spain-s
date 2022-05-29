import CoreFoundationLib
import UIKit
import UI

struct AviosDetailComponentViewModel {
    let iberiaCode: String
    let lastLiquidationPoints: String
    let totalPoints: String
}

final class AviosDetailComponentView: DesignableView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var aviosLogoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iberiaCodeLabel: UILabel!
    @IBOutlet private weak var informationLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
        
    init(viewModel: AviosDetailComponentViewModel) {
        super.init(frame: .zero)
        setModel(viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func commonInit() {
        super.commonInit()
        self.backgroundColor = .clear
        self.accessibilityIdentifier = AccessibilityAvios.aviosViewConsultation
        self.contentView?.backgroundColor = .clear
        self.containerView.backgroundColor = .white
        self.aviosLogoImageView.image = Assets.image(named: "icnOneIberia")
        self.aviosLogoImageView.accessibilityIdentifier = "icnOneIberia"
        self.titleLabel.font = .santander(family: .headline, type: .regular, size: 16)
        self.titleLabel.textColor = .black
        self.titleLabel.configureText(withKey: "pg_title_avios")
        self.titleLabel.accessibilityIdentifier = "pg_title_avios"
        self.iberiaCodeLabel.font = .santander(family: .text, type: .regular, size: 15)
        self.iberiaCodeLabel.textColor = .lisboaGray
        self.informationLabel.font = .santander(family: .text, type: .regular, size: 15)
        self.informationLabel.textColor = .lisboaGray
        self.informationLabel.configureText(
            withKey: "avios_text_knowAviosObtained",
            andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.7)
        )
        self.informationLabel.accessibilityIdentifier = "avios_text_knowAviosObtained"
        self.containerView.drawBorder(cornerRadius: 6,
                                      color: .mediumSkyGray,
                                      width: 1)
    }
}

private extension AviosDetailComponentView {
    func setModel(_ viewModel: AviosDetailComponentViewModel) {
        iberiaCodeLabel.configureText(
            withLocalizedString: localized(
                "avios_label_number",
                [
                    StringPlaceholder(
                        .number,
                        viewModel.iberiaCode
                    )
                ]
            )
        )
        iberiaCodeLabel.accessibilityIdentifier = "aviosDetailLabelIberiaPlusCode"
        let leftView = AviosPointsView(viewModel:
            AviosPointsViewModel(
                descriptionTitleKey: "avios_label_lastSettlement",
                points: viewModel.lastLiquidationPoints,
                pointsAccessibilityIdentifier: "aviosDetailLabelLastLiquidationPoints",
                background: .bostonRedLight
            )
        )
        self.stackView.addArrangedSubview(leftView)
        let rightView = AviosPointsView(viewModel:
            AviosPointsViewModel(
                descriptionTitleKey: "avios_label_total",
                points: viewModel.totalPoints,
                pointsAccessibilityIdentifier: "aviosDetailLabelTotalPoints",
                background: .darkTorquoise
            )
        )
        self.stackView.addArrangedSubview(rightView)
    }
}
