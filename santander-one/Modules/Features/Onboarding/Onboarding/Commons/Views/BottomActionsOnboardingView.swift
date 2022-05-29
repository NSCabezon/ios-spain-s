import UIKit
import UI
import CoreFoundationLib
import OpenCombine

enum BottomActionsOnboardingAction {
    case back, next
}

public class BottomActionsOnboardingView: UIView {
    private let backButton = UIButton()
    private let continueButton = WhiteLisboaButton()
    private let finishButton = RedLisboaButton()
    private let topSeparatorView = UIView()
    private var actionSubject = PassthroughSubject<BottomActionsOnboardingAction, Never>()
    var action: AnyPublisher<BottomActionsOnboardingAction, Never>
    
    var continueText: LocalizedStylableText? {
        didSet {
            if let text = continueText {
                continueButton.set(localizedStylableText: text, state: .normal)
                finishButton.set(localizedStylableText: text, state: .normal)
                finishButton.titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }
    }
    var backText: LocalizedStylableText? {
        didSet {
            if let text = backText {
                backButton.set(localizedStylableText: text, state: .normal)
                backButton.adjustTextIntoButton()
            }
        }
    }    
    
    init() {
        self.action = actionSubject.eraseToAnyPublisher()
        super.init(frame: .zero)
        self.configView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupViews(_ isRed: Bool = false) {
        topSeparatorView.backgroundColor = .mediumSkyGray
        if isRed {
            continueButton.isHidden = true
        } else {
            finishButton.isHidden = true
        }
    }
  
    func setAccesibilityIdentifiers() {
        self.finishButton.accessibilityIdentifier = "onboardingBtnGlobalPosition"
        self.finishButton.titleLabel?.accessibilityIdentifier = "generic_button_globalPosition"
    }
        
    @objc func clickBackButton(_ sender: Any) {
        self.actionSubject.send(.back)
    }
    
    @objc func clickContinueButton(_ gesture: UITapGestureRecognizer) {
        self.actionSubject.send(.next)
    }
}

private extension BottomActionsOnboardingView {
    
    func configView() {
        addSubviews()
        configBackButton()
        configContinueButton()
        configFinishButton()
        setAccesibilityIdentifiers()
        configTopSeparator()
    }
    
    func addSubviews() {
        self.addSubview(backButton)
        self.addSubview(continueButton)
        self.addSubview(finishButton)
        self.addSubview(topSeparatorView)
    }
    
    func configTopSeparator() {
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            topSeparatorView.topAnchor.constraint(equalTo: self.topAnchor),
            topSeparatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
    }
    
    func configBackButton() {
        backButton.setImage(Assets.image(named: "icnArrowLeftRedNew"), for: .normal)
        backButton.tintColor = .santanderRed
        let styleButton = ButtonStylist(textColor: .santanderRed, font: .santander(family: .text, type: .regular, size: 14))
        backButton.applyStyle(styleButton)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        backButton.contentHorizontalAlignment = .left
        backButton.addTarget(self, action:#selector(clickBackButton(_:)), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            backButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 140)
        ])
    }
    
    func configContinueButton() {
        continueButton.addSelectorAction(target: self, #selector(clickContinueButton))
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 40),
            continueButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            continueButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])
    }
    
    func configFinishButton() {
        finishButton.addSelectorAction(target: self, #selector(clickContinueButton))
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            finishButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            finishButton.heightAnchor.constraint(equalToConstant: 40),
            finishButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            finishButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 130)
        ])
    }
}
