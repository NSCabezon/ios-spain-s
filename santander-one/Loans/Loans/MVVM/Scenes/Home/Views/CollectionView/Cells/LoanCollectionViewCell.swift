//
//  LoanCollectionViewCell.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/10/19.
//
import UI
import UIKit
import CoreFoundationLib
import OpenCombine

struct LoanCollectionViewCellIdentifiers {
    var container: String?
    var loanAliasLabel = AccessibilityIDLoansHome.loanAlias.rawValue
    var loanContractNumberLabel = AccessibilityIDLoansHome.loanContractNumber.rawValue
    var loanStateLabel = AccessibilityIDLoansHome.loanState.rawValue
    var loanBalanceAmountLabel = AccessibilityIDLoansHome.loanBalanceAmount.rawValue
    var loanInitialExpirationDateLabel = AccessibilityIDLoansHome.loanEndDate.rawValue
    var loanOpeningDateLabel = AccessibilityIDLoansHome.loanStartDate.rawValue
    var loanProgressBar = AccessibilityIDLoansHome.loanProgressBar.rawValue
    var loanShareIcon = AccessibilityIDLoansHome.loanShareIcon.rawValue
}

class LoanCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var loanAliasLabel: UILabel!
    @IBOutlet weak var loanContractNumberLabel: UILabel!
    @IBOutlet weak var loanStateLabel: UILabel!
    @IBOutlet weak var loanBalanceAmountLabel: UILabel!
    @IBOutlet weak var loanInitialExpirationDateLabel: UILabel!
    @IBOutlet weak var loanOpeningDateLabel: UILabel!
    @IBOutlet weak var progressBarView: ProgressBar!
    private var viewModel: Loan?
    @IBOutlet weak var shareImageView: UIImageView!
    var didSelectShare: ((Loan) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.contentView.layer.borderWidth = 1.0
        self.shareImageView.image = Assets.image(named: "icnShare")?.withRenderingMode(.alwaysTemplate)
        self.shareImageView.tintColor = .grafite
    }
    
    @IBAction func didTapOnShare() {
        guard let viewModel = self.viewModel else { return }
        didSelectShare?(viewModel)
    }
    
    func configure(withViewModel viewModel: Loan) {
        self.viewModel = viewModel
        self.loanAliasLabel.text = viewModel.alias
        self.loanContractNumberLabel.text = viewModel.productNumber
        self.loanStateLabel.text = localized("loans_label_pending")
        self.loanBalanceAmountLabel.attributedText = viewModel.amountBigAttributedString
        self.loanOpeningDateLabel.text = viewModel.detail?.openingDate
        self.loanInitialExpirationDateLabel.text = viewModel.detail?.expirationDate
        self.progressBarView.setProgressPercentage(viewModel.detail?.progrees ?? 0)
        self.progressBarView.setProgressAlpha(1)
    }
    
    func animateProgress(withViewModel viewModel: Loan) {
        guard let detail = viewModel.detail else {
            self.progressBarView.setProgressPercentage(0)
            return
        }
        self.loanOpeningDateLabel.text = viewModel.detail?.openingDate
        self.loanInitialExpirationDateLabel.text = viewModel.detail?.expirationDate
        self.progressBarView.setProgressPercentageAnimated(detail.progrees)
    }
    
    func setAccessibilityIds(_ ids: LoanCollectionViewCellIdentifiers) {
        self.accessibilityIdentifier = ids.container
        self.loanAliasLabel.accessibilityIdentifier = ids.loanAliasLabel
        self.loanContractNumberLabel.accessibilityIdentifier = ids.loanContractNumberLabel
        self.shareImageView.isAccessibilityElement = true
        self.shareImageView.accessibilityIdentifier = ids.loanShareIcon
        self.loanStateLabel.accessibilityIdentifier = ids.loanStateLabel
        self.loanBalanceAmountLabel.accessibilityIdentifier = ids.loanBalanceAmountLabel
        self.progressBarView.isAccessibilityElement = true
        self.progressBarView.accessibilityIdentifier = ids.loanProgressBar
        self.loanOpeningDateLabel.accessibilityIdentifier = ids.loanOpeningDateLabel
        self.loanInitialExpirationDateLabel.accessibilityIdentifier = ids.loanInitialExpirationDateLabel
    }
}
