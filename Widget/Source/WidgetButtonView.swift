import UIKit

final class WidgetButtonView: UIView {
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setContentHuggingPriority(.required, for: .vertical)
        return button
    }()
    
    private lazy var imageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 40.0).isActive = true
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 19.0
        stack.alignment = .fill
        stack.axis = .vertical
        return stack
    }()
    
    var titleTextSize: CGFloat = 12 {
        didSet {
            let font: UIFont = .latoRegular(size: titleTextSize)
            button.titleLabel?.font = font
        }
    }
    
    override var tag: Int {
        didSet {
            button.tag = tag
            imageButton.tag = tag
        }
    }
    
    private var fontColor: UIColor?
    
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
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 24).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        stackView.addArrangedSubview(imageButton)
        stackView.addArrangedSubview(button)
    }
    
    func setSelected(_ isSelected: Bool) {
        let imageColor: UIColor = isSelected ? .sanRed : .sanGreyMedium
        let font: UIFont = isSelected ? .latoBold(size: 13.0) : .latoRegular(size: 13.0)
        button.titleLabel?.font = font
        setColors()
        imageButton.tintColor = imageColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setColors()
    }
    
    func setTitle(_ title: String, for state: UIControl.State) {
        let font: UIFont = .latoRegular(size: titleTextSize)
        button.titleLabel?.font = font
        button.setTitle(title, for: state)
        setColors()
    }
    
    func setColors() {
        button.setTitleColor(fontColorTitleButton, for: .normal)
    }
    
    func setImageKey(_ key: String?) {
        imageButton.tintColor = .sanRed
        guard let key = key else {
            imageButton.isHidden = true
            return
        }
        let image = UIImage(named: key)?.withRenderingMode(.alwaysTemplate)
        imageButton.setImage(image, for: .normal)
    }
    
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        button.addTarget(target, action: action, for: controlEvents)
        imageButton.addTarget(target, action: action, for: controlEvents)
    }
}
