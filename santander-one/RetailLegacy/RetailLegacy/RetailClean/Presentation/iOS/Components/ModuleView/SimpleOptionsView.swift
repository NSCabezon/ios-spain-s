import UIKit
import UI

extension ModuleMenuView {
    
    class SimpleOptionsView: UIStackView {
        
        private var shadowViews = [UIView]()
        private var heightConstraints = [NSLayoutConstraint]()
        
        var simpleOptionHeight = CGFloat(62) {
            didSet {
                for constraint in heightConstraints {
                    constraint.constant = simpleOptionHeight
                }
            }
        }
        
        // MARK: - init
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setupView()
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.setupView()
        }
        
        private func setupView() {
            axis = .vertical
            spacing = 11
            distribution = .fillEqually
            alignment = .fill
        }
        
        // MARK: - public
        
        func addSimpleOption(_ option: ModuleMenuSimpleOptionType) {
            let simpleView = SimpleView()
            simpleView.translatesAutoresizingMaskIntoConstraints = false
            shadowViews.append(simpleView)
            let constraint = simpleView.heightAnchor.constraint(equalToConstant: simpleOptionHeight)
            constraint.isActive = true
            heightConstraints.append(constraint)
            simpleView.setOption(option)
            addArrangedSubview(simpleView)
        }
        
        func addSimpleSingleOption(_ option: ModuleMenuSimpleOptionType) {
            let simpleView = SimpleSingleView()
            simpleView.translatesAutoresizingMaskIntoConstraints = false
            shadowViews.append(simpleView)
            let constraint = simpleView.heightAnchor.constraint(equalToConstant: simpleOptionHeight)
            constraint.isActive = true
            heightConstraints.append(constraint)
            simpleView.setOption(option)
            addArrangedSubview(simpleView)
        }
        
        func setSimpleOptions(_ options: [ModuleMenuSimpleOptionType]) {
            for view in arrangedSubviews {
                removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            for option in options {
                if options.count == 1 {
                    addSimpleSingleOption(option)
                } else {
                    addSimpleOption(option)
                }
            }
        }
        
        // MARK: - life cycle
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            for v in shadowViews {
                v.drawRoundedAndShadowed()
            }
        }
    }
    
    class SimpleView: UIView, CoachmarkUIView {
        
        var coachmarkId: CoachmarkIdentifier?
        
        private lazy var button: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        private var executeAction: ModuleMenuExecutableOptionType?
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setupView()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.setupView()
        }
        
        private func setupView() {
            backgroundColor = .uiWhite
            addSubview(button)
            button.embedInto(container: self)
            button.titleLabel?.numberOfLines = 2
            button.applyStyle(ButtonStylist(textColor: .sanGreyDark, font: .latoMedium(size: 14.0)))
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            button.contentHorizontalAlignment = .left
        }
        
        func setOption(_ option: ModuleMenuSimpleOptionType) {
            button.setImage(Assets.image(named: option.imageKey), for: .normal)
            button.set(localizedStylableText: option.title, state: .normal)
            coachmarkId = option.coachmarkId
            executeAction = option
        }
        
        @objc func buttonPressed() {
            executeAction?.execute()
        }

    }
    
    class SimpleSingleView: UIView, CoachmarkUIView {
        
        var coachmarkId: CoachmarkIdentifier?
        
        private lazy var button: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        private lazy var label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoMedium(size: 14.0)))
            label.textAlignment = .center
            label.numberOfLines = 2
            label.isUserInteractionEnabled = false
            return label
        }()
        private lazy var imageView: UIImageView = {
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.isUserInteractionEnabled = false
            return image
        }()
        private lazy var contentGroup: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.isUserInteractionEnabled = false
            return view
        }()
        private var executeAction: ModuleMenuExecutableOptionType?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setupView()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.setupView()
        }
        
        private func setupView() {
            backgroundColor = .uiWhite
            addSubview(button)
            addSubview(contentGroup)
            button.embedInto(container: self)
            contentGroup.addSubview(label)
            contentGroup.addSubview(imageView)
            setupConstraints()
            button.applyStyle(ButtonStylist(textColor: .sanGreyDark, font: .latoMedium(size: 14.0)))
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            button.contentHorizontalAlignment = .left
        }
        
        private func setupConstraints() {
            imageView.topAnchor.constraint(equalTo: contentGroup.topAnchor, constant: 0.0).isActive = true
            imageView.centerXAnchor.constraint(equalTo: contentGroup.centerXAnchor, constant: 0.0).isActive = true
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8.0).isActive = true
            label.leftAnchor.constraint(greaterThanOrEqualTo: contentGroup.leftAnchor, constant: 0.0).isActive = true
            label.bottomAnchor.constraint(equalTo: contentGroup.bottomAnchor, constant: 0.0).isActive = true
            label.centerXAnchor.constraint(equalTo: contentGroup.centerXAnchor, constant: 0.0).isActive = true
            contentGroup.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0.0).isActive = true
            contentGroup.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.0).isActive = true
            contentGroup.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 8.0).isActive = true
            contentGroup.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8.0).isActive = true
        }
        
        func setOption(_ option: ModuleMenuSimpleOptionType) {
            imageView.image = Assets.image(named: option.imageKey)
            label.set(localizedStylableText: option.title)
            coachmarkId = option.coachmarkId
            executeAction = option
        }
        
        @objc func buttonPressed() {
            executeAction?.execute()
        }
        
    }
}
