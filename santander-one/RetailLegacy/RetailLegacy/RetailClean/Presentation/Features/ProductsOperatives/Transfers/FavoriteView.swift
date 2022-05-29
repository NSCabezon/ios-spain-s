import UIKit
import CoreFoundationLib

class FavoriteView: UIView {
    
    let iconsBarView: IconsBarView = {
        let iconBarView = IconsBarView()
        iconBarView.translatesAutoresizingMaskIntoConstraints = false
        iconBarView.setContentHuggingPriority(.required, for: .vertical)
        return iconBarView
    }()
    
    let titleView: TitleAndSubtitleView = {
        let titleView = TitleAndSubtitleView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.setContentHuggingPriority(.required, for: .vertical)
        return titleView
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lisboaGray
        return view
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        return stack
    }()
    
    override func awakeFromNib() {
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(separatorView)
        stackView.addArrangedSubview(iconsBarView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawRoundedAndShadowed()
    }
    
    func setTitle(_ title: String) {
        titleView.setTitle(title)
    }
    
    func setSubtitle(_ subtitle: String) {
        titleView.setSubtitle(subtitle)
    }
    
    func setLeftIconAndTitle(_ title: String, icon: UIImage?) {
        iconsBarView.setLeftTitle(title)
        iconsBarView.setLeftImage(icon)
    }
    
    func setRightIconAndTitle(_ title: String, icon: UIImage?) {
        iconsBarView.setRightTitle(title)
        iconsBarView.setRightImage(icon)
    }
    
    func setTitleAsFieldTitle(_ displayAsField: Bool) {
        titleView.setTitleAsField(displayAsField)
    }
    
}

extension FavoriteView {
    class TitleAndSubtitleView: UIView {
        let titleLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setContentHuggingPriority(.required, for: .vertical)
            label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            label.numberOfLines = 2
            label.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16.0), textAlignment: .left))
            label.accessibilityIdentifier = AccessibilityEditFavorite.destinationStepLabelAliasTitle
            return label
        }()
        let subtitleLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setContentHuggingPriority(.required, for: .vertical)
            label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            label.numberOfLines = 2
            label.lineBreakMode = .byCharWrapping
            label.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 16.0), textAlignment: .left))
            label.accessibilityIdentifier = AccessibilityEditFavorite.destinationStepLabelAlias
            return label
        }()
        let stackView: UIStackView = {
            let stack = UIStackView()
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.setContentHuggingPriority(.required, for: .vertical)
            stack.spacing = 4
            stack.alignment = .fill
            stack.distribution = .fill
            stack.axis = .vertical
            return stack
        }()
        
        override func awakeFromNib() {
            setupView()
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupView()
        }
        
        private func setupView() {
            addSubview(stackView)
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(subtitleLabel)
            setupConstraints()
        }
        
        private func setupConstraints() {
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14).isActive = true
        }
        
        func setTitle(_ title: String) {
            titleLabel.text = title
        }
        
        func setSubtitle(_ subtitle: String) {
            subtitleLabel.text = subtitle
        }
        
        func setTitleAsField(_ isField: Bool) {
            let titleStyle = isField ? LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0), textAlignment: .left) : LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16.0), textAlignment: .left)
            let subtitleStyle = isField ? LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left): LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 16.0), textAlignment: .left)
            titleLabel.applyStyle(titleStyle)
            subtitleLabel.applyStyle(subtitleStyle)
        }
    }
    
}

extension FavoriteView {
    class IconsBarView: UIView {
        let leftLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0), textAlignment: .left))
            label.setContentHuggingPriority(.required, for: .vertical)
            label.accessibilityIdentifier = AccessibilityEditFavorite.destinationStepLabelCountryName
            return label
        }()
        let rightLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0), textAlignment: .left))
            label.setContentHuggingPriority(.required, for: .vertical)
            label.accessibilityIdentifier = AccessibilityEditFavorite.destinationStepLabelCurrencyName
            return label
        }()
        let leftIcon: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            return imageView
        }()
        let rightIcon: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            return imageView
        }()
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupView()
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupView()
        }
        
        private func setupView() {
            let leftGroup = buildStackView(withViews: [leftIcon, leftLabel])
            addSubview(leftGroup)
            let rightGroup = buildStackView(withViews: [rightIcon, rightLabel])
            addSubview(rightGroup)
            setupConstraints(leftView: leftGroup, rightView: rightGroup)
        }
        
        private func setupConstraints(leftView: UIView, rightView: UIView) {
            leftView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            leftView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            leftView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            leftView.rightAnchor.constraint(lessThanOrEqualTo: rightView.leftAnchor).isActive = true
            rightView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            rightView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            rightView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        private func buildStackView(withViews views: [UIView]) -> UIStackView {
            let stack = UIStackView(arrangedSubviews: views)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.alignment = .center
            stack.distribution = .fillProportionally
            stack.axis = .horizontal
            stack.setContentHuggingPriority(.required, for: .vertical)
            return stack
        }
        
        func setLeftTitle(_ title: String) {
            leftLabel.text = title
        }
        
        func setRightTitle(_ subtitle: String) {
            rightLabel.text = subtitle
        }
        
        func setLeftImage(_ image: UIImage?) {
            guard let image = image else { return }
            leftIcon.image = image
            leftIcon.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
            leftIcon.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
        }
        
        func setRightImage(_ image: UIImage?) {
            guard let image = image else { return }
            rightIcon.image = image
            rightIcon.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
            rightIcon.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
        }
    }
    
}
