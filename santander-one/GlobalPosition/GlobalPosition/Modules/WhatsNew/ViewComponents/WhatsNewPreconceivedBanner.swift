//
//  WhatsNewPreconceivedBanner.swift
//  GlobalPosition
//
//  Created by Laura González on 20/07/2020.
//

import UI
import CoreFoundationLib

final class WhatsNewPreconceivedBanner: DesignableView {
    
    @IBOutlet private weak var container: UIView!
    @IBOutlet private weak var payTaxImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    private var endDate: String?
    public var viewModel: OfferBannerViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setLabelsInfo(viewModel: PreconceivedBannerViewModel?) {
        guard let viewModel = viewModel else { return }
        titleLabel.configureText(withLocalizedString: localized("whastNew_title_preconceived", [StringPlaceholder(.value, viewModel.amountEntity.getStringValue(withDecimal: 0))]),
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16)))
        if let date = self.endDate {
            textLabel.configureText(withLocalizedString: localized("whastNew_text_preconceived", [StringPlaceholder(.date, date), StringPlaceholder(.value, viewModel.amountEntity.getStringValue(withDecimal: 0))]),
                                    andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14)))
        } else {
            textLabel.configureText(withLocalizedString: localized("whastNew_text_preconceivedNoDate", [StringPlaceholder(.value, viewModel.amountEntity.getStringValue(withDecimal: 0))]),
                                    andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14)))
        }
    }

    func setDate(_ date: String) {
        self.endDate = date
    }
}

private extension WhatsNewPreconceivedBanner {
    func setupView() {
        self.backgroundColor = .clear
        self.setupLabels()
        self.setImage()
        self.setAccessibilityIdentifiers()
        self.backgroundColor = .clear
        self.container.backgroundColor = .white
        self.container.isUserInteractionEnabled = true
        let shadowConfiguration = ShadowConfiguration(color: UIColor.darkTorquoise.withAlphaComponent(0.33), opacity: 0.7, radius: 3.0, withOffset: 1, heightOffset: 2)
        self.container.drawRoundedBorderAndShadow(with: shadowConfiguration, cornerRadius: 6.0, borderColor: .lightSkyBlue, borderWith: 1.0)
    }
    
    func setupLabels() {
        titleLabel.textColor = .darkTorquoise
        textLabel.textColor = .lisboaGray
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 2
    }
    
    func setImage() {
        payTaxImage.image = Assets.image(named: "icnPayTax1Green")
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = "whastNew_title_preconceived"
        self.textLabel.accessibilityIdentifier = "whastNew_text_preconceived"
        self.payTaxImage.accessibilityIdentifier = "icnPayTax1Green"
    }
}
