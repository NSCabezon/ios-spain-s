import MapKit
import UI
import CoreFoundationLib

class CardMapClousterView: MKAnnotationView {
    var view: UIView!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var percentageView: UIView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var contentLabelsView: UIView!
    @IBOutlet private weak var percentageConstraint: NSLayoutConstraint!
    private let maxWidth: CGFloat = 152
    private let minWidth: CGFloat = 76
    private var customOffset: CGPoint {
        CGPoint(x: 0, y: 0)
    }
    
    init(annotation: PoiAnnotationClouster?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.xibSetup()
        self.setAppearance()
        self.setAccessibilityIdentifiers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.centerOffset = self.customOffset
    }
    
    func update() {
        self.centerOffset = self.customOffset
    }
    
    func set(annotations: [PoiAnnotation]) {
        let amount: Decimal = annotations.reduce(0) {
            $0 + ($1.model.amountValue ?? 0)
        }
        let totalValues: Decimal = annotations.first?.model.totalValues ?? 0
        self.amountLabel.text = self.amount(value: amount)
        let text = localized("shoppingMap_text_shopping_other", [StringPlaceholder(StringPlaceholder.Placeholder.number, "\(annotations.count)")])
        self.countLabel.configureText(withLocalizedString: text)
        self.updatePercentage(with: amount / totalValues)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

private extension CardMapClousterView {
    var bundle: Bundle? {
        return Bundle.module
    }
    
    func amount(value: Decimal) -> String {
        let defaultCurrency = MoneyDecorator.defaultCurrency
        return value.decorateAmount(defaultCurrency)
    }
    
    func setAppearance() {
        self.amountLabel.font = UIFont.santander(family: FontFamily.text, type: FontType.bold, size: 13)
        self.amountLabel.textColor = UIColor.lisboaGray
        self.countLabel.font = UIFont.santander(family: FontFamily.text, type: FontType.bold, size: 10)
        self.countLabel.textColor = UIColor.lisboaGray
        self.contentLabelsView.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.percentageView.backgroundColor = UIColor.bostonRed.withAlphaComponent(0.5)
        self.contentView.layer.cornerRadius = self.contentView.bounds.width / 2
        self.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor.clear
    }
    
    func updatePercentage(with percentage: Decimal) {
        let total = self.minWidth + CGFloat(NSDecimalNumber(decimal: percentage).floatValue) * ( self.maxWidth - self.minWidth )
        self.percentageConstraint.constant = total
        self.percentageView.layer.cornerRadius = total / 2
    }
    
    func xibSetup() {
        self.view = self.loadViewFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.view)
        self.view.fullFit()
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: self.bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func setAccessibilityIdentifiers() {
        self.isAccessibilityElement = false
        self.amountLabel.accessibilityIdentifier = AccessibilityCardMap.cardMapClousterViewAmountLabel
        self.countLabel.accessibilityIdentifier = AccessibilityCardMap.cardMapClousterViewCountLabel
        self.percentageView.accessibilityIdentifier = AccessibilityCardMap.cardMapClousterViewPercentageView
    }
}
