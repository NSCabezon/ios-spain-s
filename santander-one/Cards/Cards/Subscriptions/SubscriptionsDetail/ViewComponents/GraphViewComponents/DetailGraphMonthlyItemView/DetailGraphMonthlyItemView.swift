import UIKit
import UI
import CoreFoundationLib

struct DetailGraphConstants {
    static let maximunValue: CGFloat = 122
    static let maximumPercentage: CGFloat = 100
    static let minimunValue: CGFloat = 3
}

public final class DetailGraphMonthlyItemView: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var coloredViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var barChartView: GradientView!
    @IBOutlet private weak var spentLabel: UILabel!
    @IBOutlet private weak var barChartBottomView: UIView!
    @IBOutlet private weak var barChartFakeView: UIView!
    
    private var model: CardSubscriptionDetailMonthViewModel?
    private var shouldMakeAnimation = true
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        coloredViewHeightConstraint.constant = 3
        titleLabel.text = ""
        spentLabel.text = ""
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        barChartView.layer.cornerRadius = 4
    }

    func configView(_ model: CardSubscriptionDetailMonthViewModel, isLastMonth: Bool) {
        self.model = model
        self.titleLabel.text = model.monthTitle
        self.spentLabel.attributedText = amountAttributedString(amount: model.amount)
        updateColoredViewHeight(model)
        handleLabelBoldIfNeeded(isLastMonth)
        self.setNeedsLayout()
    }
}

private extension DetailGraphMonthlyItemView {
    func setupView() {
        setLabel(spentLabel)
        setLabel(titleLabel)
        barChartBottomView.backgroundColor = .lightRedGraphic
        barChartFakeView.backgroundColor = .bostonRedLight
        setAccessibilityIds()
    }
    
    func handleLabelBoldIfNeeded(_ isBold: Bool) {
        let fontType: FontType = isBold ? .bold : .regular
        self.spentLabel.font = UIFont.santander(family: .text, type: fontType, size: 12)
        self.titleLabel.font = UIFont.santander(family: .text, type: fontType, size: 12)
    }
    
    func setLabel(_ label: UILabel) {
        label.textAlignment = .center
        label.textColor = .lisboaGray
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardSubscriptionDetail.graphMonthlyItemBaseView
        spentLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.graphMonthlyItemSpentLabel
        titleLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.graphMonthlyItemTitleLabel
    }
    
    func updateColoredViewHeight(_ model: CardSubscriptionDetailMonthViewModel) {
        let decimalPercentage = NSDecimalNumber(decimal: model.percentage)
        let percentage: CGFloat = CGFloat(truncating: decimalPercentage)
        let realPercentage = (DetailGraphConstants.maximunValue * percentage)
        let realValue = realPercentage + DetailGraphConstants.minimunValue
        animateBar(realValue)
    }
    
    func animateBar(_ value: CGFloat) {
        self.coloredViewHeightConstraint.constant = value
        if shouldMakeAnimation {
            shouldMakeAnimation = false
            UIView.animate(withDuration: 1.5) {
                self.layoutIfNeeded()
            }
        }
    }
    
    func amountAttributedString(amount: AmountEntity?) -> NSAttributedString? {
        guard let availableAmount: AmountEntity = amount else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .regular, size: 12)
        let amount = MoneyDecorator(availableAmount.changedSign, font: font)
        return amount.getFormatedCurrency()
    }
}

final class GradientView: UIView {
    override public class var layerClass: AnyClass {
       return CAGradientLayer.classForCoder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        guard let gradientLayer = layer as? CAGradientLayer else { return }
        let bostonRedLightColor = UIColor.bostonRedLight
        let lightRedGraphicColor = UIColor.lightRedGraphic
        gradientLayer.colors = [lightRedGraphicColor.cgColor, bostonRedLightColor.cgColor]
    }
}
