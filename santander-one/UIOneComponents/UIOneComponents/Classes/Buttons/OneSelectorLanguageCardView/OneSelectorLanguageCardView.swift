import UI
import UIKit
import CoreFoundationLib

public class OneSelectorLanguageCardView: UIButton {
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView(image: Assets.image(named: "oneSelectLanguageCardCheck"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var selectedBackgroundColor = UIColor.oneDarkTurquoise.withAlphaComponent(0.07)
    private var selectedBorderColor = UIColor.clear
    private var selectedTitleColor = UIColor.oneDarkTurquoise
    
    private var notSelectedBackgroundColor = UIColor.oneWhite
    private var notSelectedBorderColor = UIColor.oneMediumSkyGray
    private var notSelectedTitleColor = UIColor.oneLisboaGray
    
    private var disabledBackgroundColor = UIColor.oneLightGray40
    private var disabledBorderColor = UIColor.clear
    private var disabledTitleColor = UIColor.oneBrownGray
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public convenience init(optionData: OneSelectorLanguageValueOptionType?) {
        self.init(frame: .zero)
        self.optionData = optionData
        setupView(optionData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var optionData: OneSelectorLanguageValueOptionType? {
        didSet {
            self.setupView(optionData)
        }
    }
    
    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

// MARK: - Private
private extension OneSelectorLanguageCardView {
    func commonInit() {
        setupLayer()
        setupTitleLabel()
        setupCheckImageViewView()
    }
    
    func setupView(_ optionData: OneSelectorLanguageValueOptionType?) {
        if optionData?.isEnabled == true {
            optionData?.highlightAction = { [weak self] shouldHighlight in
                self?.isHighlighted = shouldHighlight
                self?.checkImageView.isHidden = !shouldHighlight
                self?.backgroundColor = shouldHighlight ? self?.selectedBackgroundColor : self?.notSelectedBackgroundColor
                self?.layer.borderColor = shouldHighlight ? self?.selectedBorderColor.cgColor : self?.notSelectedBorderColor.cgColor
                let titleColor = shouldHighlight ? self?.selectedTitleColor : self?.notSelectedTitleColor
                self?.setTitleColor(titleColor, for: .normal)
            }
        } else {
            checkImageView.isHidden = true
            backgroundColor = disabledBackgroundColor
            layer.borderColor = disabledBorderColor.cgColor
            setTitleColor(disabledTitleColor, for: .normal)
        }
        isEnabled = optionData?.isEnabled == true
    }
    
    func setupLayer() {
        layer.borderWidth = 1
        layer.cornerRadius = 5
    }
    
    func setupTitleLabel() {
        titleLabel?.textColor = UIColor.oneLisboaGray
        titleLabel?.scaledFont = UIFont.santander(family: .micro, type: .bold, size: 14)
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.numberOfLines = 3
        titleLabel?.textAlignment = .center
    }
    
    func setupCheckImageViewView() {
        addSubview(checkImageView)
        NSLayoutConstraint.activate([
            checkImageView.heightAnchor.constraint(equalToConstant: 16),
            checkImageView.widthAnchor.constraint(equalToConstant: 16),
            checkImageView.topAnchor.constraint(equalTo: topAnchor, constant: -8),
            checkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8)
        ])
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.accessibilityIdentifier = AccessibilityOneComponents.oneSelectorLanguageCardView + (suffix ?? "")
        self.titleLabel?.accessibilityIdentifier = AccessibilityOneComponents.oneSelectorLanguageCardLabel + (suffix ?? "")
        self.checkImageView.accessibilityIdentifier = AccessibilityOneComponents.oneSelectLanguageCardCheck + (suffix ?? "")
    }
}
