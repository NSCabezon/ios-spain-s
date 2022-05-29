//
//  LisboaCollectionSelectCell.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 26/05/2020.
//

import CoreFoundationLib

class LisboaCollectionSelectCell: UICollectionViewCell {
    static public let reuseID = "LisboaCollectionSelectCell"
    @IBOutlet weak private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        self.drawBorder(color: .mediumSkyGray)
        layer.masksToBounds = false
        self.drawShadow(offset: (x: 0, y: 2), opacity: 1.0, color: .lightSanGray, radius: 0.0)
        let turquoiseView = UIView(frame: bounds)
        turquoiseView.drawBorder(color: .darkTorquoise)
        turquoiseView.backgroundColor = .darkTorquoise
        self.selectedBackgroundView = turquoiseView
    }

    public func configureCellWithTitle(_ title: String, subtitle: String, showSubtitle: Bool = true) {
        if showSubtitle {
            let titlePlaceHolder = StringPlaceholder(.value, title)
            let subtitlePlaceHolder = StringPlaceholder(.value, subtitle)
            let localizedText = localized("sendMoney_label_valueCurrency", [titlePlaceHolder, subtitlePlaceHolder])
            self.titleLabel.configureText(withLocalizedString: localizedText, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
            self.titleLabel.accessibilityIdentifier = AccessibilityUsualTransfer.currencyLabel.rawValue
        } else {
            let titlePlaceHolder = StringPlaceholder(.value, title)
            let localizedText = localized("sendMoney_label_valueCountry", [titlePlaceHolder])
            self.titleLabel.configureText(withLocalizedString: localizedText, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
            self.titleLabel.accessibilityIdentifier = AccessibilityUsualTransfer.countryLabel.rawValue
        }
    }
    
    public func selectedState() {
        self.isSelected = true
        titleLabel.textColor = .white
        layer.shadowColor = UIColor.clear.cgColor
        layer.borderColor = UIColor.darkTorquoise.cgColor
    }
    
    public func unselectedState() {
        self.isSelected = false
        titleLabel.textColor = .black
        layer.shadowColor = UIColor.lightSanGray.cgColor
        layer.borderColor = UIColor.mediumSkyGray.cgColor

    }
}

private extension LisboaCollectionSelectCell {
    func setupView() {
        self.backgroundColor = .white
        titleLabel.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
    }
}
