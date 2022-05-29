import UIKit
import UI
import CoreFoundationLib

class AmountButton: UIView, DiscreteModeConformable {
    
    var discreteMode: Bool = false {
        didSet {
            subtitle.isBlured = discreteMode
        }
    }
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20))
        return label
    }()
    
    private lazy var subtitle: BluringLabel = {
        let label = BluringLabel()
        label.textAlignment = .right
        label.applyTextAlignmentToAttributedText = true
        label.minimumScaleFactor = 0.6
        label.initializeCanvas()
        label.blurRadius = 14
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .trailing
        return stackView
    }()
    
    var onTapAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.onTapAction?()
    }
    
    func setTitle(_ title: NSAttributedString?) {
        self.title.attributedText = title
    }
    
    func setSubtitle(_ subtitle: NSAttributedString?) {
        self.subtitle.attributedText = subtitle
        self.setAmountLabelAccessibility()
    }

    func setDiscreteMode(_ enabled: Bool) {
        self.discreteMode = enabled
    }
    
    func setSelected(isSelected: Bool) {
        self.subtitle.renderMargin = isSelected ? 25 : 0.0
        self.subtitle.isBlured = self.discreteMode
    }
}
private extension AmountButton {
    
    func setupViews() {
        addSubview(self.stackView)
        self.stackView.addArrangedSubview(title)
        self.stackView.addArrangedSubview(subtitle)
        
        self.stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        self.title.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 1.0).isActive = true
        self.subtitle.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 1.0).isActive = true
        
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.title.accessibilityIdentifier = AccessibilityGlobalPosition.pgLabelTotFinancing
        self.subtitle.accessibilityIdentifier = AccessibilityGlobalPosition.pgLabelTotFinancingValue
    }
    
    func setAmountLabelAccessibility() {
        guard let label = self.subtitle.attributedText?.string else { return }
        let billons = localized("voiceover_billions").text
        let millons = localized("voiceover_millons").text
        self.subtitle.accessibilityLabel = label.replacingOccurrences(of: "B", with: billons)
        self.subtitle.accessibilityLabel = label.replacingOccurrences(of: "M", with: millons)
    }
}
