//

import UIKit
import CoreFoundationLib

extension EasyPayAmortizationTableViewCell: EasyPayTableViewCellProtocol {
    func setCellInfo(_ info: Any) {
        
    }
}

final class EasyPayAmortizationTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var dateInfoLabel: UILabel!
    @IBOutlet private weak var dateDataLabel: UILabel!
    @IBOutlet private weak var capitalInfoLabel: UILabel!
    @IBOutlet private weak var capitalDataLabel: UILabel!
    @IBOutlet private weak var totalInfoLabel: UILabel!
    @IBOutlet private weak var totalDataLabel: UILabel!
    @IBOutlet private weak var pendingInfoLabel: UILabel!
    @IBOutlet private weak var pendingDataLabel: UILabel!
    @IBOutlet private weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.drawBorder(color: .lisboaGray)
        containerView.clipsToBounds = true
        shadowView.drawShadow(color: UIColor.black.withAlphaComponent(0.05))
        shadowView.drawBorder(color: .lisboaGray)
        headerView.backgroundColor = .brownGray
        backgroundColor = .bg
        selectionStyle = .none
        configureLabel(headerLabel, color: .white, font: UIFont.santander(size: 16.0))
        configureLabel(dateInfoLabel)
        configureLabel(dateDataLabel, alignment: .right)
        configureLabel(capitalInfoLabel)
        configureLabel(capitalDataLabel, alignment: .right)
        configureLabel(totalInfoLabel)
        configureLabel(totalDataLabel, alignment: .right)
        configureLabel(pendingInfoLabel, font: UIFont.santander(type: .bold, size: 16.0))
        configureLabel(pendingDataLabel, font: UIFont.santander(type: .bold, size: 16.0), alignment: .right)
    }
    
    private func configureLabel(_ label: UILabel,
                                color: UIColor = .brownGray,
                                font: UIFont = UIFont.santander(type: .light, size: 16.0),
                                alignment: NSTextAlignment = .left) {
        label.textColor = color
        label.font = font
        label.textAlignment = alignment
    }
    
    var header: LocalizedStylableText = .empty {
        didSet {
            headerLabel.configureText(withLocalizedString: header)
        }
    }
    var dateInfo: LocalizedStylableText = .empty {
        didSet {
            dateInfoLabel.configureText(withLocalizedString: dateInfo)
        }
    }
    var date: String? {
        didSet {
            dateDataLabel.text = date
        }
    }
    var capitalInfo: LocalizedStylableText = .empty {
        didSet {
            capitalInfoLabel.configureText(withLocalizedString: capitalInfo)
        }
    }
    var capital: String? {
        didSet {
            capitalDataLabel.text = capital
        }
    }
    var totalInfo: LocalizedStylableText = .empty {
        didSet {
            totalInfoLabel.configureText(withLocalizedString: totalInfo)
        }
    }
    var total: String? {
        didSet {
            totalDataLabel.text = total
        }
    }
    var pendingInfo: LocalizedStylableText = .empty {
        didSet {
            pendingInfoLabel.configureText(withLocalizedString: pendingInfo)
        }
    }
    var pending: String? {
        didSet {
            pendingDataLabel.text = pending
        }
    }
}
