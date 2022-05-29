import UIKit
import OpenCombine
import CoreFoundationLib
import CoreDomain

class MiddleOptionsView: UIView {
    
    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 0
        
        return stack
    }()
    private let digitalProfileView = DigitalProfileView()
    private let userNameView = UserNameView()
    let isDigitalProfileEnabledSubject = PassthroughSubject<Bool, Never>()
    let percentageSubject = PassthroughSubject<Double, Never>()
    let nameSubject = PassthroughSubject<NameRepresentable, Never>()
    let tapSubject = PassthroughSubject<Void, Never>()
    private var anySubscriptions = Set<AnyCancellable>()
    
    private lazy var viewTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePersonalAreaTap(_:)))
        return tap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    func setVerticalViews(_ views: [UIView]) {
        containerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        views.forEach { containerStackView.addArrangedSubview($0) }
    }
    
    func hideDigitalProfile(isHidden: Bool) {
        digitalProfileView.isHidden = isHidden
    }
}

private extension MiddleOptionsView {
    func setupViews() {
        containerStackView.embedInto(container: self)
        setupDigitalProfileView()
        setupUserNameView()
        setVerticalViews([userNameView, digitalProfileView])
        setAccessibilityIdentifiers()
        self.addGestureRecognizer(self.viewTapGesture)
    }
    
    func setupDigitalProfileView() {
        digitalProfileView.setSubtitleWithKey("menu_label_digitalProfile")
        isDigitalProfileEnabledSubject.sink { [unowned self] isEnabled in
            self.hideDigitalProfile(isHidden: !isEnabled)
        }.store(in: &anySubscriptions)
        percentageSubject.sink { [unowned self] percentage in
            digitalProfileView.subject.send(percentage)
        }.store(in: &anySubscriptions)
    }
    
    func setupUserNameView() {
        userNameView.setIconImageKey("icnSetting")
        userNameView.setSubtitleWithKey("menu_label_personalArea")
        nameSubject.sink { [weak self] name in
            guard let self = self else { return }
            self.userNameView.subject.send(name)
        }.store(in: &anySubscriptions)
    }
    
    func setAccessibilityIdentifiers() {
        userNameView.accessibilityIdentifier = AccessibilitySideMenu.btnPersonalArea
        digitalProfileView.accessibilityIdentifier = AccessibilitySideMenu.btnDigitalProfile
    }
    
    @objc func handlePersonalAreaTap(_ sender: UITapGestureRecognizer) {
        tapSubject.send()
    }
}
