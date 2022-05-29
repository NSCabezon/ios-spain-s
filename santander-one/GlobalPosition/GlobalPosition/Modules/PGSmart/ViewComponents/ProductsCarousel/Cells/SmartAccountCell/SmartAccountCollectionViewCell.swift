//
//  SmartAccountCollectionViewCell.swift
//  GlobalPosition
//
//  Created by Luis Escámez Sánchez on 19/12/2019.
//

import CoreFoundationLib
import UI

final class SmartAccountCollectionViewCell: UICollectionViewCell, GeneralPGCellProtocol {
    
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var accountAliasLabel: UILabel!
    @IBOutlet weak var securedAccountNumber: UILabel!
    
    @IBOutlet weak var availableMoneyTitleLabel: UILabel!
    @IBOutlet weak var availableMoneyDescriptionLabel: BluringLabel!
    
    @IBOutlet weak var lastMovementsStackView: UIStackView!
    @IBOutlet weak var lastMovementsNumberLabel: UILabel!
    @IBOutlet weak var movementsLabel: UILabel!
    @IBOutlet weak var piggyBankImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAppearance()
        setLabelStyle()
        setAccessibilityIdentifiers()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        availableMoneyDescriptionLabel.initializeCanvas()
        lastMovementsNumberLabel.text = ""
        movementsLabel.text = ""
        piggyBankImage?.isHidden = true
    }

    // MARK: - Accesible Methods
    func setCellInfo(_ info: Any?) {
        guard let viewModel = info as? PGGenericNotificationCellViewModel else { return }
        if let accountEntity = viewModel.elem as? AccountEntity {
            showsPiggyBankImage(accountEntity)
        }
        productTypeLabel.configureText(withKey: "pgProduct_title_account",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: UIFont.santander(family: .headline, type: .regular, size: 14.0)))
        accountAliasLabel.configureText(withLocalizedString: LocalizedStylableText(text: viewModel.title ?? "", styles: nil),
                                        andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 18.0),
                                                                                             lineHeightMultiple: 0.75))
        securedAccountNumber.text = viewModel.subtitle
        availableMoneyTitleLabel.configureText(withKey: "pgBasket_label_balance",
                                               andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14.0)))
        availableMoneyDescriptionLabel?.attributedText = viewModel.ammount
        availableMoneyDescriptionLabel?.isBlured = viewModel.discreteMode ?? false
        if let number = viewModel.notification, number != 0 {
            lastMovementsNumberLabel.text = "\(number)"
            movementsLabel.configureText(withKey: number == 1 ? "pgBasket_label_transaction_one" : "pgBasket_label_transaction_other",
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14.0),
                                                                                              alignment: .left))
        }
        self.setAccessibility {
            self.setAccessibilityLabel()
            self.disableAccessibilityElements()
        }
    }
}

private extension SmartAccountCollectionViewCell {
    func setAppearance() {
        self.contentViewCell.layer.cornerRadius = 5
        self.contentViewCell.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    func setLabelStyle() {
        productTypeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        accountAliasLabel.textColor = UIColor.white
        securedAccountNumber.textColor = UIColor.white
        securedAccountNumber.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        availableMoneyTitleLabel.textColor = UIColor.white
        availableMoneyDescriptionLabel.textColor = UIColor.white
        availableMoneyDescriptionLabel.font = UIFont.santander(family: .text, type: .bold, size: 24.0)
        availableMoneyDescriptionLabel.adjustsFontSizeToFitWidth = true
        availableMoneyDescriptionLabel.minimumScaleFactor = 2.0/3.0 // minimum size 16.0
        availableMoneyDescriptionLabel.textAlignment = .left
        availableMoneyDescriptionLabel.applyTextAlignmentToAttributedText = true
        lastMovementsNumberLabel.textColor = UIColor.white
        lastMovementsNumberLabel.font = UIFont.santander(family: .text, type: .bold, size: 20.0)
        lastMovementsNumberLabel.textAlignment = .left
        movementsLabel.textColor = UIColor.white
    }
    
    func showsPiggyBankImage(_ accountEntity: AccountEntity) {
        if accountEntity.isPiggyBankAccount {
            self.piggyBankImage?.image = Assets.image(named: "imgPiggySmart")
        }
        self.piggyBankImage?.isHidden = !accountEntity.isPiggyBankAccount
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityGlobalPosition.pgProductViewAccount
        self.productTypeLabel.accessibilityIdentifier =  AccessibilityGlobalPosition.pgProductTitleAccount
        self.accountAliasLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgProductAliasAccount
        self.securedAccountNumber.accessibilityIdentifier = AccessibilityGlobalPosition.pgProductAccountNumber
        self.movementsLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgSmartAccountLabelTransaction
        self.lastMovementsNumberLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgSmartAccountLabelTransactionValue
        self.availableMoneyTitleLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgBasketLabelBalance
        self.availableMoneyDescriptionLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgBasketLabelBalanceValue
        self.piggyBankImage?.accessibilityIdentifier = AccessibilityGlobalPosition.imgPGPiggyBank
        self.piggyBankImage.image?.accessibilityIdentifier = AccessibilityGlobalPosition.imgPGPiggyBank
    }
    
    func setAccessibilityLabel() {
        let productTypeValue = self.productTypeLabel.text ?? ""
        self.accessibilityLabel = productTypeValue
        self.updateAccessibilityValue()
        self.isAccessibilityElement = true
        self.accessibilityTraits = .button
    }
    
    func updateAccessibilityValue() {
        let productTypeValue = self.productTypeLabel.text ?? ""
        let accountAliasValue = self.accountAliasLabel.text ?? ""
        let securedAccountNumberValue = self.securedAccountNumber.text ?? ""
        let numberOfMovementsValue = (self.lastMovementsNumberLabel.text ?? "") + (self.movementsLabel.text ?? "")
        let availableMoneyTitleValue = self.availableMoneyDescriptionLabel.isBlured ? "" : self.availableMoneyTitleLabel.text ?? ""
        let availableMoneyDescriptionValue = self.availableMoneyDescriptionLabel.isBlured ? "" : self.availableMoneyDescriptionLabel.attributedText?.string ?? ""
        self.accessibilityValue = productTypeValue + "." +
            accountAliasValue + "." +
            securedAccountNumberValue + ".\n" +
            numberOfMovementsValue + "." +
            availableMoneyTitleValue + "." +
            availableMoneyDescriptionValue
    }
    
    func disableAccessibilityElements() {
        self.productTypeLabel.isAccessibilityElement = false
        self.accountAliasLabel.isAccessibilityElement = false
        self.securedAccountNumber.isAccessibilityElement = false
        self.availableMoneyTitleLabel.isAccessibilityElement = false
        self.availableMoneyDescriptionLabel.isAccessibilityElement = false
    }
}

extension SmartAccountCollectionViewCell: AccessibilityCapable { }
