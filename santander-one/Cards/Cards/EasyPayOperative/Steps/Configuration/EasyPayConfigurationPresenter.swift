//
//  EasyPayConfigurationPresenter.swift
//  Cards
//
//  Created by alvola on 02/12/2020.
//

import Operative
import CoreFoundationLib
import SANLegacyLibrary

protocol EasyPayConfigurationPresenterProtocol: OperativeStepPresenterProtocol {
    var view: EasyPayConfigurationViewProtocol? { get set }
    var minFees: Int { get }
    var maxFees: Int { get }
    var pressDelay: Double { get }
    func viewDidLoad()
    func close()
    func continuePressed()
    func slideToConfirmCompleted()
    func setCurrentFees(_ num: Int)
    func setTrackChangedFees()
}

private enum EasyPayConfigurationState: Equatable {
    case initial
    case loading
    case completed
    case completedWithError(String?)
}

final class EasyPayConfigurationPresenter {
    weak var view: EasyPayConfigurationViewProtocol?
    var number = 0
    var isBackButtonEnabled = true
    var isCancelButtonEnabled = true
    var container: OperativeContainerProtocol?
    private let dependenciesResolver: DependenciesResolver
    private lazy var operativeData: EasyPayOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    private var state: EasyPayConfigurationState = .initial {
        didSet {
            reloadView()
        }
    }
    private var currentFees: Int = 3
    let minFees = EasyPayConstants.minFees
    let maxFees = EasyPayConstants.maxFees
    let pressDelay = EasyPayConstants.pressDelay
    
    private var useCaseHandler: UseCaseHandler {
        return dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var localeManager: TimeManager {
        return dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension EasyPayConfigurationPresenter: EasyPayConfigurationPresenterProtocol {
    func viewDidLoad() {
        trackScreen()
        setMovementInfo()
        setOperativeDescription()
        setCurrentFeesNum()
        state = operativeData.easyPayAmortization == nil ? .initial : .loading
    }
    
    func close() {
        container?.close()
    }
    
    func trackEvent(_ action: EasyPayConfigurationPage.Action) {
        trackerManager.trackEvent(screenId: trackerPage.page,
                                  eventId: action.rawValue,
                                  extraParameters: [:])
    }
    
    func setCurrentFees(_ num: Int) {
        operativeData.easyPayCurrentFeeData = nil
        currentFees = num
        guard state != .initial, !existsError() else { return }
        validateEasyPay()
    }
    
    func setTrackChangedFees() {
        trackEvent(EasyPayConfigurationPage.Action.changeFees)
    }
    
    func continuePressed() {
        trackEvent(EasyPayConfigurationPage.Action.continueAction)
        validateEasyPay()
    }
    
    func slideToConfirmCompleted() {
        trackEvent(EasyPayConfigurationPage.Action.fractionateAction)
        guard let input = getConfirmEasyPayUseCaseInput() else { return }
        view?.showLoading()
        let usecase = dependenciesResolver.resolve(for: ConfirmEasyPayUseCase.self)
        Scenario(useCase: usecase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] _ in
                guard let self = self else { return }
                self.view?.dismissLoading(completion: {
                    self.container?.stepFinished(presenter: self)
                })
            }.onError { [weak self] error in
                self?.view?.dismissLoading(completion: {
                    self?.showGeneralError(error.getErrorDesc() ?? "")
                })
            }
    }
}

// MARK: - Private Methods

private extension EasyPayConfigurationPresenter {
    
    func validateEasyPay() {
        guard let input = getValidateEasyPayUseCaseInput() else { return }
        state = .loading
        getFirstFeeInfo()
        let usecase = dependenciesResolver.resolve(for: ValidateEasyPayUseCase.self)
        Scenario(useCase: usecase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess(handleValidationResponse)
            .onError(handleValidationError)
    }
    
    func handleValidationResponse(_ response: ValidateEasyPayUseCaseOkOutput) {
        operativeData.easyPayAmortization = response.easyPayAmortization
        container?.save(operativeData)
        createMonthlyFees()
        state = .completed
    }
    
    func handleValidationError(_ error: UseCaseError<StringErrorOutput>) {
        var errorWS: String?
        switch error {
        case .error(let error):
            let stringLoader: StringLoader = dependenciesResolver.resolve()
            errorWS = stringLoader.getWsErrorIfPresent(error?.getErrorDesc() ?? "")?.text
        case .networkUnavailable:
            errorWS = "generic_error_withoutConnection"
        case .generic, .intern, .unauthorized:
            errorWS = nil
        }
        state = .completedWithError(errorWS)
    }
    
    func reloadView() {
        view?.showContinue(state != .completed && state != .loading)
        view?.showCurrentFee((state == .completed || state == .loading) && operativeData.easyPayCurrentFeeData != nil)
        view?.showMonthlyFees(state == .completed && !(operativeData.easyPayAmortization?.amortizations ?? []).isEmpty)
        view?.showSlideToActive(state == .completed)
        view?.showLoading(state == .loading)
        view?.showSimpleError(true)
        if case .completedWithError(let error) = state {
            view?.showError(error)
        }
    }
    
    func setMovementInfo() {
        let timeManager = dependenciesResolver.resolve(for: TimeManager.self)
        let paidOff = operativeData.cardTransactionDetail?.soldOutDate
        let operationDate = operativeData.productSelected?.cardTransactionEntity.operationDate
        let operationHour = operativeData.cardTransactionDetail?.transactionDate ?? ""
        var decoratedAmount: NSAttributedString?
        if let amount = operativeData.productSelected?.cardTransactionEntity.amount {
            let money = MoneyDecorator(amount, font: UIFont.santander(type: .bold, size: 30.0), decimalFontSize: 24.0)
            decoratedAmount = money.getFormatedCurrency()
        }
        let movementViewModel = EasyPayHeaderMovementViewModel(
            movementName: operativeData.productSelected?.cardTransactionEntity.description?.camelCasedString ?? "",
            cardName: operativeData.productSelected?.cardEntity.alias?.camelCasedString ?? "",
            amount: decoratedAmount,
            operationDay: timeManager.toString(date: operationDate, outputFormat: .d_MMM_yyyy) ?? "",
            operationHour: timeManager.toString(input: operationHour, inputFormat: .HHmmssZ, outputFormat: .HHmm) ?? "",
            settleDay: timeManager.toString(date: paidOff, outputFormat: .d_MMM_yyyy) ?? ""
        )
        view?.setMovementInfo(movementViewModel)
    }
    
    func setCurrentFeesNum() {
        guard let num = operativeData.easyPayAmortization?.amortizations.count else { return }
        currentFees = num
        view?.setCurrentFees(num)
    }
    
    func setOperativeDescription() {
        guard let cardEntity = operativeData.productSelected?.cardEntity else { return }
        let formattedValue = Decimal(EasyPayConstants.minimumAmount).getSmartFormattedValue()
        let description = localized( cardEntity.isAllInOne ? "easyPay_label_dividePayNoCommissions" : "easyPay_label_dividePay", [StringPlaceholder(.value, formattedValue)])
        view?.setOperativeDescription(description)
    }
    
    func createMonthlyFees() {
        view?.setMonthlyFees([])
        let fees = operativeData.easyPayAmortization?.amortizations
        let feesList = (fees ?? []).enumerated().map {
            MonthlyFeeViewModel(amortization: $0.element, num: $0.offset, timeManager: localeManager)
        }
        if feesList.first != nil, var currentYear = feesList.first?.year {
            let groupedFees = feesList.reduce([[MonthlyFeeViewModel]]()) { (res, viewModel) in
                var resCopy = res
                guard !res.isEmpty else {
                    resCopy.append([viewModel])
                    return resCopy
                }
                var last = resCopy.removeLast()
                if viewModel.year == currentYear {
                    last.append(viewModel)
                    resCopy.append(last)
                } else {
                    resCopy.append(last)
                    resCopy.append([viewModel])
                }
                currentYear = viewModel.year
                return resCopy
            }
            view?.setMonthlyFees(groupedFees)
        }
    }
    
    func showGeneralError(_ errorDescription: String) {
        let acceptComponents = DialogButtonComponents(titled: localized("generic_button_accept"), does: nil)
        let stringLoader: StringLoader = dependenciesResolver.resolve()
        view?.showOldDialog(
            title: nil,
            description: stringLoader.getWsErrorString(errorDescription),
            acceptAction: acceptComponents,
            cancelAction: nil,
            isCloseOptionAvailable: false
        )
    }
    
    func getValidateEasyPayUseCaseInput() -> ValidateEasyPayUseCaseInput? {
        let selected: String = "\(currentFees)"
        guard let card = operativeData.productSelected?.cardEntity,
              let cardTransaction = operativeData.productSelected?.cardTransactionEntity,
              let feeData = operativeData.feeData,
              let balanceCode = operativeData.easyPayContractTransaction?.balanceCode,
              let movementIndex = operativeData.easyPayContractTransaction?.transactionDay
        else { return nil }
        return ValidateEasyPayUseCaseInput(
            card: card,
            cardTransaction: cardTransaction,
            feeData: feeData,
            numFeesSelected: selected,
            balanceCode: Int(balanceCode) ?? 0,
            movementIndex: Int(movementIndex) ?? 0
        )
    }
    
    func getConfirmEasyPayUseCaseInput() -> ConfirmEasyPayUseCaseInput? {
        guard let product = operativeData.productSelected,
              let easyPayContractTransaction = operativeData.easyPayContractTransaction
        else { return nil }
        return ConfirmEasyPayUseCaseInput(
            card: product.cardEntity,
            numFees: self.currentFees,
            easyPayContractTransaction: easyPayContractTransaction
        )
    }
    
    // MARK: - Current Fee Info Methods
    
    func getFirstFeeInfo() {
        operativeData.easyPayCurrentFeeData = nil
        let usecase = dependenciesResolver.resolve(for: FirstFeeInfoEasyPayUseCase.self)
        Scenario(useCase: usecase, input: getFirstFeeInfoUseCaseInput())
            .execute(on: dependenciesResolver.resolve())
            .onSuccess(handleFirstFeeOkResponse)
    }
    
    func handleFirstFeeOkResponse(_ result: FirstFeeInfoEasyPayUseCaseOkOutput) {
        operativeData.easyPayCurrentFeeData = result.currentFeeData
        createFirstFeeViewModel(with: result.currentFeeData)
        reloadView()
    }
    
    func createFirstFeeViewModel(with entity: EasyPayCurrentFeeDataEntity) {
        let currencyType = entity.currency.currencyType
        let viewModel = CurrentFeeDetailViewModel(
            monthlyFeeAmount: getAmount(from: entity.feeAmount, currencyType),
            monthsAmount: currentFees,
            firstFeeDate: entity.settlementDate,
            comissionAmount: getAmount(from: entity.comission, currencyType),
            interest: getAmount(from: entity.interestsAmount, currencyType),
            taePercentage: entity.tae,
            totalAmount: getAmount(from: entity.totalAmount, currencyType),
            localeManager: localeManager
        )
        view?.setFirstFeeInfo(viewModel: viewModel)
    }
    
    func getFirstFeeInfoUseCaseInput() -> EasyPayFirstFeeInfoUseCaseInput {
        return EasyPayFirstFeeInfoUseCaseInput(
            numberOfFees: currentFees,
            cardDTO: operativeData.productSelected?.cardEntity.dto,
            transactionBalanceCode: operativeData.easyPayContractTransaction?.dto.balanceCode,
            transactionDay: operativeData.easyPayContractTransaction?.transactionDay
        )
    }
    
    func getAmount(from value: Double?, _ currency: CurrencyType) -> AmountEntity? {
        guard let value = value else { return nil }
        return AmountEntity(
            value: Decimal(value),
            currency: currency
        )
    }
    
    func getAmount(from value: Int?, _ currency: CurrencyType) -> AmountEntity? {
        guard let value = value else { return nil }
        return AmountEntity(
            value: Decimal(value),
            currency: currency
        )
    }
    
    func existsError() -> Bool {
        if case .completedWithError = state {
            return true
        }
        return false
    }
}

extension EasyPayConfigurationPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: EasyPayConfigurationPage {
        return EasyPayConfigurationPage()
    }
}
