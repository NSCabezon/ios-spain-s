import UIKit
import UI
import CoreFoundationLib

protocol CardBoardingGeolocationViewProtocol: CardBoardingStepView {
    func setGeolocationStateView(_ isLocationEnabled: Bool)
    func showActivationSuccessView()
}

class CardBoardingGeolocationViewController: UIViewController {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var topShadow: UIView!
    private let presenter: CardBoardingGeolocationPresenterProtocol
    var isFirstStep: Bool = false
    private let cardBoardingFooter = CardBoardingTabBar(frame: .zero)
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setup(with: self.containerView)
        view.backgroundColor = .clear
        view.setSpacing(16)
        return view
    }()
    private var headerView = CardBoardingGeolocationHeaderView()
    private var locationStateView = CardBoardingGeolocationStateView()
    private var activationSuccessView = CardBoardingActivationSuccessView()
    private var activationSuccessBottomConstraint: NSLayoutConstraint?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: CardBoardingGeolocationPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setAppareance()
        self.presenter.viewDidLoad()
        self.setScrollableStackView()
        self.addCardBoardingFooter()
        self.setActivationSuccessView()
        NotificationCenter.default
        .addObserver(self,
            selector: #selector(didViewBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.presenter.viewDidLayoutSubviews()
    }
}

private extension CardBoardingGeolocationViewController {
    func setScrollableStackView() {
        self.scrollableStackView.addArrangedSubview(self.headerView)
        self.scrollableStackView.addArrangedSubview(self.locationStateView)
        self.locationStateView.delegate = self
        self.scrollableStackView.scrollView.delegate = self
    }
    
    func setActivationSuccessView() {
        self.activationSuccessView.isHidden = true
        self.containerView.addSubview(self.activationSuccessView)
        self.activationSuccessView.setDescriptionText("cardBoarding_text_geolocationActivated")
        self.containerView.bringSubviewToFront(self.cardBoardingFooter)
        self.activationSuccessBottomConstraint = self.activationSuccessView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 0)
        self.activationSuccessBottomConstraint?.isActive = true
        NSLayoutConstraint.activate([
            self.activationSuccessView.heightAnchor.constraint(equalToConstant: 72),
            self.activationSuccessView.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: 0),
            self.activationSuccessView.rightAnchor.constraint(equalTo: self.containerView.rightAnchor, constant: 0)
        ])
    }
    
    func setNavigationBar() {
        let builder = NavigationBarBuilder(style: .white, title: .none)
        builder.build(on: self, with: nil)
    }
    
    func addCardBoardingFooter() {
        self.containerView.addSubview(self.cardBoardingFooter)
        self.cardBoardingFooter.backButton.isHidden = self.isFirstStep
        self.cardBoardingFooter.fitOnBottomWithHeight(72, andBottomSpace: 0)
        self.cardBoardingFooter.addBackAction(target: self, selector: #selector(didSelectBack))
        self.cardBoardingFooter.addNextAction(target: self, selector: #selector(didSelectNext))
    }
    
    @objc func didSelectBack() {
        self.presenter.didSelectBack()
    }
    
    @objc func didSelectNext() {
        self.presenter.didSelectNext()
    }
    
    @objc func didViewBecomeActive() {
        self.presenter.didViewBecomeActive()
    }
    
    func setAppareance() {
        self.view.applyGradientBackground(colors: [.white, .skyGray, .white], locations: [0.0, 0.9, 0.2])
        self.containerView.backgroundColor = .clear
        self.topShadow.backgroundColor = .white
        self.topShadow.addShadow(location: .bottom, color: .clear, opacity: 0.7, height: 0.5)
    }
}

extension CardBoardingGeolocationViewController: CardBoardingGeolocationViewProtocol {
    func setGeolocationStateView(_ isLocationEnabled: Bool) {
        self.locationStateView.setLocationState(isLocationEnabled)
    }
    
    func showActivationSuccessView() {
        self.activationSuccessView.isHidden = false
        self.activationSuccessBottomConstraint?.constant = -72
        UIView.animate(withDuration: 0.2) {
            self.containerView.layoutIfNeeded()
        } completion: { [weak self] completed in
            guard completed else { return }
            self?.activationSuccessBottomConstraint?.constant = 0
            UIView.animate(withDuration: 0.2, delay: 2) {
                self?.containerView.layoutIfNeeded()
            } completion: { [weak self] completed in
                guard completed else { return }
                self?.activationSuccessView.isHidden = true
            }
        }
    }
}

extension CardBoardingGeolocationViewController: CardBoardingGeolocationStateDelegate {
    func didSelectSwitchButton() {
        self.presenter.didGeolocationPermissionChange()
    }
}

extension CardBoardingGeolocationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topShadow.layer.shadowColor = scrollView.contentOffset.y > 0.0 ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
}
