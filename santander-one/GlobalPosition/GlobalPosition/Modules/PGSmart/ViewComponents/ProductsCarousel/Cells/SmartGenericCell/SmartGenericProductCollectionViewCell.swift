//
//  SmartGenericProductCollectionViewCell.swift
//  GlobalPosition
//
//  Created by Luis Escámez Sánchez on 20/12/2019.
//
import UI
import CoreFoundationLib

final class SmartGenericProductCollectionViewCell: UICollectionViewCell, GeneralPGCellProtocol {

    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var productAliasLabel: UILabel!
    @IBOutlet weak var securedProductNumber: UILabel!
    
    @IBOutlet weak var availableMoneyTitleLabel: UILabel!
    @IBOutlet weak var availableMoneyDescriptionLabel: BluringLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
        self.setLabelStyle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        availableMoneyDescriptionLabel.initializeCanvas()
        
        availableMoneyTitleLabel.text = ""
        availableMoneyDescriptionLabel.text = ""
    }
       
    // MARK: - Accesible Methods
     func setCellInfo(_ info: Any?) {
        guard let viewModel = info as? PGSmartGenericCellViewModel else { return }
        productTypeLabel.configureText(withLocalizedString: localized(viewModel.producName ?? ""),
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 14.0)))
        productAliasLabel.configureText(withLocalizedString: LocalizedStylableText(text: viewModel.title ?? "", styles: nil),
                                        andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 18.0),
                                                                                             lineHeightMultiple: 0.75))
        securedProductNumber.configureText(withLocalizedString: LocalizedStylableText(text: viewModel.subtitle ?? "", styles: nil),
                                           andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14.0)))
        securedProductNumber.numberOfLines = 2
        
        if let basketName = viewModel.basketName, let ammount = viewModel.ammount {
            availableMoneyTitleLabel.text = basketName
            availableMoneyDescriptionLabel?.attributedText = ammount
            availableMoneyDescriptionLabel?.isBlured = viewModel.discreteMode ?? false
        }
         self.setAccessibility {
             self.setAccessibilityLabel()
             self.disableAccessibilityElements()
         }
         self.setAccessibilityIdentifiers(info: viewModel)
    }
}
    // MARK: - Private Methods
private extension SmartGenericProductCollectionViewCell {
    func setAppearance() {
        self.contentViewCell.layer.cornerRadius = 5
        self.contentViewCell.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    func setLabelStyle() {
        productTypeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        productAliasLabel.textColor = UIColor.white
        securedProductNumber.textColor = UIColor.white
        availableMoneyTitleLabel.textColor = UIColor.white
        availableMoneyTitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        availableMoneyDescriptionLabel.textColor = UIColor.white
        availableMoneyDescriptionLabel.font = UIFont.santander(family: .text, type: .bold, size: 24.0)
        availableMoneyDescriptionLabel.adjustsFontSizeToFitWidth = true
        availableMoneyDescriptionLabel.textAlignment = .left
        availableMoneyDescriptionLabel.applyTextAlignmentToAttributedText = true
    }
    
    func setAccessibilityLabel() {
        let productTypeValue = self.productTypeLabel.text ?? ""
        self.accessibilityLabel = productTypeValue
        self.accessibilityTraits = .button
        self.updateAccessibilityValue()
        self.isAccessibilityElement = true
    }
    
    func updateAccessibilityValue() {
        let productTypeValue = self.productTypeLabel.text ?? ""
        let productAliasValue = self.productAliasLabel.text ?? ""
        let securedProductNumberValue = self.securedProductNumber.text ?? ""
        let availableMoneyTitleValue = self.availableMoneyDescriptionLabel.isBlured ? "" : self.availableMoneyTitleLabel.text ?? ""
        let availableMoneyDescriptionValue = self.availableMoneyDescriptionLabel.isBlured ? "" : self.availableMoneyDescriptionLabel.attributedText?.string ?? ""
        self.accessibilityValue = "\(productTypeValue) . \(productAliasValue) . \(securedProductNumberValue) . \(availableMoneyTitleValue) . \(availableMoneyDescriptionValue)"
    }
    
    func disableAccessibilityElements() {
        self.productTypeLabel.isAccessibilityElement = false
        self.securedProductNumber.isAccessibilityElement = false
        self.availableMoneyTitleLabel.isAccessibilityElement = false
        self.availableMoneyDescriptionLabel.isAccessibilityElement = false
    }
    
    func setAccessibilityIdentifiers(info: PGSmartGenericCellViewModel) {
        if let elem = info.elem as? GlobalPositionProduct {
            self.accessibilityIdentifier = "pgSmart_\(elem.productId)_view"
            self.productTypeLabel.accessibilityIdentifier = "pgSmart_\(elem.productId)_title"
            self.productAliasLabel.accessibilityIdentifier = "pgSmart_\(elem.productId)_alias"
            self.securedProductNumber.accessibilityIdentifier = "pgSmart_\(elem.productId)_number"
            self.availableMoneyTitleLabel.accessibilityIdentifier = "pgSmart_\(elem.productId)_balanceDots"
            self.availableMoneyDescriptionLabel.accessibilityIdentifier = "pgSmart_\(elem.productId)_BalanceDotsValue"
        }
    }
}

extension SmartGenericProductCollectionViewCell: AccessibilityCapable { }
