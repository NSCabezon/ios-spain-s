import UIKit
import CoreFoundationLib
import CoreDomain

protocol PrivateMenuOption {
    var title: LocalizedStylableText { get }
    var iconKey: String? { get }
    var imageURL: String? { get set }
    var action: () -> Void { get }
    var didUpdateImageURL: ((String) -> Void)? { get set }
    var coachmarkId: CoachmarkIdentifier? { get set }
}

class MenuOptionData: PrivateMenuOption, AccessibilityProtocol {
    var coachmarkId: CoachmarkIdentifier?
    var title: LocalizedStylableText
    var iconKey: String?
    var imageURL: String? {
        didSet {
            if let imageURL = imageURL {
                didUpdateImageURL?(imageURL)
            }
        }
    }
    var action: () -> Void
    var didUpdateImageURL: ((String) -> Void)?
	var accessibilityIdentifier: String?
    
	init(title: LocalizedStylableText, iconKey: String?, imageURL: String? = nil, coachmarkId: CoachmarkIdentifier? = nil, accessibilityIdentifier: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.iconKey = iconKey
        self.imageURL = imageURL
        self.action = action
        self.coachmarkId = coachmarkId
		self.accessibilityIdentifier = accessibilityIdentifier
    }
}

class PrivateUserHeader: UIView {
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        
        return stack
    }()
    
    private let leftView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        
        return view
    }()
    
    private let userInfoView: MiddleOptionsView = {
        let view = MiddleOptionsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let optionsBarView: OptionsBarView = {
        let view = OptionsBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var hasTopNotch: Bool {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        
        return false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        addSubview(containerStackView)
        addSubview(separatorView)
        separatorView.backgroundColor = .mediumSky
        containerStackView.addArrangedSubview(leftView)
        containerStackView.addArrangedSubview(userInfoView)
        containerStackView.addArrangedSubview(optionsBarView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        optionsBarView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        optionsBarView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        if #available(iOS 11.0, *) {
            containerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            containerStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }
        if hasTopNotch {
            containerStackView.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -12).isActive = true
        } else {
            containerStackView.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -2).isActive = true
        }
        containerStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        containerStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
    }
    
    func setOptions(_ options: [PrivateMenuOption]) {
        optionsBarView.setOptions(options)
    }
    
    func setLeftView(_ view: UIView) {
        for view in leftView.subviews {
            view.removeFromSuperview()
        }
        view.embedInto(container: leftView)
    }
    
    func setMiddleViews(_ views: [UIView]) {
        userInfoView.setVerticalViews(views)
    }
}
