//
//  TimeLineMovementCell.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 23/03/2020.
//

import UI

protocol ConfigurableExpenseCell: AnyObject {
    func configurewithModel(_ model: ExpenseItem)
}

class TimeLineMovementCell: UITableViewCell, ConfigurableExpenseCell {
    static let cellHeight: CGFloat = 80
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var movementCountLabel: UILabel!
    @IBOutlet private weak var bottomLineSeparator: UIView!
    @IBOutlet private weak var arrowImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func hideBottomLine(_ visibility: Bool) {
        bottomLineSeparator.isHidden = visibility
    }
    
    func configurewithModel(_ model: ExpenseItem) {
        amountLabel.attributedText = model.amountString
        movementCountLabel.text = String(model.count)
        titleLabel.configureText(withLocalizedString: model.title)
        if [.bizumReceived, .bizumEmitted].contains(model.expenseType) {
            if let optionalSubtitle = model.customSubtitle {
                subtitleLabel.text = "***\(optionalSubtitle.suffix(3))"
            }
        } else {
            subtitleLabel.configureText(withLocalizedString: model.subtitle)
        }
        accessibilityIdentifier = model.accessibilityIdentifier
    }
}

private extension TimeLineMovementCell {
    func configureUI() {
        self.titleLabel.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
        self.subtitleLabel.setSantanderTextFont(type: .light, size: 14.0, color: .lisboaGray)
        self.movementCountLabel.setSantanderTextFont(type: .bold, size: 22.0, color: .darkTorquoise)
        self.amountLabel.setSantanderTextFont(type: .regular, size: 20.0, color: .lisboaGray)
        self.bottomLineSeparator.backgroundColor = .mediumSkyGray
        self.arrowImage.image = Assets.image(named: "icnArrowRight")
    }
}
