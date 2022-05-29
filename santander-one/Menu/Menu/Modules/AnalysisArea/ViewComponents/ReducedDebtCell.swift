//
//  ReducedDebtCell.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 23/03/2020.
//

import UI

class ReducedDebtCell: UITableViewCell, ConfigurableExpenseCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private weak var arrowImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func configurewithModel(_ model: ExpenseItem) {
        amountLabel.attributedText = model.amountString
        icon.image = Assets.image(named: "icnDebt")
        titleLabel.configureText(withLocalizedString: model.title)
        subtitleLabel.configureText(withLocalizedString: model.subtitle)
        accessibilityIdentifier = model.accessibilityIdentifier
    }
}

private extension ReducedDebtCell {
    func configureUI() {
        self.contentView.backgroundColor = UIColor.darkTurqLight.withAlphaComponent(0.1)
        self.titleLabel.setSantanderTextFont(type: .regular, size: 16.0, color: .lisboaGray)
        self.subtitleLabel.setSantanderTextFont(type: .light, size: 14.0, color: .lisboaGray)
        self.amountLabel.setSantanderTextFont(type: .regular, size: 20.0, color: .lisboaGray)
        self.bottomSeparator.backgroundColor = .mediumSkyGray
        self.arrowImage.image = Assets.image(named: "icnArrowRight")
    }
}
