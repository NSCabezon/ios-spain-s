//
//  LastContributionsLoansCell.swift
//  Menu
//
//  Created by Ignacio González Miró on 01/09/2020.
//

import UIKit
import UI
import CoreFoundationLib

class LastContributionsLoansCell: UITableViewCell {
    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var separatorView: DottedLineView!
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var progressView: ProgressBar!
    @IBOutlet private weak var progressViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var fromLabel: UILabel!
    @IBOutlet private weak var toLabel: UILabel!

    public static var identifier: String {
        return String(describing: self)
    }
    
    public static var height: CGFloat {
        return CGFloat(131.0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func config(_ viewModel: LastContributionsViewModel) {
        self.titleLabel.configureText(withLocalizedString: LocalizedStylableText(text: viewModel.loan?.title ?? "", styles: nil),
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 18.0),
                                                                                           alignment: .left,
                                                                                           lineHeightMultiple: 0.7))
        self.detailLabel.text = localized("loans_label_pending")
        self.ibanLabel.text = viewModel.loan?.iban
        let amountAtributed = viewModel.amountAttributedText(viewModel.loan?.amount?.value)
        self.amountLabel.attributedText = amountAtributed
        guard let loanEntity = viewModel.loan else { return }
        self.updateLoansFooter(viewModel, loanEntity: loanEntity)
    }
}

private extension LastContributionsLoansCell {
    func setupView() {
        self.selectionStyle = .none
        self.setAppeareance()
        self.setIdentifiers()
    }
    
    func setAppeareance() {
        let shadowColor = UIColor.lightSanGray.withAlphaComponent(0.35)
        let shadowConfiguration = ShadowConfiguration(color: shadowColor, opacity: 0.7, radius: 3.0, withOffset: 1, heightOffset: 2)
        self.baseView.drawRoundedBorderAndShadow(with: shadowConfiguration, cornerRadius: 6.0, borderColor: .mediumSkyGray, borderWith: 1.0)
        self.separatorView.strokeColor = .mediumSkyGray
        self.setLabels()        
        self.progressView.setProgressPercentage(0)
        self.progressView.setProgressAlpha(1)
    }
    
    func setLabels() {
        self.titleLabel.textColor = .lisboaGray
        self.detailLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        self.detailLabel.textColor = .grafite
        self.detailLabel.textAlignment = .right
        self.ibanLabel.font = .santander(family: .text, type: .light, size: 14.0)
        self.ibanLabel.textColor = .lisboaGray
        self.ibanLabel.textAlignment = .left
        self.amountLabel.textColor = .lisboaGray
        self.amountLabel.textAlignment = .right
        self.fromLabel.font = .santander(family: .text, type: .light, size: 12.0)
        self.fromLabel.textColor = .lisboaGray
        self.fromLabel.textAlignment = .left
        self.toLabel.font = .santander(family: .text, type: .light, size: 12.0)
        self.toLabel.textColor = .lisboaGray
        self.toLabel.textAlignment = .right
    }
    
    func setIdentifiers() {
        self.baseView.accessibilityIdentifier = AccessibilityLastContributions.lcLoansBaseView.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityLastContributions.lcLoansTitle.rawValue
        self.detailLabel.accessibilityIdentifier = AccessibilityLastContributions.lcLoansDetail.rawValue
        self.progressView.accessibilityIdentifier = AccessibilityLastContributions.lcLoansHorizontalGraph.rawValue
    }
    
    func updateLoansFooter(_ viewModel: LastContributionsViewModel, loanEntity: LastContributionsLoansEntity) {
        guard !loanEntity.startDate.isEmpty || !loanEntity.endsDate.isEmpty else {
            self.progressViewHeight.constant = 0
            self.footerView.isHidden = true
            self.separatorView.isHidden = true
            self.progressView.setProgressPercentage(0)
            return
        }
        self.separatorView.isHidden = false
        self.footerView.isHidden = false
        self.fromLabel.text = viewModel.loan?.startDate
        self.toLabel.text = viewModel.loan?.endsDate
        self.progressView.setProgressPercentageAnimated(loanEntity.progress)
    }
}
