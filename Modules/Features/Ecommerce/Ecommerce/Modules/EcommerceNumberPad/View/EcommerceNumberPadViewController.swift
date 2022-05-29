import UI
import CoreFoundationLib
import ESCommons
import Foundation

protocol EcommerceNumberPadViewProtocol: class {
    func showToast(description: String)
}

final class EcommerceNumberPadViewController: UIViewController {
    @IBOutlet private weak var header: EcommerceHeaderView!
    @IBOutlet private weak var separatorAndTitleContainer: UIView!
    @IBOutlet private weak var separator: DashedLineView!
    @IBOutlet private weak var separatorWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var enterKeyLabel: UILabel!
    @IBOutlet private weak var ecommerceNumberPad: EcommerceNumberPadLoginView!
    @IBOutlet private weak var backToBiometryImageView: UIImageView!
    @IBOutlet private weak var backToBiometryLabel: UILabel!
    @IBOutlet private weak var recoverPasswordLabel: UILabel!
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var backToBiometryStackView: UIStackView!
    @IBOutlet private weak var footerMarginView: UIView!
    private let presenter: EcommerceNumberPadPresenterProtocol
    private var separatorWidthRate: CGFloat = 0.739
    private var separatorElementWidth: Int = 11
    
    init(presenter: EcommerceNumberPadPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "EcommerceNumberPadView", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        clearPassword()
        configureView()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        clearPassword()
        setPopGestureEnabled(false)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearPassword),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPopGestureEnabled(true)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension EcommerceNumberPadViewController: EcommerceNumberPadViewProtocol {
    func showToast(description: String) {
        Toast.show(description)
    }
}

private extension EcommerceNumberPadViewController {
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func configureView() {
        view.backgroundColor = .silverDark
        header.delegate = self
        footerMarginView.backgroundColor = .skyGray
        separatorAndTitleContainer.backgroundColor = .skyGray
        setSeparator()
        setEnterKeyLabel()
        footerView.backgroundColor = .skyGray
        recoverPasswordLabel.font = .santander(family: .text, type: .regular, size: 14)
        recoverPasswordLabel.textColor = .darkTorquoise
        recoverPasswordLabel.configureText(withKey: "login_button_retrieveKey")
        ecommerceNumberPad.delegate = self
        setBiometryLabels()
        setBiometryTap()
        setRecoveryPassTap()
        setAccessibilityIds()
    }
    
    func setEnterKeyLabel() {
        enterKeyLabel.font = .santander(family: .text, type: .regular, size: 20)
        enterKeyLabel.textColor = .black
        enterKeyLabel.textAlignment = .center
        enterKeyLabel.configureText(withKey: "ecommerce_title_enterPassword")
        enterKeyLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setSeparator() {
        separator.dashPattern = [9, 2]
        separator.strokeColor = .brownGray
        separator.backgroundColor = .skyGray
        let width = Int(separatorWidthRate * UIScreen.main.bounds.width)
        let remaining = width % separatorElementWidth
        separatorWidthConstraint.constant = CGFloat(width - remaining)
    }
    
    func setAccessibilityIds() {
        enterKeyLabel.accessibilityIdentifier = AccessibilityEcommerceNumberPadView.enterKeyLabel
        ecommerceNumberPad.accessibilityIdentifier = AccessibilityEcommerceNumberPadView.ecommerceNumberPadView
        backToBiometryLabel.accessibilityIdentifier = AccessibilityEcommerceNumberPadView.backToBiometryLabel
        backToBiometryImageView.accessibilityIdentifier = AccessibilityEcommerceNumberPadView.backToBiometryImageView
        recoverPasswordLabel.accessibilityIdentifier = AccessibilityEcommerceNumberPadView.recoverPasswordLabel
        footerView.accessibilityIdentifier = AccessibilityEcommerceNumberPadView.footerView
    }
    
    func setBiometryLabels() {
        backToBiometryLabel.textColor = .darkTorquoise
        backToBiometryLabel.font = .santander(family: .text, type: .bold, size: 16)
        backToBiometryLabel.configureText(withKey: "ecommerce_button_back")
        backToBiometryImageView.image = nil
    }
    
    func setBiometryTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(back))
        self.backToBiometryStackView.isUserInteractionEnabled = true
        self.backToBiometryStackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func back() {
        presenter.back()
    }
    
    func setRecoveryPassTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToRecoveryPass))
        self.recoverPasswordLabel.isUserInteractionEnabled = true
        self.recoverPasswordLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func goToRecoveryPass() {
        presenter.goToRecoveryPassword()
    }
    
    @objc func clearPassword() {
        ecommerceNumberPad.clear()
    }
}

extension EcommerceNumberPadViewController: DidTapInHeaderButtonsDelegate {
    func didTapInMoreInfo() {
        presenter.showMoreInfo()
    }
    
    func didTapInDismiss() {
        presenter.dismiss()
    }
}

extension EcommerceNumberPadViewController: EcommerceNumberPadLoginViewDelegate {
    func didTapOnOK(withMagic magic: String) {
        presenter.confirm(magic)
    }
}
