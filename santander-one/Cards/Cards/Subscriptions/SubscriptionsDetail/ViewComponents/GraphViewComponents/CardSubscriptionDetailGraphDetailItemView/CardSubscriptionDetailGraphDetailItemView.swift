import Foundation
import UIKit
import UI
import CoreFoundationLib

public final class CardSubscriptionDetailGraphDetailItemView: XibView {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var imageIconView: UIImageView!
    @IBOutlet private weak var titleTotalAnnualSpentLabel: UILabel!
    @IBOutlet private weak var textTotalAnnualSpentLabel: UILabel!
    @IBOutlet private weak var separatorView: DottedLineView!
    @IBOutlet private weak var titleAverageMonthlySpentLabel: UILabel!
    @IBOutlet private weak var textAverageMonthlySpentLabel: UILabel!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: CardSubscriptionDetailSummaryViewModel) {
        self.titleTotalAnnualSpentLabel.configureText(withLocalizedString: localized("m4m_label_paymentsTotal", [StringPlaceholder(.number, viewModel.titleTotalAnnualSpent)]))
        self.textTotalAnnualSpentLabel.attributedText = availableBigAmountAttributedString(viewModel.textTotalAnnualSpent)
        self.titleAverageMonthlySpentLabel.configureText(withLocalizedString: localized("m4m_label_averageSpending", [StringPlaceholder(.number, viewModel.titleAverageMonthlySpent)]))
        self.textAverageMonthlySpentLabel.attributedText = availableBigAmountAttributedString(viewModel.textAverageMonthlySpent)
    }
}
 
private extension CardSubscriptionDetailGraphDetailItemView {
    
    func setupView() {
        backgroundColor = .blue
        self.separatorView.backgroundColor = .clear
        self.separatorView.strokeColor = .lightSanGray
        self.separatorView.lineDashPattern = [1, 1]
        imageIconView.image = Assets.image(named: "icnPaymentsTotal")
        setLabelsConfiguration()
        setAccessibilityIds()
    }
    
    func setLabelsConfiguration() {
        setTitleTotalAnualSpentLabel()
        setTitleAverageMonthlySpentLabel()
        textTotalAnnualSpentLabel.textColor = .lisboaGray
        textAverageMonthlySpentLabel.textColor = .lisboaGray
    }
    
    func setTitleTotalAnualSpentLabel() {
        titleTotalAnnualSpentLabel.font = UIFont.santander(family: .text, type: .bold, size: 14)
        titleTotalAnnualSpentLabel.textColor = .lisboaGray
        titleTotalAnnualSpentLabel.textAlignment = .center
        titleTotalAnnualSpentLabel.numberOfLines = 1
        titleTotalAnnualSpentLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setTitleAverageMonthlySpentLabel() {
        titleAverageMonthlySpentLabel.font = UIFont.santander(family: .text, type: .regular, size: 12)
        titleAverageMonthlySpentLabel.textColor = .lisboaGray
        titleAverageMonthlySpentLabel.textAlignment = .center
        titleAverageMonthlySpentLabel.numberOfLines = 1
        titleAverageMonthlySpentLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardSubscriptionDetail.graphItemBaseView
        titleTotalAnnualSpentLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.graphItemTitleTotalAnualSpentLabel
        titleAverageMonthlySpentLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.graphItemTitleAverageMonthlySpentLabel
        textTotalAnnualSpentLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.graphItemTextTotalAnualSpentLabel
        textAverageMonthlySpentLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.graphItemTextAverageMonthlySpentLabel
        imageIconView.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.graphItemImageView
    }
    
    func availableBigAmountAttributedString(_ amount: AmountEntity?) -> NSAttributedString? {
        guard let availableAmount: AmountEntity = amount else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let amount = MoneyDecorator(availableAmount, font: font, decimalFontSize: 15)
        return amount.getFormatedCurrency()
    }
}
