//
//  FractionatePaymentCell.swift
//  Pods
//
//  Created by Hernán Villamil on 8/4/22.
//

import UI
import CoreFoundationLib

final class FractionatePaymentCell: UICollectionViewCell {
    static let cellIdentifier = "fractionate_pay_cell"
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var noInterestLabel: UILabel!
    var configuration: FractionatePaymentCellConfiguration? {
        didSet { configureView(configuration) }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        noInterestLabel.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commoninit()
    }
}

private extension FractionatePaymentCell {
    func commoninit() {
        setAppearance()
        setLabels()
    }
    
    func setAppearance() {
        backgroundColor = .white
        drawBorder(cornerRadius: 5.0, color: .mediumSkyGray, width: 1.2)
        layer.masksToBounds = false
        drawShadow(offset: (x: 0, y: 2), opacity: 0.3, color: .atmsShadowGray, radius: 3.0)
    }
    
    func setLabels() {
        titleLabel.setSantanderTextFont(type: .bold, size: 17.0, color: .darkTorquoise)
        subtitleLabel.setSantanderTextFont(type: .regular, size: 10.0, color: .lisboaGray)
        noInterestLabel.text = localized("easyPay_text_noInterest")
        noInterestLabel.setSantanderTextFont(type: .regular, size: 10.0, color: .bostonRed)
    }
    
    func configureView(_ configuration: FractionatePaymentCellConfiguration?) {
        guard let unwrappedConfiguration = configuration else { return }
        self.titleLabel.configureText(withLocalizedString: unwrappedConfiguration.title)
        self.subtitleLabel.configureText(withLocalizedString: unwrappedConfiguration.subtitle)
        self.accessibilityIdentifier = unwrappedConfiguration.accessibilityId
        self.noInterestLabel.isHidden = !unwrappedConfiguration.noInterestIsHidden
    }
}
