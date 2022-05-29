import UIKit
import UI
import CoreFoundationLib

public class ConfirmationTotalOperationItemView: UIView {
    private var view: UIView?
    private var groupedAccessibilityElements: [Any]?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setup(with viewModel: ConfirmationTotalOperationItemViewModel) {
        let moneyDecorator = MoneyDecorator(viewModel.amountEntity,
                                            font: .santander(family: .text, type: .bold, size: 40),
                                            decimalFontSize: 26)
        self.titleLabel.configureText(withLocalizedString: localized(viewModel.totalTitleKey))
        self.valueLabel.attributedText = moneyDecorator.formatAsMillions()
    }
}

private extension ConfirmationTotalOperationItemView {
    func setupView() {
        self.xibSetup()
        self.titleLabel.setSantanderTextFont(size: 14, color: .grafite)
        self.valueLabel.setSantanderTextFont(type: .bold, size: 40, color: .lisboaGray)
        self.view?.backgroundColor = .veryLightGray
        self.setupAccessibilityId()
    }
    
    func xibSetup() {
        self.view = self.loadViewFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.view ?? UIView())
        self.view?.fullFit()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func setupAccessibilityId() {
        self.titleLabel.accessibilityIdentifier = AccessibilityOtherOperatives.lblConfirmationTotalAmount.rawValue
        self.valueLabel.accessibilityIdentifier = AccessibilityOtherOperatives.lblConfirmationTotalAmount.rawValue + "_value"
    }
}
