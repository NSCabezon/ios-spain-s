import UI
import CoreFoundationLib
import Operative
import ESUI

protocol BizumDonationAmountViewProtocol: OperativeView, PhotoHelperDelegate, ValidatableFormViewProtocol {
    func showAccountHeader(_ viewModel: SelectAccountHeaderViewModel)
    func showDestination(_ viewModel: BizumDonationAmountDestinationViewModel)
    func showSimpleSendMoney(_ viewModel: BizumSimpleAmountViewModel)
    func showMultimediaView(_ model: BizumMultimediaViewModel)
    func showOptionsToAddImage(onCamera: @escaping () -> Void, onGallery: @escaping () -> Void)
    func showErrorMessage(onAccept: @escaping () -> Void)
    func showAmountError(_ error: String)
    func hideAmountError()
    func updateDestinationVisibility(_ isDetailed: Bool)
}

final class BizumDonationAmountViewController: UIViewController {
    var associatedScrollView: UIScrollView? { return self.scrollView }
    let keyboardManager: KeyboardManager = KeyboardManager()
    let presenter: BizumDonationAmountPresenterProtocol
    private var sendMoneyViewProtocol: SendingInformationBizumDelegate?

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var footerContainerView: UIView!
    @IBOutlet private weak var separatorView: UIView! {
        didSet {
            self.separatorView.backgroundColor = .mediumSkyGray
        }
    }
    @IBOutlet private weak var destinationImage: UIImageView! {
        didSet {
            self.destinationImage.contentMode = .center
        }
    }
    @IBOutlet private weak var initialLabel: UILabel! {
        didSet {
            self.initialLabel.textColor = .white
            self.initialLabel.font = .santander(family: .text, type: .bold, size: 15)
        }
    }

    @IBOutlet private weak var destinationLabel: UILabel! {
        didSet {
            self.destinationLabel.textColor = .brownishGray
            self.destinationLabel.font = .santander(family: .text, type: .regular, size: 16)
        }
    }
    @IBOutlet private weak var detailedDestinationTopLabel: UILabel! {
        didSet {
            self.detailedDestinationTopLabel.textColor = .lisboaGray
            self.detailedDestinationTopLabel.font = .santander(family: .text, type: .bold, size: 16)
            self.detailedDestinationTopLabel.numberOfLines = 2
            self.detailedDestinationTopLabel.lineBreakMode = .byTruncatingTail
        }
    }
    @IBOutlet private weak var detailedDestinationBottomLabel: UILabel! {
        didSet {
            self.detailedDestinationBottomLabel.textColor = .brownishGray
            self.detailedDestinationBottomLabel.font = .santander(family: .text, type: .regular, size: 16)
        }
    }
    @IBOutlet private weak var selectedAccount: SelectAccountHeaderView! {
        didSet {
            self.selectedAccount.backgroundColor = .skyGray
        }
    }
    @IBOutlet private weak var continueButton: WhiteLisboaButton! {
        didSet {
            self.continueButton.setIsEnabled(false)
            self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
            self.continueButton.addSelectorAction(target: self, #selector(didSelectContinue))
        }
    }
    init(nibName nibNameOrNil: String?, presenter: BizumDonationAmountPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: .module)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.keyboardManager.setDelegate(self)
        self.configureView()
        self.setupNavigationBar()
        self.presenter.viewDidLoad()
        self.setAccessibilityIdentifiers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.keyboardManager.update()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.operativeViewWillDisappear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sendMoneyViewProtocol?.setAmountFocused()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.restoreProgressBar()
    }
    
    func setAccessibilityIdentifiers() {
        self.continueButton.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumBtnContinue
        self.destinationImage.accessibilityIdentifier = AccessibilityBizumDonation.donationAmountViewControllerDestinationImage
        self.destinationLabel.accessibilityIdentifier = AccessibilityBizumDonation.donationAmountViewControllerDestinationLabel
        self.initialLabel.accessibilityIdentifier = AccessibilityBizumDonation.donationAmountViewControllerDestinationLabel
    }
}

private extension BizumDonationAmountViewController {
    func configureView() {
        self.scrollView.delegate = self
        self.footerContainerView.addShadow(location: .bottom, color: .clear, opacity: 0.7, height: 0.5)
    }

    func setupNavigationBar() {
        let titleImage = TitleImage(image: ESAssets.image(named: "icnBizumHeader"),
                                    topMargin: 4,
                                    width: 16,
                                    height: 16)
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeaderAndImage(titleKey: "toolbar_title_amount",
                                            header: .title(key: "toolbar_title_bizum", style: .default),
                                            image: titleImage)
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(didSelectClose))
        )
        builder.build(on: self, with: nil)
    }

    @objc func didSelectContinue() {
        self.view.resignFirstResponder()
        self.presenter.updateConcept(sendMoneyViewProtocol?.getConcept() ?? "")
        self.presenter.didSelectContinue()
    }
    
    private func didSelectContinueTextfield(_ textfield: EditText) {
        self.didSelectContinue()
    }

    @objc func didSelectClose() {
        self.presenter.didSelectClose()
    }
}
extension BizumDonationAmountViewController: BizumDonationAmountViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        return presenter
    }
    var viewForPresentation: UIViewController? {
        return self
    }
    
    func showAccountHeader(_ viewModel: SelectAccountHeaderViewModel) {
        self.selectedAccount.setup(with: viewModel)
    }

    func showDestination(_ viewModel: BizumDonationAmountDestinationViewModel) {
        self.destinationImage.image = nil
        self.destinationImage.clipsToBounds = true
        self.destinationImage.contentMode = .scaleAspectFit
        self.destinationLabel.text = viewModel.alias
        self.detailedDestinationTopLabel.text = viewModel.alias
        self.detailedDestinationBottomLabel.text = viewModel.identifier.replacingOccurrences(of: organizationCodePrefix, with: "")
        guard let iconUrl = viewModel.iconUrl else {
            self.setInitialsAvatar(viewModel)
            return
        }
        self.destinationImage.loadImage(urlString: iconUrl) { [weak self] in
            guard self?.destinationImage.image == nil else { return }
            self?.setInitialsAvatar(viewModel)
        }
    }
    
    func setInitialsAvatar(_ viewModel: BizumDonationAmountDestinationViewModel) {
        self.destinationImage.backgroundColor = viewModel.avatarColor
        self.destinationImage.roundCorners(corners: .allCorners, radius: destinationImage.frame.height / 2)
        self.initialLabel.text = viewModel.avatarName
    }

    func showSimpleSendMoney(_ viewModel: BizumSimpleAmountViewModel) {
        let sendMoneyView = BizumSimpleAmountView()
        sendMoneyView.presenter = presenter
        sendMoneyView.updatableSendingMoneyDelegate = self
        viewModel.updateView(view: sendMoneyView)
        self.sendMoneyViewProtocol = sendMoneyView
        self.stackView.addArrangedSubview(sendMoneyView)
    }

    func showOptionsToAddImage(onCamera: @escaping () -> Void, onGallery: @escaping () -> Void) {
        let absoluteMargin: (left: CGFloat, right: CGFloat) = (left: 19.0, right: 9.0)
        let components: [LisboaDialogItem] = [
            .margin(36.0),
            .styledText(LisboaDialogTextItem(text: localized("customizeAvatar_popup_title_select"),
                                             font: .santander(family: .text, type: .regular, size: 22),
                                             color: .lisboaGray,
                                             alignament: .center,
                                             margins: absoluteMargin)),
            .margin(16.0),
            .styledText(LisboaDialogTextItem(text: localized("customizeAvatar_popup_text_select"),
                                             font: .santander(family: .text, type: .regular, size: 16),
                                             color: .lisboaGray,
                                             alignament: .center,
                                             margins: absoluteMargin)),
            .margin(22.0),
            .horizontalActions(HorizontalLisboaDialogActions(left: LisboaDialogAction(title: localized("customizeAvatar_button_photos"),
                                                                                      type: .white,
                                                                                      margins: absoluteMargin,
                                                                                      action: onGallery),
                                                             right: LisboaDialogAction(title: localized("customizeAvatar_button_camera"),
                                                                                       type: .red,
                                                                                       margins: absoluteMargin,
                                                                                       action: onCamera))),
            .margin(24.0)
        ]
        let builder = LisboaDialog(items: components, closeButtonAvailable: true)
        builder.showIn(self)
    }

    func selectedImage(image: Data) {
        self.presenter.selectedImage(image: image)
    }
    
    func showErrorMessage(onAccept: @escaping () -> Void) {
        let absoluteMargin: (left: CGFloat, right: CGFloat) = (left: 19.0, right: 19.0)
        let components: [LisboaDialogItem] = [
            .margin(36.0),
            .styledText(LisboaDialogTextItem(text: localized("bizum_alert_request"),
                                             font: .santander(family: .headline, type: .regular, size: 22),
                                             color: .lisboaGray,
                                             alignament: .center,
                                             margins: absoluteMargin)),
            .margin(16.0),
            .styledText(LisboaDialogTextItem(text: localized("bizum_alert_join"),
                                             font: .santander(family: .text, type: .regular, size: 16),
                                             color: .lisboaGray,
                                             alignament: .center,
                                             margins: absoluteMargin)),
            .margin(8.0),
            .horizontalActions(HorizontalLisboaDialogActions(left: LisboaDialogAction(title: localized("generic_button_cancel"),
                                                                                      type: .white,
                                                                                      margins: absoluteMargin,
                                                                                      isCancelAction: true,
                                                                                      action: { }),
                                                             right: LisboaDialogAction(title: localized("generic_button_accept"),
                                                                                       type: .red,
                                                                                       margins: absoluteMargin,
                                                                                       action: onAccept))),
            .margin(8.0)
        ]

        let builder = LisboaDialog(items: components, closeButtonAvailable: false)
        builder.showIn(self)
    }
    
    func showError(error: PhotoHelperError) {
        let keyDesc: String
        switch error {
        case .noPermissionCamera:
            keyDesc = "permissionsAlert_text_camera"
        case .noPermissionPhotoLibrary:
            keyDesc = "permissionsAlert_text_photos"
        }
        self.showRequestGalleryAccess(keyDesc)
    }

    func showAmountError(_ error: String) {
        self.sendMoneyViewProtocol?.showAmountError(error)
    }

    func hideAmountError() {
        self.sendMoneyViewProtocol?.hideAmountError()
    }

    func updateDestinationVisibility(_ isDetailed: Bool) {
        self.detailedDestinationTopLabel.isHidden = !isDetailed
        self.detailedDestinationBottomLabel.isHidden = !isDetailed
        self.destinationLabel.isHidden = isDetailed
    }
    
    // MARK: ValidatableFormViewProtocol
    func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
        self.keyboardManager.setKeyboardButtonEnabled(enable)
    }
}

extension BizumDonationAmountViewController: SystemSettingsNavigatable {}
extension BizumDonationAmountViewController: KeyboardManagerDelegate {
    var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("generic_button_continue"),
                                             accessibilityIdentifier: "",
                                             action: self.didSelectContinueTextfield,
                                             actionType: .continueAction)
    }

    var associatedView: UIView {
        return self.scrollView
    }
}

extension BizumDonationAmountViewController: BizumUpdatableSendingMoneyDelegate {
    func updateSendingAmount(_ amount: Decimal) {
        self.presenter.updateAmount(amount)
        self.hideAmountError()
    }
}

extension BizumDonationAmountViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.footerContainerView.layer.masksToBounds = false
        self.footerContainerView.layer.shadowColor =
            scrollView.contentOffset.y > 0.0 ? UIColor.black.withAlphaComponent(0.7).cgColor : UIColor.clear.cgColor
    }
}
