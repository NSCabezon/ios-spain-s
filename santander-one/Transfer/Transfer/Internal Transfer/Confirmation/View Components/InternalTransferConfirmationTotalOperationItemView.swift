import UIKit
import UI
import CoreFoundationLib

final class InternalTransferConfirmationTotalOperationItemView: UIView {
    
    private var view: UIView!
    private var groupedAccessibilityElements: [Any]?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setup(with amount: AmountEntity) {
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 40), decimalFontSize: 26)
        self.titleLabel.configureText(withKey: "confirmation_label_totalOperation")
        self.valueLabel.attributedText = moneyDecorator.formatAsMillions()
        self.titleLabel.accessibilityIdentifier = AccessibilityConfirmationView.labelTotal.rawValue
        self.valueLabel.accessibilityIdentifier = AccessibilityConfirmationView.amountTotal.rawValue
    }
}

private extension InternalTransferConfirmationTotalOperationItemView {
    
    func setupView() {
        self.xibSetup()
        self.titleLabel.setSantanderTextFont(size: 14, color: .grafite)
        self.valueLabel.setSantanderTextFont(type: .bold, size: 40, color: .lisboaGray)
        self.view.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
    }
    
    func xibSetup() {
        self.view = self.loadViewFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.view)
        self.view.fullFit()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
}

extension InternalTransferConfirmationTotalOperationItemView {
    public override var accessibilityElements: [Any]? {
        get {
            if let accessibilityItems = groupedAccessibilityElements {
                return accessibilityItems
            }
            groupedAccessibilityElements = self.groupElements([])
            return groupedAccessibilityElements
        }
        set {
            groupedAccessibilityElements = newValue
        }
    }
}
