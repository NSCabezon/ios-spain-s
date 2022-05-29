import UIKit
import CoreFoundationLib
import UI

protocol SecureDeviceAliasViewProtocol: UIViewController {
     func configureView(model: SecureDeviceAliasViewModel)
}

struct SecureDeviceAliasViewModel {
    let device: String
    let alias: String?
    let date: Date
}

final class SecureDeviceAliasViewController: UIViewController {
    @IBOutlet private weak var headerSafeAreaView: UIView!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var imageHeader: UIImageView!
    @IBOutlet private weak var labelHeader: UILabel!
    @IBOutlet private weak var headerSeparator: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var infoView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleSeparator: UIView!
    @IBOutlet private weak var deviceInfoLabel: UILabel!
    @IBOutlet private weak var deviceLabel: UILabel!
    @IBOutlet private weak var deviceSepartor: DottedLineView!
    @IBOutlet private weak var aliasInfoLabel: UILabel!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var aliasSeparator: DottedLineView!
    @IBOutlet private weak var dateInfoLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var dateSeparator: DottedLineView!
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var footerSeaprator: UIView!
    @IBOutlet private weak var footerButton: WhiteLisboaButton!
    @IBOutlet private weak var footerSafeAreaView: UIView!
    
    var presenter: SecureDeviceAliasPresenterProtocol

    init(presenter: SecureDeviceAliasPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "SecureDeviceAliasViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    func setColors() {
        self.headerSafeAreaView.backgroundColor = UIColor.skyGray
        self.labelHeader.textColor = UIColor.lisboaGray
        self.titleLabel.textColor = UIColor.lisboaGray
        self.deviceInfoLabel.textColor = UIColor.lisboaGray
        self.deviceLabel.textColor = UIColor.lisboaGray
        self.aliasInfoLabel.textColor = UIColor.lisboaGray
        self.aliasLabel.textColor = UIColor.lisboaGray
        self.dateInfoLabel.textColor = UIColor.lisboaGray
        self.dateLabel.textColor = UIColor.lisboaGray
        self.view.backgroundColor = UIColor.skyGray
        self.scrollView.backgroundColor = UIColor.white
        self.headerView.backgroundColor = UIColor.skyGray
        self.headerSeparator.backgroundColor = UIColor.mediumSkyGray
        self.infoView.backgroundColor = UIColor.white
        self.titleSeparator.backgroundColor = UIColor.mediumSkyGray
        self.deviceSepartor.backgroundColor = UIColor.clear
        self.aliasSeparator.backgroundColor = UIColor.clear
        self.dateSeparator.backgroundColor = UIColor.clear
        self.deviceSepartor.strokeColor = UIColor.mediumSkyGray
        self.aliasSeparator.strokeColor = UIColor.mediumSkyGray
        self.dateSeparator.strokeColor = UIColor.mediumSkyGray
        self.footerView.backgroundColor = UIColor.white
        self.footerSeaprator.backgroundColor = UIColor.mediumSkyGray
        self.footerSafeAreaView.backgroundColor = UIColor.white
    }
    
    func setFonts() {
        self.labelHeader.font = .santander(family: .text, type: .light, size: 14.0)
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 18.0)
        self.deviceInfoLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        self.deviceLabel.font = UIFont.santander(family: .text, type: .light, size: 16.0)
        self.aliasLabel.font = UIFont.santander(family: .text, type: .light, size: 16.0)
        self.aliasInfoLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        self.dateInfoLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        self.dateLabel.font = UIFont.santander(family: .text, type: .light, size: 16.0)
    }
    
    func setTexts() {
        self.imageHeader.image = Assets.image(named: "icnSecurityRedBig")
        self.labelHeader.configureText(withKey: "otpPush_label_registeredDevice")
        self.titleLabel.configureText(withKey: "otpPush_label_titleRegisteredDevice")
        self.deviceInfoLabel.configureText(withKey: "deviceRegister_label_terminal")
        self.aliasInfoLabel.configureText(withKey: "deviceRegister_label_alias")
        self.dateInfoLabel.configureText(withKey: "deviceRegister_label_registrationDate")
        self.footerButton.setTitle(localized("otpPush_buttom_updateSecureDevice"), for: .normal)
    }
    
    private func configureView() {
        self.setColors()
        self.setFonts()
        self.setTexts()
        self.footerButton.addSelectorAction(target: self, #selector(continueDidPressed))
        self.setAccessibilityIdentifiers()
    }
    
    @objc private func continueDidPressed() { self.presenter.goToUpdate() }
    @objc private func backDidPressed() { self.presenter.backDidPressed() }
    @objc private func closeDidPressed() { self.presenter.closeDidPressed() }
}

extension SecureDeviceAliasViewController: SecureDeviceAliasViewProtocol {
    func configureView(model: SecureDeviceAliasViewModel) {
        self.aliasLabel.text = model.alias
        self.deviceLabel.text = model.device
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        self.dateLabel.text = formatter.string(from: model.date)
    }
}

private extension SecureDeviceAliasViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_secureDevice")
        )
        builder.setLeftAction(.back(action: #selector(backDidPressed)))
        builder.setRightActions(.close(action: #selector(closeDidPressed)))
        builder.build(on: self, with: nil)
    }
    
    func setAccessibilityIdentifiers() {
        self.imageHeader.accessibilityIdentifier = AccessibilitySecuritySectionPersonalArea.icnSecurityRedBig
        self.labelHeader.accessibilityIdentifier = AccessibilitySecureDeviceAlias.otpPushLabelRegisteredDevice
        self.titleLabel.accessibilityIdentifier = AccessibilitySecureDeviceAlias.otpPushLabelTitleRegisteredDevice
        self.deviceLabel.accessibilityIdentifier = AccessibilitySecureDeviceAlias.summaryItemTerminal
        self.deviceInfoLabel.accessibilityIdentifier = AccessibilitySecureDeviceAlias.summaryItemTerminalInfo
        self.aliasLabel.accessibilityIdentifier = AccessibilitySecureDeviceAlias.summaryItemAlias
        self.aliasInfoLabel.accessibilityIdentifier = AccessibilitySecureDeviceAlias.summaryItemAliasInfo
        self.dateLabel.accessibilityIdentifier = AccessibilitySecureDeviceAlias.summaryItemRegistrationDate
        self.dateInfoLabel.accessibilityIdentifier = AccessibilitySecureDeviceAlias.summaryItemRegistrationDateInfo
        self.footerButton.accessibilityIdentifier = AccessibilitySecureDeviceAlias.secureDeviceBtnUpdateSecurityDevice
        self.footerButton.titleLabel?.accessibilityIdentifier = AccessibilitySecureDeviceAlias.otpPushButtomUpdateSecureDevice
    }
}
