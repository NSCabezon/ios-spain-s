import UIKit
import CoreFoundationLib

final class DefaultActionButton: UIView {
    private var view: UIView!
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var imageIconWidth: NSLayoutConstraint!
    @IBOutlet private weak var imageIconHeight: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dragIcon: UIImageView!
    @IBOutlet private weak var backgroundImage: UIImageView!
    
    private var style: ActionButtonStyle = ActionButtonStyle.defaultStyleWithGrayBorder
    
    init(viewModel: DefaultActionButtonViewModel, isDragDisabled: Bool) {
        super.init(frame: .zero)
        self.setupView()
        setViewModel(viewModel, isDragDisabled: isDragDisabled)
    }
    
    init(viewModel: DefaultActionButtonWithBackgroundViewModel) {
        super.init(frame: .zero)
        self.setupView()
        setBackgroundViewModel(viewModel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

// MARK: - Private extension
private extension DefaultActionButton {
    func setupView() {
        self.xibSetup()
        self.applyEnabledStyle()
        self.setDragIcon()
        self.setAppearance(withStyle: self.style)
    }

    func xibSetup() {
        self.backgroundColor = .clear
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.backgroundColor = .clear
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }

    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func setViewModel(_ viewModel: DefaultActionButtonViewModel, isDragDisabled: Bool) {
        self.setTitle(viewModel.title)
        self.setImageIcon(viewModel.imageKey, viewModel.renderingMode)
        self.setBackgroundImage(nil)
        if !isDragDisabled {
            self.setAccessibility(viewModel)
        } else {
            self.titleLabel.isAccessibilityElement = false
        }
    }
    
    func setBackgroundViewModel(_ viewModel: DefaultActionButtonWithBackgroundViewModel) {
        self.setTitle(viewModel.title)
        self.setImageIcon(viewModel.imageKey, viewModel.renderingMode)
        self.setBackgroundImage(viewModel.backgroundKey)
        self.titleLabel.accessibilityIdentifier = viewModel.titleAccessibilityIdentifier
        self.imageIcon.isAccessibilityElement = true
        self.imageIcon.accessibilityIdentifier = viewModel.imageAccessibilityIdentifier
        self.setAccessibility(viewModel)
    }

    func setTitle(_ title: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineHeightMultiple = 0.70
        let text: String = localized(title)
        let builder = TextStylizer.Builder(fullText: text)
        self.titleLabel.attributedText = builder
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text).setStyle(UIFont.santander(size: 13.0)))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text).setParagraphStyle(paragraphStyle))
            .build()
        titleLabel.numberOfLines = 2
    }
    
    func setImageIcon(_ imageKey: String, _ renderingMode: UIImage.RenderingMode) {
        let image = Assets.image(named: imageKey)
        self.imageIcon.image = image?.withRenderingMode(renderingMode)
    }
    
    func setDragIcon() {
        self.dragIcon.image = Assets.image(named: "icnDrag")
        self.dragIcon.isHidden = true
    }
    
    func setBackgroundImage(_ imageKey: String?) {
        guard let imageKey = imageKey else { return self.backgroundImage.isHidden = true }
        backgroundImage.isHidden = false
        backgroundImage.image = Assets.image(named: imageKey)
    }
    
    func setAccessibility(_ viewModel: DefaultActionButtonViewModelProtocol) {
        self.titleLabel.accessibilityIdentifier = viewModel.titleAccessibilityIdentifier
        self.imageIcon.accessibilityIdentifier = viewModel.imageAccessibilityIdentifier
        self.view.isAccessibilityElement = false
        self.backgroundImage.isAccessibilityElement = false
        self.imageIcon.isAccessibilityElement = false
        self.titleLabel.isAccessibilityElement = true
        self.titleLabel.accessibilityTraits = .button
        self.titleLabel.accessibilityLabel = titleLabel.text
    }
}

extension DefaultActionButton: ActionButtonFillViewProtocol {
    func setAppearance(withStyle style: ActionButtonStyle) {
        self.style = style
        self.view.backgroundColor = .clear
        self.view.layer.cornerRadius = 5
        self.imageIcon.tintColor = style.imageTintColor
        self.backgroundImage.layer.cornerRadius = 5
        self.view.layer.borderColor = style.borderColor.cgColor
        self.titleLabel.textColor = style.textColor
        if let imageIconSize = style.imageIconSize {
            self.imageIconWidth.constant = imageIconSize.width
            self.imageIconHeight.constant = imageIconSize.height
        }
        if let textHeight = style.textHeight, let titleLabel = self.titleLabel {
            self.titleLabel.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: textHeight))
        }
        if let textFont = style.textFont {
            self.titleLabel.textFont = textFont
        }
    }
    
    func setDragIconVisibility(isHidden: Bool) {
        self.dragIcon.isHidden = isHidden
    }
    
    func applyDisabledStyle() {
        if style.textColor == ActionButtonStyle.defaultStyleWithGrayBorder.textColor {
            self.imageIcon.tintColor = UIColor.coolGray
            self.titleLabel.textColor = UIColor.coolGray
        } else {
            self.view.alpha = 0.6
        }
    }

    func applyEnabledStyle() {
        self.imageIcon.tintColor = style.imageTintColor
        self.titleLabel.textColor = style.textColor
    }
}
