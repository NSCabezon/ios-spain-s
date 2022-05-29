//
//  AnalysisBalanceCell.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 10/06/2020.
//

import UI
import CoreFoundationLib

class AnalysisBalanceCell: UITableViewCell {
    static let cellIdentifier = "AnalysisBalanceCell"
    static let defaultHeight: CGFloat = 86.0
    @IBOutlet weak private var conceptLabel: UILabel!
    @IBOutlet weak private var accountLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var horizontalSeparator: UIView!
    @IBOutlet weak var discontinueLine: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
        
    public func configureWithBalance(_ balanceItem: BalanceItem, hideBottomLine: Bool, hideDiscontinue: Bool) {
        self.conceptLabel.configureText(withKey: balanceItem.concept.camelCasedString, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.80))
        self.accountLabel.text = balanceItem.accountFormmated.camelCasedString
        guard let amountDecimal = balanceItem.amount?.value else { return }
        self.amountLabel.attributedText = balanceItem.amountAttributedText(amountDecimal)
        horizontalSeparator.isHidden = hideBottomLine
        discontinueLine.isHidden = hideDiscontinue
    }
}

private extension AnalysisBalanceCell {
    func commonInit() {
        conceptLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        conceptLabel.textColor = .lisboaGray
        accountLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        accountLabel.textColor = .grafite
        amountLabel.font = .santander(family: .text, type: .bold, size: 20.0)
        amountLabel.textColor = .lisboaGray
        amountLabel.accessibilityIdentifier = AccessibilityAnalysisArea.amountLabel.rawValue
        horizontalSeparator.backgroundColor = .mediumSkyGray
        horizontalSeparator.isHidden = true
        self.addDiscontinueLine()
    }
    
    func addDiscontinueLine() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.mediumSkyGray.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [1, 1, 1, 1]
        let path = CGMutablePath()
        shapeLayer.position = CGPoint(x: 0, y: 0)
        path.addLines(between: [CGPoint(x: 0, y: 0),
                                CGPoint(x: discontinueLine.frame.width, y: 0)])
        shapeLayer.path = path
        self.discontinueLine.layer.addSublayer(shapeLayer)
    }
}
