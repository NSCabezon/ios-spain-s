import UIKit
import UI

class TabControlView: UIView {
    
    var selectedOption = 0 {
        didSet {
            setSelectedPosition(selectedOption, animated: true)
            didSelect?(selectedOption)
        }
    }
    var didSelect: ((Int) -> Void)?
    private var centerConstraint: NSLayoutConstraint?
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 1.0
        
        return stackView
    }()
    private lazy var selectIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .sanRed
        
        return view
    }()
    private lazy var bottomSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lisboaGray
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(bottomSeparator)
        bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0).isActive = true
        bottomSeparator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bottomSeparator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottomSeparator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        addSubview(selectIndicatorView)
        selectIndicatorView.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
        selectIndicatorView.bottomAnchor.constraint(equalTo: bottomSeparator.topAnchor).isActive = true
        
        selectIndicatorView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 5.0).isActive = true
    }
    
    func setOptions(_ options: [LocalizedStylableText]) {
        let optionsWithImage: [(String?, LocalizedStylableText)] = options.map { (nil, $0) }
        setOptions(optionsWithImage)
    }
    
    func setOptions(_ options: [(String?, LocalizedStylableText)]) {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
        }
        for (index, option) in options.enumerated() {
            let button = ButtonView()
            button.setTitle(option.1, for: .normal)
            button.setImageKey(option.0)
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            button.tag = index
            if index == 0 {
                selectIndicatorView.widthAnchor.constraint(equalTo: button.widthAnchor).isActive = true
                centerConstraint = selectIndicatorView.centerXAnchor.constraint(equalTo: button.centerXAnchor)
                centerConstraint?.isActive = true
                button.isSeparatorHidden = true
            }
        }
        setSelectedPosition(0, animated: false)
    }
    
    func setSelectedPosition(_ position: Int, animated: Bool = true) {
        let selectedView = stackView.arrangedSubviews[selectedOption]
        layoutIfNeeded()
        centerConstraint?.isActive = false
        centerConstraint = selectIndicatorView.centerXAnchor.constraint(equalTo: selectedView.centerXAnchor)
        centerConstraint?.isActive = true
        
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            (view as? ButtonView)?.setSelected(index == position)
        }
        
        guard animated else { return }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    @objc func buttonPressed(_ view: UIView) {
        selectedOption = view.tag
    }
    
}

extension TabControlView {
    
    class ButtonView: CoachmarkBaseUIView {
        
        private lazy var separator: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .sanGreyMedium
            
            return view
        }()
        
        private lazy var button: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.numberOfLines = 0
            button.setContentHuggingPriority(.defaultHigh, for: .vertical)
            
            return button
        }()
        
        private lazy var imageButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setContentCompressionResistancePriority(.required, for: .vertical)

            return button
        }()
        
        private lazy var stackView: UIStackView = {
            let stack = UIStackView()
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.alignment = .fill
            stack.axis = .vertical
            
            return stack
        }()
        
        override var tag: Int {
            didSet {
                button.tag = tag
                imageButton.tag = tag
            }
        }
        
        var isSeparatorHidden: Bool {
            get {
                return separator.isHidden
            }
            set {
                separator.isHidden = newValue
            }
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
            addSubview(separator)
            separator.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
            separator.leftAnchor.constraint(equalTo: leftAnchor, constant: -1).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
            separator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            addSubview(stackView)
            stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
            stackView.leftAnchor.constraint(equalTo: separator.rightAnchor).isActive = true
            
            stackView.addArrangedSubview(imageButton)
            stackView.addArrangedSubview(button)
        }
        
        func setSelected(_ isSelected: Bool) {
            let fontColor: UIColor = isSelected ? .sanGreyDark : .sanGreyMedium
            let imageColor: UIColor = isSelected ? .sanRed : .sanGreyMedium
            let font: UIFont = isSelected ? .latoBold(size: 13.0) : .latoRegular(size: 13.0)
            button.applyStyle(ButtonStylist(textColor: fontColor, font: font))
            imageButton.tintColor = imageColor
        }
        
        func setTitle(_ title: LocalizedStylableText, for state: UIControl.State) {
            button.set(localizedStylableText: title, state: state)
        }
        
        func setImageKey(_ key: String?) {
            guard let key = key else {
                imageButton.isHidden = true
                return
            }
            let image = Assets.image(named: key)?.withRenderingMode(.alwaysTemplate)
            imageButton.setImage(image, for: .normal)
        }
        
        func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
            button.addTarget(target, action: action, for: controlEvents)
            imageButton.addTarget(target, action: action, for: controlEvents)
        }
    }
}
