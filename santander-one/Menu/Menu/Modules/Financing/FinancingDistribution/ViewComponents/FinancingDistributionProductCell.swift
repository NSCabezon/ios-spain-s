//
//  FinancingDistributionProductCell.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 31/08/2020.
//

import UI
import CoreFoundationLib

class FinancingDistributionProductCell: UITableViewCell {
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var topSeparator: UIView!
    
    static let cellIdentifier = "FinancingDistributionProductCell"
    static let nibName = "FinancingDistributionProductCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    public func configureCellWithItem(_ item: FinanceGraphData) {
        let valueAsNumber = NSDecimalNumber(decimal: item.value)
        let placeHolder = StringPlaceholder(.value, valueAsNumber.doubleValue.asFinancialAgregatorPercentText(includePercentSimbol: false))
        let txt = localized(item.type.localizedKey, [placeHolder])
        self.titleLabel.configureText(withLocalizedString: txt)
        self.amountLabel.attributedText = FinanceDistributionViewModel.formattedMoneyFromAmount(item.amount)
        self.iconImageView.image = Assets.image(named: item.type.iconName)
        self.titleLabel.accessibilityIdentifier = item.type.titleAccessibilityIdentifier
        self.amountLabel.accessibilityIdentifier = item.type.amountAccessibilityIdentifier
    }
}

private extension FinancingDistributionProductCell {
    func setupView() {
        titleLabel.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
        titleLabel.lineBreakMode = .byWordWrapping
        amountLabel.setSantanderTextFont(type: .bold, size: 18.0, color: .lisboaGray)
        topSeparator.backgroundColor = .mediumSkyGray
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityFinancingDistribution.productTitle
        self.iconImageView.accessibilityIdentifier = AccessibilityFinancingDistribution.productIcon
        self.amountLabel.accessibilityIdentifier = AccessibilityFinancingDistribution.amount
    }
}
