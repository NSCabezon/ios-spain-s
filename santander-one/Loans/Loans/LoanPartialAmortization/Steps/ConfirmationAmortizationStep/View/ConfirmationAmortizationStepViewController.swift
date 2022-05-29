import UI
import Operative
import CoreFoundationLib
import CoreDomain
import UIKit

public protocol ConfirmationAmortizationStepViewModifierProtocol: ConfirmationAmortizationStepViewProtocol {}

public protocol ConfirmationAmortizationStepViewProtocol: OperativeView {
    func loadView(_ viewModel: ConfirmationAmortizationViewModel?)
    func addContentView(_ view: UIView)
}

open class ConfirmationAmortizationStepViewController: UIViewController {
    public var presenter: ConfirmationAmortizationStepPresenterProtocol
    @IBOutlet private weak var continueButton: WhiteLisboaButton!
    @IBOutlet private weak var containerView: UIView!
    private var items: [ConfirmationItemViewModel] = []
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0.0
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        return stack
    }()
    
    public lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(with: containerView)
        view.setScrollInsets(UIEdgeInsets(top: 0.0, left: 0.0, bottom: 8.0, right: 0.0))
        view.setSpacing(0.0)
        return view
    }()
    
    public init(presenter: ConfirmationAmortizationStepPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "\(ConfirmationAmortizationStepViewController.self)", bundle: Bundle.module)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.presenter.viewDidLoad()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.presenter.viewWillAppear()
    }
}

private extension ConfirmationAmortizationStepViewController {
    func setupView() {
        self.setupButtons()
        self.setupStackView()
    }
    
    func setupNavigationBar() {
        self.view.backgroundColor = .skyGray
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "genericToolbar_title_confirmation")
        )
        builder.setLeftAction(.back(action: #selector(didSelectBack)))
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(didSelectClose))
        )
        builder.build(on: self, with: nil)
    }
    
    @objc func didSelectClose() {
        self.presenter.didSelectClose()
    }
    
    @objc func didSelectBack() {
        self.presenter.didSelectBack()
    }
    
    func setupButtons() {
        self.continueButton.setTitle(localized("generic_button_confirm"), for: .normal)
        self.continueButton.addAction { [weak self] in
            self?.presenter.didSelectContinue()
        }
    }
    
    func setupStackView() {
        let container = stackView.embedIntoView(topMargin: 0, bottomMargin: 16, leftMargin: 16, rightMargin: 16)
        scrollableStackView.addArrangedSubview(container)
        scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollableStackView.widthAnchor.constraint(equalTo: container.widthAnchor)
        containerView.backgroundColor = .skyGray
    }
}

extension ConfirmationAmortizationStepViewController: ConfirmationAmortizationStepViewProtocol {
    public var operativePresenter: OperativeStepPresenterProtocol {
        presenter
    }
    
    public func loadView(_ viewModel: ConfirmationAmortizationViewModel?) {
        guard let viewModel = viewModel else { return }
        self.view.backgroundColor = .skyGray
        stackView.drawBorder(cornerRadius: 0, color: .mediumSkyGray, width: 1)
        self.build(viewModel)
    }
    
    func build(_ viewModel: ConfirmationAmortizationViewModel) {
        addAmount(viewModel.amountAmortized,
                  confirmationItemAction: ConfirmationItemAction(
                    title: localized("generic_edit_link"),
                    action: { self.presenter.modifyAmount() }))
        addLoanType(viewModel.loanTitle)
        addContractNumber(viewModel.contractNumber)
        addIbanAndTitular(viewModel.iban, titular: viewModel.contractHolder)
        addRegularAmount(viewModel.pendingCapitalTitle, amount: viewModel.pendingCapital)
        addItem(viewModel.expirationDateTitle, value: viewModel.expirationDate)
        addRegularAmount(viewModel.initialAmountTitle, amount: viewModel.initialLimit)
        addItem(viewModel.applyForTitle, value: viewModel.applyFor)
        addItem(viewModel.valueDateTitle, value: viewModel.valueDate)
        addRegularAmount(viewModel.liquidationAmountTitle, amount: viewModel.liquidationAmount, isLast: !viewModel.isNewMortgageLawLoan)
        if viewModel.isNewMortgageLawLoan {
            addRegularAmount(viewModel.finantialLossTitle, amount: viewModel.finantialLossAmount)
            addRegularAmount(viewModel.compensationTitle, amount: viewModel.compensationAmount)
            addRegularAmount(viewModel.insuranceFeeTitle, amount: viewModel.insuranceFeeAmount, isLast: true)
        }
        for item in self.items {
            let view = ConfirmationItemView()
            view.setup(with: item)
            stackView.addArrangedSubview(addMarginsToView(view))
        }
        addTotalView(viewModel.totalAmount)
        addExtraInfoView(viewModel.phone)
    }

    private func addMarginsToView(_ theView: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(theView)
        theView.fullFit(topMargin: 0, bottomMargin: 0, leftMargin: 0, rightMargin: 0)
        return container
    }
    
    func addAmount(_ amount: AmountRepresentable?, confirmationItemAction: ConfirmationItemAction? = nil) {
        guard let amount = amount else { return }
        let moneyDecorator = AmountRepresentableDecorator(amount, font: .santander(family: .text, type: .bold, size: 32), decimalFontSize: 18)
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_amortizationAmount"),
            value: moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: ""),
            position: .first,
            action: confirmationItemAction
        )
        self.items.append(item)
    }
    
    func addIbanAndTitular(_ iban: String?, titular: String) {
        let item = ConfirmationItemViewModel(title: localized("confirmation_item_holder"),
                                             value: titular,
                                             position: .unknown,
                                             info: NSAttributedString(string: iban ?? ""))
        self.items.append(item)
    }
    
    func addLoanType(_ loanType: String?) {
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_loan"),
            value: loanType?.capitalized ?? "",
            position: .unknown
        )
        self.items.append(item)
    }
    
    func addContractNumber(_ contractNumber: String?) {
        guard let contractNumber = contractNumber else { return }
        let title: LocalizedStylableText = localized("confirmation_item_contract")
        let item = ConfirmationItemViewModel(
            title: title,
            value: contractNumber,
            position: .unknown
        )
        self.items.append(item)
    }
    
    func addRegularAmount(_ title: String, amount: AmountRepresentable?, confirmationItemAction: ConfirmationItemAction? = nil, isLast: Bool = false) {
        guard let amount = amount else { return }
        let moneyDecorator = AmountRepresentableDecorator(amount, font: .santander(family: .text, type: .bold, size: 14), decimalFontSize: 14)
        let item = ConfirmationItemViewModel(
            title: localized(title),
            value: moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: ""),
            position: isLast ? .last : .unknown,
            action: confirmationItemAction
        )
        self.items.append(item)
    }
    
    func addItem(_ title: String, value: String) {
        let item = ConfirmationItemViewModel(
            title: localized(title),
            value: value,
            position: .unknown
        )
        self.items.append(item)
    }
    
    func addTotalView(_ totalAmount: NSAttributedString?) {
        let totalView = TotalAmountView()
        totalView.translatesAutoresizingMaskIntoConstraints = false
        totalView.configure(totalAmount)
        totalView.fullFit(topMargin: 0, bottomMargin: 15, leftMargin: 16, rightMargin: 16)
        stackView.addArrangedSubview(totalView)
    }

    func addExtraInfoView(_ phone: String?) {
        let extraInformationView = ExtraInformationView()
        extraInformationView.translatesAutoresizingMaskIntoConstraints = false
        extraInformationView.configure(phone)
        extraInformationView.fullFit(topMargin: 0, bottomMargin: 0, leftMargin: 16, rightMargin: 16)
        scrollableStackView.addArrangedSubview(extraInformationView)
    }
    
    public func addContentView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollableStackView.addArrangedSubview(view)
    }

    public func enableConfirmButton() {
        self.continueButton.setIsEnabled(true)
    }

    public func disableConfirmButton() {
        self.continueButton.setIsEnabled(false)
    }
}
