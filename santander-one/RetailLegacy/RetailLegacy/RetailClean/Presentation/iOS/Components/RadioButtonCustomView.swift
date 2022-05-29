import UIKit

class RadioButtonCustomView: UIView {
    
    private lazy var radioOptionView: RadioOptionView = {
        let view = RadioOptionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var separatorView: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.sanGreyMedium.withAlphaComponent(0.25)
        return separator
    }()
    
    var radioBorderColor: UIColor {
        get {
            return radioOptionView.radioBorderColor
        }
        set {
            radioOptionView.radioBorderColor = newValue
        }
    }
    
    var radioCentralColor: UIColor {
        get {
            return radioOptionView.radioCentralColor
        }
        set {
            radioOptionView.radioCentralColor = newValue
        }
    }
    
    private var customView: SelectableCustomView?
    var isSeparatorVisible = true {
        didSet {
            separatorView.isHidden = !isSeparatorVisible
        }
    }
    var didSelect: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setCustomView(_ view: SelectableCustomView) {
        customView = view
        stackView.addArrangedSubview(view)
    }
    
    private func setupView() {
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.0).isActive = true
        stackView.addArrangedSubview(radioOptionView)
        radioOptionView.pressedAction = { [weak self] isOn in
            self?.customView?.isHidden = !isOn
            self?.didSelect?(isOn)
        }
        addSubview(separatorView)
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.leftAnchor.constraint(equalTo: stackView.leftAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: stackView.rightAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0.0).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0).isActive = true
    }
    
    func setTitle(_ title: String) {
        radioOptionView.setTitle(title)
    }
    
    func setSelected(_ isSelected: Bool) {
        radioOptionView.setSelected(isSelected)
        customView?.isHidden = !isSelected
        customView?.onSelection(isSelected: isSelected)
    }
    
    func setAccessibilityIdentifiers(identifier: String) {
        radioOptionView.setAccessibilityIdentifiers(identifier: identifier)
    }
}
