//
//  InternalTransferAmountViewController.swift
//  TransferOperatives
//
//  Created by Marcos Álvarez Mesa on 15/2/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import UIOneComponents
import CoreFoundationLib
import IQKeyboardManagerSwift
import CoreDomain
import Operative

final class InternalTransferAmountViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet weak var floatingButton: OneFloatingButton!
    @IBOutlet weak var floatingButtonConstraint: NSLayoutConstraint!

    // MARK: - Variables
    private let viewModel: InternalTransferAmountViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: InternalTransferAmountDependenciesResolver
    private let oneAccountsSelectedCardView = OneAccountsSelectedCardView()
    private let internalTransferDescriptionView = InternalTransferDescriptionView()
    private lazy var internalTransferAmountView: InternalTransferAmountView = {
        let defaultCurrency = CurrencyRepresented(currencyCode: defaultCurrency.rawValue)
        let amountView = InternalTransferAmountView(originCurrency: viewModel.operativeData.originAccount?.currencyRepresentable ?? defaultCurrency,
                                                    destinationCurrency: viewModel.operativeData.destinationAccount?.currencyRepresentable ?? defaultCurrency)
        return amountView
    }()
    private lazy var defaultCurrency: CurrencyType = NumberFormattingHandler.shared.getDefaultCurrency()
    private let internalTransferDateView = InternalTransferDateView(frame: .zero)
    private lazy var modifier: InternalTransferAmountModifierProtocol = self.dependencies.resolve()

    private struct Constants {
        static let maxCounterLabel: String = "140"
        static let daysForTransfersBetweenDefaultCurrencies = 365
        static let daysForTransfersBetweenForeignCurrancies = 60
    }

    // MARK: - Initializers
    init(dependencies: InternalTransferAmountDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "InternalTransferAmountViewController", bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Life cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        bind()
        configureSubviews()
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureKeyboardListener()
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
}

// MARK: - Subviews configuration
private extension InternalTransferAmountViewController {

    func configureSubviews() {
        stackView.spacing = 20
        configureTap()
        configureFloatingButton()
    }

    func configureTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }

    func configureFloatingButton() {
        let progress = viewModel.progress
        let subtitle = localized("sendMoney_button_confirmation",
                                 [StringPlaceholder(.number, String(progress.current + 1)),
                                  StringPlaceholder(.number, String(progress.total))])
        floatingButton.configureWith(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(title: localized("generic_button_continue"),
                                                               subtitle: subtitle.text,
                                                               icons: .right,
                                                               fullWidth: false)),
            status: .ready)
    }
}

// MARK: - Reactive functions
private extension InternalTransferAmountViewController {

    func bind() {
        bindViewModelLoad()
        bindViewModelExchangeRatesLoad()
        bindViewModelChangeAvailability()
        bindViewModelChangeReceiveAmount()
        bindViewModelChangeAmount()
        bindOneAccountsSelectedCardViewSelectOrigin()
        bindOneAccountsSelectedCardViewSelectDestination()
        bindInternalTransferDateViewSelectIssueDate()
        bindInternalTransferDateViewSelecteOneFilterSegment()
        bindInternalTransferDescriptionView()
        bindInternalTranferAmountViewChangeAmount()
        bindInternalTranferAmountViewChangeReceiveAmount()
        bindInternalTranferAmountViewReceiveAmountEndEditing()
        bindInternalTranferAmountViewAmountEndEditing()
        bindFloatingButtonTouch()
    }

    func bindViewModelLoad() {
        viewModel.state
            .case(InternalTransferAmountState.loaded)
            .sink { [weak self] loadedInformation in
                guard let self = self else { return }
                self.updateViewComponents(with: loadedInformation)
            }.store(in: &subscriptions)
    }

    func bindViewModelExchangeRatesLoad() {
        viewModel.state
            .case(InternalTransferAmountState.didUpdateExchangeInformation)
            .sink { [weak self] exchangeRatesInformation in
                guard let self = self else { return }
                self.updateAmountView(transferType: exchangeRatesInformation)
            }.store(in: &subscriptions)
    }
    
    func bindViewModelChangeAvailability() {
        viewModel.state
            .case(InternalTransferAmountState.didChangeAvailabilityToContinue)
            .map { available -> OneFloatingButton.ButtonState in
                return available ? .available : .disabled
            }
            .subscribe(floatingButton.buttonStateSubject)
            .store(in: &subscriptions)
    }

    func bindViewModelChangeReceiveAmount() {
        viewModel.state
            .case(InternalTransferAmountState.didChangeReceiveAmount)
            .sink { [weak self] amount in
                guard let self = self else { return }
                self.internalTransferAmountView.setReceiveAmount(amount)
            }.store(in: &subscriptions)
    }

    func bindViewModelChangeAmount() {
        viewModel.state
            .case(InternalTransferAmountState.didChangeAmount)
            .sink { [weak self] amount in
                guard let self = self else { return }
                self.internalTransferAmountView.setAmount(amount)
            }.store(in: &subscriptions)
    }

    func bindInternalTransferDescriptionView() {
        internalTransferDescriptionView.publisher
            .case(InternalTransferDescriptionViewState.descriptionDidChange)
            .sink { [weak self] text in
                guard let self = self else { return }
                self.viewModel.didSetInternalTransferPresentableType(.description(text))
            }.store(in: &subscriptions)
    }

    func bindInternalTranferAmountViewChangeAmount() {
        internalTransferAmountView.publisher
            .case(InternalTransferAmountViewState.didChangeAmount)
            .sink { [weak self] amount in
                guard let self = self else { return }
                self.viewModel.didSetInternalTransferPresentableType(.amount(self.internalTransferAmountView.getAmount()))
            }.store(in: &subscriptions)
    }

    func bindInternalTranferAmountViewChangeReceiveAmount() {
        internalTransferAmountView.publisher
            .case(InternalTransferAmountViewState.didChangeWillReceive)
            .sink { [weak self] amount in
                guard let self = self else { return }
                self.viewModel.didSetInternalTransferPresentableType(.receiveAmount(self.internalTransferAmountView.getReceiveAmount()))
            }.store(in: &subscriptions)
    }

    func bindInternalTranferAmountViewReceiveAmountEndEditing() {
        internalTransferAmountView.publisher
            .case(InternalTransferAmountViewState.didEndEditingWillReceive)
            .receive(on: Schedulers.main)
            .sink { [weak self] amount in
                guard let self = self else { return }
                self.viewModel.updateAmountsIfNecessary()
                if self.modifier.shoulFocusDescription && self.internalTransferAmountView.isAmountFirstResponder() == false {
                    _ = self.internalTransferDescriptionView.becomeFirstResponder()
                }
            }.store(in: &subscriptions)
    }
    
    func bindInternalTranferAmountViewAmountEndEditing() {
        internalTransferAmountView.publisher
            .case(InternalTransferAmountViewState.didEndEditingAmount)
            .receive(on: Schedulers.main)
            .sink { [weak self] amount in
                guard let self = self else { return }
                self.viewModel.updateAmountsIfNecessary()
                if self.modifier.shoulFocusDescription && self.internalTransferAmountView.isReceiveAmountFirstResponder() == false {
                    _ = self.internalTransferDescriptionView.becomeFirstResponder()
                }
            }.store(in: &subscriptions)
    }

    func bindInternalTransferDateViewSelectIssueDate() {
        internalTransferDateView.publisher
            .case(ReactiveInternalTransferDateViewState.didSelectIssueDate)
            .sink { [weak self] date in
                guard let self = self else { return }
                self.viewModel.didSetInternalTransferPresentableType(.issueDate(date))
            }.store(in: &subscriptions)
    }
    
    func bindInternalTransferDateViewSelecteOneFilterSegment() {
        internalTransferDateView.publisher
            .case(ReactiveInternalTransferDateViewState.didSelecteOneFilterSegment)
            .sink { [weak self] type in
                guard let self = self else { return }
                if type == .now {
                    self.viewModel.didSetInternalTransferPresentableType(.issueDate(Date()))
                }
            }.store(in: &subscriptions)
    }

    func bindOneAccountsSelectedCardViewSelectOrigin() {
        oneAccountsSelectedCardView.publisher
            .case(ReactiveOneAccountsSelectedState.didSelectOrigin)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.backToStep(.selectAccount)
            }.store(in: &subscriptions)
    }
    
    func bindOneAccountsSelectedCardViewSelectDestination() {
        oneAccountsSelectedCardView.publisher
            .case(ReactiveOneAccountsSelectedState.didSelectDestination)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.backToStep(.destinationAccount)
            }.store(in: &subscriptions)
    }
    
    func bindFloatingButtonTouch() {
        floatingButton.onTouchSubject
            .sink { [weak self] in
                guard let self = self else { return }
                self.floatingButtonDidPressed()
            }.store(in: &subscriptions)
    }
}

// MARK: - View configuration
private extension InternalTransferAmountViewController {

    func addSubviews() {
        addAccountSelector()
        addAmountView()
        addDescriptionView()
        addDateView()
    }

    func addAccountSelector() {
        let oneCardSelectedContainerView = UIView()
        oneCardSelectedContainerView.addSubview(oneAccountsSelectedCardView)
        oneAccountsSelectedCardView.fullFit(leftMargin: 16, rightMargin: 16)
        stackView.addArrangedSubview(oneCardSelectedContainerView)
    }

    func addAmountView() {
        let containerView = UIView()
        containerView.addSubview(internalTransferAmountView)
        internalTransferAmountView.fullFit(leftMargin: 16, rightMargin: 16)
        stackView.addArrangedSubview(containerView)
    }

    func addDescriptionView() {
        let containerView = UIView()
        containerView.addSubview(internalTransferDescriptionView)
        internalTransferDescriptionView.fullFit(leftMargin: 16, rightMargin: 16)
        internalTransferDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(containerView)
        let regularExpression = modifier.descriptionRegularExpression
        internalTransferDescriptionView.configureView(maxCounterLabel: Constants.maxCounterLabel,
                                                           regularExpression: regularExpression)
    }

    func addDateView() {
        let containerView = UIView()
        containerView.addSubview(internalTransferDateView)
        internalTransferDateView.translatesAutoresizingMaskIntoConstraints = false
        internalTransferDateView.fullFit()
        stackView.addArrangedSubview(containerView)
    }

    func updateViewComponents(with info: InternalTranferAmountLoadedInformation) {
        guard let ibanRepresentable = info.destinationAccount.ibanRepresentable,
              let availableAmount = info.destinationAccount.availableAmountRepresentable?.decoratedAmount,
              let alias = info.destinationAccount.alias
        else { return }
        let containsDefaultCurrency = self.viewModel.operativeData.containsCurrency(type: defaultCurrency)
        let viewModel = OneAccountsSelectedCardViewModel(
            statusCard: .expanded(
                OneAccountsSelectedCardExpandedViewModel(
                    destinationIban: ibanRepresentable,
                    destinationAlias: alias,
                    destinationCountry: availableAmount
                )
            ),
            originAccount: info.originAccount,
            originImage: nil,
            amountToShow: .available)

        oneAccountsSelectedCardView.setupAccountViewModel(viewModel)
        internalTransferAmountView.setAmount(info.amount)
        internalTransferAmountView.configureView(for: InternalTransferAmountViewTypeMapper.map(transferType: info.transferType))
        internalTransferDescriptionView.setDescription(info.description)
        updateDateView(with: info.issueDate, and: info.transferType, containsDefaultCurrency: containsDefaultCurrency)
    }

    func updateAmountView(transferType: InternalTransferType) {
        switch transferType {
        case .noExchange:
            return
        case .simpleExchange(sellExchange: let sellExchange):
            internalTransferAmountView.updateRatesInformation(buyRate: nil,
                                                              sellRate: InternalTransferType.exchangeRateString(exchangeType: sellExchange))
        case .doubleExchange(sellExchange: let sellExchange, buyExchange: let buyExchange):
            internalTransferAmountView.updateRatesInformation(buyRate: InternalTransferType.exchangeRateString(exchangeType: buyExchange),
                                                              sellRate: InternalTransferType.exchangeRateString(exchangeType: sellExchange))
        }
    }

    func updateDateView(with issueDate: Date?, and transferType: InternalTransferType, containsDefaultCurrency: Bool) {
        if case .noExchange = transferType {
            let selectionDateOneFilterViewModel = OneLabelViewModel(type: .normal, mainTextKey: "transfer_label_periodicity", accessibilitySuffix: AccessibilitySendMoneyAmount.periodicitySuffix)
            let selectedIndex = (issueDate?.isDayInToday() ?? true) ? 0 : 1
            let selectionDateViewModel = SelectionDateOneFilterViewModel(oneLabelViewModel: selectionDateOneFilterViewModel,
                                                                         options: ["sendMoney_tab_today", "sendMoney_tab_chooseDay"],
                                                                         selectedIndex: selectedIndex)
            let today = Date()
            let oldResolver: DependenciesResolver = dependencies.external.resolve()
            let issueDateViewModel = OneInputDateViewModel(dependenciesResolver: oldResolver,
                                                           status: .activated,
                                                           firstDate: issueDate,
                                                           placeholderKey: nil,
                                                           minDate: today,
                                                           maxDate: today.getDateByAdding(days: containsDefaultCurrency ? Constants.daysForTransfersBetweenDefaultCurrencies : Constants.daysForTransfersBetweenForeignCurrancies),
                                                           accessibilitySuffix: nil)
            internalTransferDateView.configureView(InternalTransferDateViewConfiguration(type: .allowDateSelection(selectionDateViewModel: selectionDateViewModel,
                                                                                                                   inputDateViewModel: issueDateViewModel)))
        } else {
            internalTransferDateView.configureView(InternalTransferDateViewConfiguration(type: .today))
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func floatingButtonDidPressed() {
        viewModel.next()
    }

    func configureKeyboardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        floatingButtonConstraint.constant = keyboardSize.cgRectValue.height * -1
        view.layoutSubviews()
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        floatingButtonConstraint.constant = 0
        view.layoutSubviews()
    }
}

extension InternalTransferAmountViewController: StepIdentifiable {}

// MARK: - AmountRepresentable extension
private extension AmountRepresentable {
    var decoratedAmount: String {
        return AmountRepresentableDecorator(self, font: UIFont.santander(size: 10)).getFormatedWithCurrencyName()?.string ?? ""
    }
}
