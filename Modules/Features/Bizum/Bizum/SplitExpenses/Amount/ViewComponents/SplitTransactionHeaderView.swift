//
//  SplitTransactionHeaderView.swift
//  Bizum

import UI
import ESUI

protocol SplitTransactionHeaderViewProtocol: class {
    func update(with viewModel: SplitTransactionViewModel)
}

final class SplitTransactionHeaderView: XibView {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var transactionTitleLabel: UILabel!
    @IBOutlet private weak var transactionProductLabel: UILabel!
    @IBOutlet private weak var transactionAmountLabel: UILabel!
    @IBOutlet private weak var splitImageView: UIImageView!
    @IBOutlet private weak var bottomImageView: UIImageView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var separatorView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension SplitTransactionHeaderView {
    func setupView() {
        self.contentView.drawBorder(cornerRadius: 0, color: .mediumSkyGray, width: 1.0)
        self.splitImageView.image = ESAssets.image(named: "icnShareExpenseGreen")
        self.bottomImageView.image = Assets.image(named: "icnBrokenPaper")
        self.view?.backgroundColor = .skyGray
        self.transactionTitleLabel.setSantanderTextFont(type: .bold, size: 18, color: .lisboaGray)
        self.transactionProductLabel.setSantanderTextFont(size: 14, color: .grafite)
        self.transactionTitleLabel.numberOfLines = 0
        self.transactionProductLabel.numberOfLines = 0
        self.transactionAmountLabel.setSantanderTextFont(color: .lisboaGray)
        self.separatorView.backgroundColor = .mediumSkyGray
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.transactionAmountLabel.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountOperationHeaderLabelAmount
        self.contentView.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountOperationHeaderContentView
        self.splitImageView.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountOperationHeaderSplitExpensesIcon
        self.bottomImageView.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountOperationHeaderBottomImageView
    }
}

extension SplitTransactionHeaderView: SplitTransactionHeaderViewProtocol {
    func update(with viewModel: SplitTransactionViewModel) {
        self.transactionTitleLabel.configureWithTextAndAccessibility(viewModel.title)
        if let origin = viewModel.origin {
            self.transactionProductLabel.configureWithTextAndAccessibility(origin)
        }
        self.transactionAmountLabel.attributedText = viewModel.amountWithAttributed
    }
}
