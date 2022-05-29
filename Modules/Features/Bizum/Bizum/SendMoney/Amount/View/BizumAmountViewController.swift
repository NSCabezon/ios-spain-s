import UIKit
import UI
import CoreFoundationLib
import Operative
import ESUI

protocol SendingInformationBizumDelegate: AnyObject {
    func getConcept() -> String?
    func showAmountError(_ error: String)
    func hideAmountError()
    func setAmountFocused()
}

protocol BizumUpdatableSendingMoneyDelegate: class {
    func updateSendingAmount(_ amount: Decimal)
}

protocol BizumSendMoneyViewProtocol: ValidatableFormViewProtocol, OperativeView, BizumAmountMultimediaViewProtocol {
    func showSimpleSendMoney(_ viewModel: BizumSimpleAmountViewModel)
    func showMultipleSendMoney(_ bizumOperativeType: BizumOperativeType, contacts: [BizumContactDetailModel], amount: Decimal?, concept: String?)
    func showBizumNonRegistered(onAccept: @escaping () -> Void, onCancel: @escaping () -> Void)
    func showAmountError(_ error: String)
    func hideAmountError()
    func showErrorMessage(key: String)
}

final class BizumAmountViewController: UIViewController {
    let presenter: BizumAmountPresenterProtocol
    let keyboardManager: KeyboardManager = KeyboardManager()
    var associatedScrollView: UIScrollView? { return self.scrollView }
    private var sendMoneyViewDelegate: SendingInformationBizumDelegate?

    @IBOutlet private weak var separatorView: UIView! {
        didSet {
            self.separatorView.backgroundColor = .mediumSkyGray
        }
    }
    @IBOutlet private weak var continueButton: WhiteLisboaButton! {
        didSet {
            self.continueButton.setIsEnabled(false)
            self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
            self.continueButton.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumBtnContinue
            self.continueButton.addSelectorAction(target: self, #selector(didSelectContinue))
        }
    }
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!

    init(nibName nibNameOrNil: String?, presenter: BizumAmountPresenterProtocol) {
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
        self.presenter.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.keyboardManager.update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.restoreProgressBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sendMoneyViewDelegate?.setAmountFocused()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }

    @objc func openSettings() {
         self.navigateToSettings()
     }
}

extension BizumAmountViewController: KeyboardManagerDelegate {
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

extension BizumAmountViewController: BizumSendMoneyViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        return presenter
    }

    func showSimpleSendMoney(_ viewModel: BizumSimpleAmountViewModel) {
        let sendMoneyView = BizumSimpleAmountView()
        sendMoneyView.presenter = presenter
        sendMoneyView.updatableSendingMoneyDelegate = self
        sendMoneyView.setViewModel(viewModel)
        self.sendMoneyViewDelegate = sendMoneyView
        self.stackView.addArrangedSubview(sendMoneyView)
        self.presenter.simpleViewShown()
    }

    func showMultipleSendMoney(_ bizumOperativeType: BizumOperativeType, contacts: [BizumContactDetailModel], amount: Decimal?, concept: String?) {
        let sendMoneyView = BizumMultipleAmountView()
        let viewModel = BizumMultipleAmountViewModel(bizumOperativeType: bizumOperativeType, contacts: contacts, amount: amount, concept: concept)
        viewModel.updatableSendingMoneyDelegate = self
        sendMoneyView.presenter = presenter
        viewModel.updateView(view: sendMoneyView)
        self.sendMoneyViewDelegate = sendMoneyView
        self.stackView.addArrangedSubview(sendMoneyView)
        self.presenter.multipleViewShown()
    }

    func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
        self.keyboardManager.setKeyboardButtonEnabled(enable)
    }

    func showBizumNonRegistered(onAccept: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let absoluteMargin: (left: CGFloat, right: CGFloat) = (left: 19.0, right: 9.0)
        let components: [LisboaDialogItem] = [
            .margin(36.0),
            .styledText(LisboaDialogTextItem(text: localized("bizum_alert_weCantNot"),
                                             font: .santander(family: .text, type: .regular, size: 22),
                                             color: .lisboaGray,
                                             alignament: .center,
                                             margins: absoluteMargin)),
            .margin(16.0),
            .styledText(LisboaDialogTextItem(text: localized("bizum_alert_notRegistered"),
                                             font: .santander(family: .text, type: .regular, size: 16),
                                             color: .lisboaGray,
                                             alignament: .center,
                                             margins: absoluteMargin)),
            .margin(22.0),
            .horizontalActions(HorizontalLisboaDialogActions(left: LisboaDialogAction(title: localized("generic_button_cancel"),
                                                                                      type: .white,
                                                                                      margins: absoluteMargin,
                                                                                      isCancelAction: true,
                                                                                      action: onCancel),
                                                             right: LisboaDialogAction(title: localized("generic_button_accept"),
                                                                                       type: .red,
                                                                                       margins: absoluteMargin,
                                                                                       action: onAccept))),
            .margin(24.0)
        ]

        let builder = LisboaDialog(items: components, closeButtonAvailable: false)
        builder.showIn(self)
    }

    func showErrorMessage(key: String) {
        self.showOldDialog(
             title: nil,
             description: localized(key),
             acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil),
             cancelAction: nil,
             isCloseOptionAvailable: false
         )
     }

    func showAmountError(_ error: String) {
        self.sendMoneyViewDelegate?.showAmountError(error)
    }

    func hideAmountError() {
        self.sendMoneyViewDelegate?.hideAmountError()
    }
}

private extension BizumAmountViewController {
    func configureView() {
        let tapView = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        self.view.addGestureRecognizer(tapView)
    }

    @objc func viewWasTapped() {
        self.resignFirstResponder()
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
            NavigationBarBuilder.RightAction.close(action: #selector(close))
        )
        builder.build(on: self, with: nil)
    }
    
    @objc func didSelectContinue() {
        if let concept = sendMoneyViewDelegate?.getConcept() {
            self.presenter.updateConcept(concept)
        }
        self.presenter.didSelectContinue()
    }
    
    private func didSelectContinueTextfield(_ textfield: EditText) {
        self.didSelectContinue()
    }

    @objc func close() {
        self.presenter.didTapClose()
    }
}

extension BizumAmountViewController: BizumUpdatableSendingMoneyDelegate {
    func updateSendingAmount(_ amount: Decimal) {
        self.presenter.updateSendingAmount(amount)
        self.hideAmountError()
    }
}

extension BizumAmountViewController: GenericErrorDialogPresentationCapable {
    var associatedGenericErrorDialogView: UIViewController {
        return self
    }
}
