import UIKit
import UI
import Operative
import CoreFoundationLib

protocol BillEmittersManualPaymentViewProtocol: OperativeView {
    func showFields(_ fields: [FieldViewModelType])
    func showEditAccount(alias: String, amount: String)
    func showEmitterView(viewModel: EmitterSelectedViewModel)
    func updateContinueAction(_ enable: Bool)
    func showFaqs(_ items: [FaqsItemViewModel])
    func showErrors(_ errors: [FieldErrorViewModel])
}

class BillEmittersManualPaymentViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var headerContainerView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var continueButton: WhiteLisboaButton!

    // MARK: - Attributes
    
    let presenter: BillEmittersManualPaymentPresenterProtocol
    private let editAccountOperativeHeader = EditAccountOperativeHeader()
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setSpacing(13)
        view.setup(with: self.containerView)
        return view
    }()
    let keyboardManager = KeyboardManager()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: BillEmittersManualPaymentPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editAccountOperativeHeader.delegate = self
        self.headerContainerView.addSubview(self.editAccountOperativeHeader)
        self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
        self.continueButton.addSelectorAction(target: self, #selector(didSelectContinue))
        self.separatorView.backgroundColor = UIColor.mediumSkyGray
        self.setupNavigationBar()
        self.presenter.viewDidLoad()
        self.keyboardManager.setDelegate(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.keyboardManager.update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.operativeViewWillDisappear()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "toolbar_title_receipts",
                                    header: .title(key: "toolbar_title_paymentOther", style: .default))
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func didSelectContinue() {
        self.hideFieldErrors()
        let values = self.scrollableStackView
            .getArrangedSubviews()
            .compactMap({ ($0 as? BillEmittersManualPaymentFieldRetrievable)?.retrievedValue })
        self.presenter.didSelectContinue(withValues: values)
    }
    
    private func didSelectContinueTextfield(textfield: EditText) {
        self.didSelectContinue()
    }
    
    @objc private func faqs() {
        presenter.didTapFaqs()
    }
    
    @objc private func close() {
        presenter.didTapClose()
    }
}

extension BillEmittersManualPaymentViewController: EditAccountOperativeHeaderDelegate {
    
    func didSelectEditAccount() {
        self.presenter.didSelectChangeAccount()
    }
}

extension BillEmittersManualPaymentViewController: BillEmittersManualPaymentViewProtocol {
    
    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }
    
    func showEditAccount(alias: String, amount: String) {
        self.editAccountOperativeHeader.setViewModel(EditAccountViewModel(
            title: "generic_label_paymentAccount",
            subTitle: alias,
            amount: amount
        ))
    }
    
    func showEmitterView(viewModel: EmitterSelectedViewModel) {
        let emitterView = BillEmittersManualEmitterView(frame: .zero)
        emitterView.setup(viewModel: viewModel)
        emitterView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.addArrangedSubview(emitterView)
    }
    
    func showFields(_ fields: [FieldViewModelType]) {
        fields.forEach { field in
            let view: UIView
            switch field {
            case .field(let viewModel):
                let fieldView = BillEmittersManualPaymentFieldView(frame: .zero)
                fieldView.setupWithViewModel(viewModel)
                fieldView.textField.updatableDelegate = self
                presenter.fields.append(fieldView.textField)
                view = fieldView
            case .date(let date):
                let fieldView = BillEmittersManualPaymentDateFieldView(frame: .zero)
                fieldView.setupWithDate(date)
                presenter.fields.append(fieldView.textField)
                view = fieldView
            case .amount:
                let fieldView = BillEmittersManualPaymentAmountFieldView(frame: .zero)
                fieldView.textField.updatableDelegate = self
                presenter.fields.append(fieldView.textField)
                view = fieldView
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            self.scrollableStackView.addArrangedSubview(view)
        }
        self.keyboardManager.update()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
    
    func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
        self.keyboardManager.setKeyboardButtonEnabled(enable)
    }
    
    func hideFieldErrors() {
        self.scrollableStackView
            .getArrangedSubviews()
            .compactMap { $0 as? FieldErrorActionable }
            .forEach { $0.hideError() }
    }
    
    func showErrors(_ errors: [FieldErrorViewModel]) {
        self.scrollableStackView
            .getArrangedSubviews()
            .compactMap({ $0 as? FieldErrorActionable })
            .forEach { field in
                errors.forEach({ viewModel in
                    guard field.identifier == viewModel.identifier else { return }
                    field.showError(viewModel.error)
                })
        }
    }
}

extension BillEmittersManualPaymentViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension BillEmittersManualPaymentViewController: KeyboardManagerDelegate {
    
    var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("generic_button_continue"), accessibilityIdentifier: "billEmittersBtnContinue", action: self.didSelectContinueTextfield(textfield:))
    }
    
    var associatedScrollView: UIScrollView? {
        return self.scrollableStackView.scrollView
    }
}

extension BillEmittersManualPaymentViewController: UpdatableTextFieldDelegate {
    func updatableTextFieldDidUpdate() {
        self.presenter.validatableFieldChanged()
    }
}
