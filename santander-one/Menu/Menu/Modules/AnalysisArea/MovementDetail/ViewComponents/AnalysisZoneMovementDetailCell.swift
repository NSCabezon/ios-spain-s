//
//  AnalysisZoneMovementDetailCell.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 24/06/2020.
//

import UI
import CoreFoundationLib

final class AnalysisZoneMovementDetailCell: UICollectionViewCell {
    static let cellIdentifier = "AnalysisZoneMovementDetailCell"
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var accountAliasLabel: UILabel!
    @IBOutlet weak private var accountNumberLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var discontinueLineView: UIView!
    @IBOutlet weak private var dateTitleLabel: UILabel!
    @IBOutlet weak private var dateValueLabel: UILabel!
    @IBOutlet weak private var tornImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
        setupLabels()
    }
    
    public func configureCellWithEntity(_ item: AnalysisMovementDetailEntity) {
        self.accountAliasLabel.text = item.concept.camelCasedString
        self.accountNumberLabel.text = item.ibanString
        self.dateValueLabel.text = item.operationDateString
        self.amountLabel.attributedText = item.attributedAmountString
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        discontinueLineView.dotted(with: [1, 1, 1, 1], color: UIColor.mediumSkyGray.cgColor)
    }
}

private extension AnalysisZoneMovementDetailCell {
    func configureView() {
        self.tornImageView.image = Assets.image(named: "imgTorn")
        self.containerView.backgroundColor = UIColor.white
        containerView.drawBorder(cornerRadius: 0, color: .mediumSkyGray, width: 1.0)
        self.accessibilityIdentifier = AccessibilityAnalysisArea.timeLinedetail.rawValue
    }
    
    func setupLabels() {
        accountAliasLabel.font = .santander(family: .text, type: .bold, size: 18.0)
        accountAliasLabel.textColor = .lisboaGray
        
        accountNumberLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        accountNumberLabel.textColor = .grafite
        
        amountLabel.font = .santander(family: .text, type: .bold, size: 32.0)
        amountLabel.textColor = .lisboaGray
        
        dateTitleLabel.font = .santander(family: .text, type: .regular, size: 13.0)
        dateTitleLabel.textColor = .grafite
        dateTitleLabel.configureText(withKey: "transaction_label_operationDate", andConfiguration: nil)
        
        dateValueLabel.font = .santander(family: .text, type: .regular, size: 13.0)
        dateValueLabel.textColor = .lisboaGray
    }
}
