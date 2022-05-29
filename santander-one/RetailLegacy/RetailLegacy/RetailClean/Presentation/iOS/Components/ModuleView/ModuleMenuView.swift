import UIKit

class ModuleMenuView: BaseHeader, ViewCreatable {
    
    private var containerStack: UIStackView? = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private var simpleOptionsView: SimpleOptionsView = {
        let view = SimpleOptionsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var mainOptionView: MainOptionView = {
        let view = MainOptionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var mainOptionHeightConstraint: NSLayoutConstraint?
    
    var mainOptionHeight = CGFloat(135) {
        didSet {
            mainOptionHeightConstraint?.constant = mainOptionHeight
        }
    }
    
    private var shadowViews = [UIView]()

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
        containerStack?.embedInto(container: self, insets: UIEdgeInsets(top: 16, left: 12, bottom: -16, right: -12))
        containerStack?.addArrangedSubview(mainOptionView)
        shadowViews.append(mainOptionView)
        let widthConstraint = mainOptionView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.52)
        widthConstraint.priority = .required
        widthConstraint.isActive = true
        mainOptionView.isHidden = true
        containerStack?.addArrangedSubview(simpleOptionsView)
        simpleOptionsView.isHidden = true
        mainOptionHeightConstraint = mainOptionView.heightAnchor.constraint(equalToConstant: mainOptionHeight)
        mainOptionHeightConstraint?.isActive = true
        backgroundColor = .uiBackground
    }
    
    // MARK: - public
    
    func setMainOption(_ option: ModuleMenuMainOptionType?) {
        mainOptionView.isHidden = option == nil
        guard let option = option else {
            return
        }
        mainOptionView.setMainOption(option)
    }
        
    func setSimpleOptionHeight(_ newHeight: CGFloat) {
        simpleOptionsView.simpleOptionHeight = newHeight
    }
    
    func addSimpleOption(_ option: ModuleMenuSimpleOptionType?) {
        simpleOptionsView.isHidden = option == nil
        guard let option = option else { return }
        simpleOptionsView.addSimpleOption(option)
    }
    
    func setSimpleOptions(_ options: [ModuleMenuSimpleOptionType]?) {
        containerStack?.alignment = options?.count == 1 ? .fill : .top
        simpleOptionsView.isHidden = options == nil
        guard let options = options else { return }
        simpleOptionsView.setSimpleOptions(options)
    }

    // MARK: - life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for v in shadowViews {
            v.drawRoundedAndShadowed()
        }
    }
}
