import CoreFoundationLib
import UIKit
import UI

struct TitleViewModel {
    let style: OneNavigationBarStyle
    let titleKey: String
    let titleImage: OneNavigationBarTitleImage?
    let titleConfiguration: LocalizedStylableTextConfiguration?
    let tooltipAction: ((UIView) -> Void)?
    let tooltipAccessibilityLabelKey: String?
    let accessibilityLabelKey: String
    let accessibilityValue: String?
    let accessibilityHint: String?
}

final class TitleView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .typography(fontName: .oneB400Bold)
        label.textColor = .oneSantanderRed
        return label
    }()
    private lazy var tooltipImageView: UIImageView = {
        let icon = UIImageView(image: Assets.image(named: "icnInfoRedLight")?.withRenderingMode(.alwaysTemplate))
        icon.isAccessibilityElement = true
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stack)
        return stack
    }()
    private var viewModel: TitleViewModel?
    
    private var action: ((UIView) -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tooltipImageView.alpha = 0.5
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.4) {
            self.tooltipImageView.alpha = 1.0
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.4) {
            self.tooltipImageView.alpha = 1.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    override func accessibilityElementDidBecomeFocused() {
        if self.accessibilityElementIsFocused() {
            self.isAccessibilityElement = false
            DispatchQueue.main.async {
                UIAccessibility.post(notification: .layoutChanged, argument: self.label)
            }
        }
    }
    
    init(_ info: TitleViewModel) {
        super.init(frame: .zero)
        self.viewModel = info
        self.commonInit()
        self.set(info: info)
        self.setAccessibilityIdentifiers()
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
}

private extension TitleView {
    @objc func didTapOnTooltip(sender: UIGestureRecognizer) {
        self.action?(sender.view!)
    }
    
    func commonInit() {
        self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapOnTooltip)))
    }
    
    func set(info: TitleViewModel) {
        if let titleImage = info.titleImage {
            self.imageView.image = titleImage.image
            self.imageView.tintColor = info.style.buttonImageTintColor
            self.imageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
            self.imageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
            self.stackView.addArrangedSubview(self.imageView)
        }
        self.label.configureText(withKey: info.titleKey, andConfiguration: info.titleConfiguration)
        self.label.textColor = info.style.titleTextColor
        self.stackView.addArrangedSubview(self.label)
        if let action = info.tooltipAction {
            self.action = action
            self.tooltipImageView.tintColor = info.style.buttonImageTintColor
            self.tooltipImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            self.tooltipImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            self.stackView.addArrangedSubview(self.tooltipImageView)
            self.tooltipImageView.accessibilityLabel = localized("voiceover_helpInformation")
            self.tooltipImageView.accessibilityTraits = .button
            self.tooltipImageView.isAccessibilityElement = true
        }
    }

    func setAccessibilityIdentifiers() {
        self.imageView.accessibilityIdentifier = self.viewModel?.titleImage?.accessibilityIdentifier
        self.label.accessibilityIdentifier = self.viewModel?.titleKey
        self.tooltipImageView.accessibilityIdentifier = "icnInfoRedLight"
    }
    
    func setAccessibilityInfo() {
        self.isAccessibilityElement = true
        self.isUserInteractionEnabled = false
        self.label.isAccessibilityElement = true
        self.label.accessibilityLabel = localized(self.viewModel?.accessibilityLabelKey ?? "")
        self.label.accessibilityValue = self.viewModel?.accessibilityValue
        self.label.accessibilityHint = self.viewModel?.accessibilityHint
        self.label.accessibilityTraits = .header
        self.imageView.isAccessibilityElement = self.viewModel?.titleImage != nil
        self.tooltipImageView.isAccessibilityElement = self.viewModel?.tooltipAction != nil
        self.tooltipImageView.accessibilityLabel = localized(self.viewModel?.tooltipAccessibilityLabelKey ?? "")
        self.tooltipImageView.accessibilityTraits = .button
        self.stackView.isAccessibilityElement = false
        self.accessibilityElements = [self.imageView ,self.label, self.tooltipImageView].compactMap{$0}
    }
}

extension TitleView: ToolTipButtonDeRigueur {    
    var tooltip: UIView? {
        return tooltipImageView
    }
    
    var xCorrectionPadding: CGFloat {
        return 4
    }
}

extension TitleView: AccessibilityCapable {}
