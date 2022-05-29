import UIKit
import UI
import MapKit
import OpenCombine
import CoreFoundationLib

enum PoiPointViewtate: State {
    case idle
    case centerUpdated(PoiPointView)
}

class PoiPointView: MKAnnotationView {
    var view: UIView!
    @IBOutlet private weak var stackView: Stackview!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleView: UIView!
    @IBOutlet private weak var arrowImage: UIImageView!
    @IBOutlet private weak var calloutView: UIView!
    @IBOutlet private weak var calloutContentView: UIView!
    @IBOutlet private weak var calloutArrowView: LineTriangularView!
    @IBOutlet private weak var calloutDateLabel: UILabel!
    @IBOutlet private weak var calloutTitleLabel: UILabel!
    @IBOutlet private weak var calloutAliasLabel: UILabel!
    @IBOutlet private weak var calloutAmountLabel: UILabel!
    @IBOutlet private weak var calloutAddressLabel: UILabel!
    private var customOffset: CGPoint {
        CGPoint(x: 0, y: 5 - frame.size.height / 2)
    }
    private let stateSubject = CurrentValueSubject<PoiPointViewtate, Never>(.idle)
    var state: AnyPublisher<PoiPointViewtate, Never>
    
    init(annotation: PoiAnnotation?, reuseIdentifier: String?) {
        state = stateSubject.eraseToAnyPublisher()
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        xibSetup()
        setAppearance()
        setDelegates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        state = stateSubject.eraseToAnyPublisher()
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        calloutView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerOffset = customOffset
    }

    func set(model: CardMapItem) {
        titleLabel.text = model.amountDecorated
        calloutDateLabel.attributedText = model.dateDecorated
        calloutTitleLabel.text = model.name?.camelCasedString
        calloutAliasLabel.text = model.alias?.camelCasedString
        calloutAmountLabel.attributedText = model.amountSmartDecorated
        calloutAddressLabel.text = model.addressDecorated?.camelCasedString
        setAccessibilityIdentifiers()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func showCalloutView() {
        calloutView.isHidden = false
        setCalloutViewAccessibility(isAccessible: true)
    }
    
    func hiddeCalloutView() {
        calloutView.isHidden = true
        setCalloutViewAccessibility(isAccessible: false)
    }
    
    func update() {
        centerOffset = customOffset
    }
}

private extension PoiPointView {
    var bundle: Bundle? {
        return Bundle.module
    }
    
    func setDelegates() {
        stackView.delegate = self
    }
    
    func setAppearance() {
        backgroundColor = UIColor.clear
        calloutView.isHidden = true
        titleView.backgroundColor = .white
        titleView.layer.cornerRadius = 2
        titleView.layer.borderWidth = 2
        titleView.layer.borderColor = UIColor.bostonRed.cgColor
        titleLabel.textColor = UIColor.lisboaGray
        titleLabel.font = UIFont.santander(family: FontFamily.text, type: FontType.bold, size: 13)
        arrowImage.image = Assets.image(named: "icnPosition")
        calloutDateLabel.font = UIFont.santander(family: FontFamily.text, type: FontType.regular, size: 13)
        calloutDateLabel.textColor = UIColor.lisboaGray
        calloutTitleLabel.font = UIFont.santander(family: FontFamily.text, type: FontType.bold, size: 14)
        calloutTitleLabel.textColor = UIColor.lisboaGray
        calloutTitleLabel.preferredMaxLayoutWidth = 200
        calloutAliasLabel.font = UIFont.santander(family: FontFamily.text, type: FontType.regular, size: 13)
        calloutAliasLabel.textColor = UIColor.lisboaGray
        calloutAliasLabel.preferredMaxLayoutWidth = 200
        calloutAmountLabel.font = UIFont.santander(family: FontFamily.text, type: FontType.bold, size: 25)
        calloutAmountLabel.textColor = UIColor.santanderRed
        calloutAddressLabel.font = UIFont.santander(family: FontFamily.text, type: FontType.regular, size: 13)
        calloutAddressLabel.textColor = UIColor.lisboaGray
        calloutAddressLabel.preferredMaxLayoutWidth = 200
        calloutContentView.layer.cornerRadius = 5
        calloutContentView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        calloutContentView.layer.borderWidth = 1
        calloutView.backgroundColor = .clear
        calloutView.layer.shadowColor = UIColor.grafite.cgColor
        calloutView.layer.shadowOffset = CGSize(width: 0, height: 4)
        calloutView.layer.shadowRadius = 6
        calloutView.layer.shadowOpacity = 0.15
        calloutArrowView.backgroundColor = UIColor.clear
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.fullFit()
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityCardMap.poiPointViewTitleView
        titleLabel.accessibilityIdentifier = AccessibilityCardMap.poiPointViewTitleLabel
        calloutDateLabel.accessibilityIdentifier = AccessibilityCardMap.poiPointCalloutViewDateLabel
        calloutTitleLabel.accessibilityIdentifier = AccessibilityCardMap.poiPointCalloutViewTitleLabel
        calloutAliasLabel.accessibilityIdentifier = AccessibilityCardMap.poiPointCalloutViewAliasLabel
        calloutAmountLabel.accessibilityIdentifier = AccessibilityCardMap.poiPointCalloutViewAmountLabel
        calloutAddressLabel.accessibilityIdentifier = AccessibilityCardMap.poiPointCalloutViewAddressLabel
    }
    
    func setCalloutViewAccessibility(isAccessible: Bool) {
        self.isAccessibilityElement = !isAccessible
        calloutView.isAccessibilityElement = false
    }
}

extension PoiPointView: StackviewDelegate {
    func didChangeBounds(for stackview: UIStackView) {
        centerOffset = customOffset
        stateSubject.send(.centerUpdated(self))
    }
}
