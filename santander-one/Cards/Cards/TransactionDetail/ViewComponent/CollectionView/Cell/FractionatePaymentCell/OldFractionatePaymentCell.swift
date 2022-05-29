//
//  FractionatePaymentCell.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 30/04/2020.
//

import UI
import CoreFoundationLib

class OldFractionatePaymentCell: UICollectionViewCell {
    static let cellIdentifier = "fractionate_pay_cell"
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var noInterestLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        noInterestLabel.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        self.drawBorder(cornerRadius: 5.0, color: .mediumSkyGray, width: 1.2)
        layer.masksToBounds = false
        self.drawShadow(offset: (x: 0, y: 2), opacity: 0.3, color: .atmsShadowGray, radius: 3.0)
    }

    public func configureCellWithTitle(_ title: LocalizedStylableText, subtitle: LocalizedStylableText, accessibilityId: String, noInterestHidden: Bool) {
        self.titleLabel.configureText(withLocalizedString: title)
        self.subtitleLabel.configureText(withLocalizedString: subtitle)
        self.accessibilityIdentifier = accessibilityId
        self.noInterestLabel.isHidden = !noInterestHidden
    }
}

private extension OldFractionatePaymentCell {
    func setupView() {
        self.backgroundColor = .white
        titleLabel.setSantanderTextFont(type: .bold, size: 17.0, color: .darkTorquoise)
        subtitleLabel.setSantanderTextFont(type: .regular, size: 10.0, color: .lisboaGray)
        noInterestLabel.text = localized("easyPay_text_noInterest")
        noInterestLabel.setSantanderTextFont(type: .regular, size: 10.0, color: .bostonRed)
    }
}
