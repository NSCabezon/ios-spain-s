import UIKit
import UI

class GenericLandingOptionView: UIView {
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santanderTextLight(size: 21.0)
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        label.numberOfLines = 2
        return label
    }()
    
    private let image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        return image
    }()
    
    private let topSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var action: (() -> Void)?
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        addSubview(label)
        addSubview(image)
        addSubview(topSeparator)
        addSubview(bottomSeparator)
        addSubview(button)
        
        topSeparator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        topSeparator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topSeparator.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topSeparator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topSeparator.backgroundColor = .lisboaGray
        bottomSeparator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomSeparator.backgroundColor = .lisboaGray
        bottomSeparator.isHidden = true
        
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 11.0).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 18.0).isActive = true
        image.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 8).isActive = true
        image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -11.0).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        button.embedInto(container: self)
        
        backgroundColor = .clear
    }
    
    func setupWith(_ option: GenericLandingPushOptionType) {
        label.configureText(withLocalizedString: option.title)
        image.image = Assets.image(named: option.imageKey)
        action = option.execute
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        action?()
    }
    
    func setAsLastOption(_ isLastOption: Bool) {
        bottomSeparator.isHidden = !isLastOption
    }
    
}
