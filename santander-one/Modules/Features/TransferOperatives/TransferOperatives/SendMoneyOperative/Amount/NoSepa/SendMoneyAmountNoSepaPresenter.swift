//
//  SendMoneyAmountNoSepaPresenter.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 25/1/22.
//

import Foundation
import Operative
import CoreDomain
import CoreFoundationLib
import PdfCommons

protocol SendMoneyAmountNoSepaPresenterProtocol: OperativeStepPresenterProtocol, SendMoneyCurrencyHelperPresenterProtocol {
    var view: SendMoneyAmountNoSepaView? { get set }
    func getSubtitleInfo() -> String
    func getStepOfSteps() -> [Int]
    func viewDidLoad()
    func viewDidAppear()
    func didSelectContinue()
    func didSelectBack()
    func didSelectClose()
    func changeOriginAccount()
    func changeDestinationAccount()
    func saveRecipientBankOutput(_ output: RecipientBankViewOutput)
    func saveAmount(_ amount: String)
    func saveDescription(_ description: String?)
    func didSelectExpense(_ expense: SendMoneyNoSepaExpensesProtocol)
    func hasEdited(_ field: String?)
}

final class SendMoneyAmountNoSepaPresenter {
    var number: Int = 0
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var container: OperativeContainerProtocol?
    weak var view: SendMoneyAmountNoSepaView?
    let dependenciesResolver: DependenciesResolver
    lazy var operativeData: SendMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var sendMoneyUseCaseProvider: SendMoneyUseCaseProviderProtocol {
        return self.dependenciesResolver.resolve()
    }
    private var isFloatingButtonEnabled = false
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension SendMoneyAmountNoSepaPresenter: SendMoneyAmountNoSepaPresenterProtocol {
    var viewCurrencyHelper: SendMoneyCurrencyHelperViewProtocol? {
        return self.view
    }
    func getSubtitleInfo() -> String {
        self.container?.getSubtitleInfo(presenter: self) ?? ""
    }
    
    func getStepOfSteps() -> [Int] {
        self.container?.getStepOfSteps(presenter: self) ?? []
    }
    
    func viewDidLoad() {
        self.loadCurrenciesSelectionItems()
        self.setViews()
        self.trackScreen()
    }
    
    func viewDidAppear() {
        self.container?.progressBarAlpha(1)
        self.setFloatingButton()
    }
    
    func didSelectContinue() {
        self.goToNextStep()
    }
    
    func didSelectBack() {
        self.container?.back()
    }
    
    func didSelectClose() {
        self.container?.close()
    }
    
    func changeOriginAccount() {
        self.container?.back(
            to: SendMoneyAccountSelectorPresenter.self,
            creatingAt: 0,
            step: SendMoneyAccountSelectorStep(dependenciesResolver: self.dependenciesResolver))
    }
    
    func changeDestinationAccount() {
        self.container?.back(
            to: SendMoneyDestinationAccountPresenter.self,
            creatingAt: 0,
            step: SendMoneyDestinationStep(dependenciesResolver: self.dependenciesResolver))
    }
    
    func saveRecipientBankOutput(_ output: RecipientBankViewOutput) {
        self.operativeData.bicSwift = output.bicSwift
        self.operativeData.bankName = output.bankName
        self.operativeData.bankAddress = output.bankAddress
        self.setFloatingButton()
    }
    
    func saveAmount(_ amount: String) {
        if !amount.isEmpty {
            guard let currency = self.operativeData.currency else { return }
            let currencyRepresented = CurrencyRepresented(currencyName: currency.code, currencyCode: currency.code)
            self.operativeData.amount = AmountRepresented(value: amount.notWhitespaces().stringToDecimal ?? 0, currencyRepresentable: currencyRepresented)
        } else {
            self.operativeData.amount = nil
        }
        self.setFloatingButton()
    }
    
    func saveDescription(_ description: String?) {
        self.operativeData.description = description
    }
    
    func didSelectExpense(_ expense: SendMoneyNoSepaExpensesProtocol) {
        self.operativeData.expenses = expense
        self.setAmountDateView()
        self.trackEvent(.paymentCost, parameters: [:])
    }
    
    func hasEdited(_ field: String?) {
        guard let field = field else { return }
        self.trackerManager.trackEvent(screenId: self.trackerPage.page, eventId: field, extraParameters: [:])
    }
}

private extension SendMoneyAmountNoSepaPresenter {
    
    var sendMoneyModifier: SendMoneyModifierProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)
    }
    
    var destinationIban: IBANRepresentable? {
        return self.operativeData.destinationIBANRepresentable
    }
    
    var isCurrencyEditable: Bool {
        let isCurrencyEditable = self.sendMoneyModifier?.isCurrencyEditable(self.operativeData)
        return isCurrencyEditable ?? false
    }
    
    func setViews() {
        self.setAccountSelectorView()
        self.setRecipientBankView()
        self.setAmountDateView()
    }
    
    func setAccountSelectorView() {
        guard let selectedAccount = self.operativeData.selectedAccount,
              let destinationIban = self.destinationIban
        else { return }
        var originImage: String?
        if let mainAcount = self.operativeData.mainAccount, mainAcount.equalsTo(other: selectedAccount) {
            originImage = "icnHeartTint"
        }
        let amountType = self.sendMoneyModifier?.amountToShow ?? .currentBalance
        let viewModel = OneAccountsSelectedCardViewModel(
            statusCard: .expanded(
                OneAccountsSelectedCardExpandedViewModel(
                    destinationIban: destinationIban,
                    destinationAlias: self.operativeData.destinationAlias ?? self.operativeData.destinationName,
                    destinationCountry: self.operativeData.destinationCountryName ?? ""
                )
            ),
            originAccount: selectedAccount,
            originImage: originImage,
            amountToShow: amountType
        )
        self.view?.addAccountSelector(viewModel)
    }
    
    func setRecipientBankView() {
        guard let baseUrl = self.dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL
        else { return }
        let appRepository: AppRepositoryProtocol = self.dependenciesResolver.resolve()
        let language = appRepository.getCurrentLanguage().rawValue
        let viewModel = RecipientBankViewModel(bicSwift: self.operativeData.bicSwift,
                                               bankName: self.operativeData.bankName,
                                               bankAddress: self.operativeData.bankAddress,
                                               swiftHelperUrl: String(format: "%@RWD/helper/images/%@_swiftHelper.png",
                                                                      baseUrl,
                                                                      language),
                                               swiftHelperDefaultImageKey: "en_swiftHelper")
        self.view?.addRecipientBankView(viewModel: viewModel)
    }
    
    func setAmountDateView() {
        let pdfAction =  {
            let useCase = self.sendMoneyUseCaseProvider.getNoSepaFeesUseCase()
            self.view?.showLoading()
            Scenario(useCase: useCase)
                .execute(on: self.dependenciesResolver.resolve())
                .onSuccess { [weak self] data in
                    guard let data = data, let self = self else { return }
                    self.view?.hideLoading()
                    self.dependenciesResolver.resolve(for: PDFCoordinatorLauncher.self).openPDF(data, title: "toolbar_title_ratesExpenses", source: .nosepa)
                    self.container?.progressBarAlpha(0)
                    self.trackEvent(.fileDownload, parameters: [:])
                }
                .onError { [weak self] _ in
                    self?.view?.hideLoading()
                }
        }
        let viewModel = AmountAndDateViewModel(isCurrencyEditable: self.isCurrencyEditable,
                                               currencyCode: self.operativeData.currency?.code ?? self.operativeData.currencyName,
                                               amount: self.operativeData.amount,
                                               description: self.operativeData.description,
                                               selectedExpense: self.operativeData.expenses,
                                               expenses: self.sendMoneyModifier?.expensesItems,
                                               pdfAction: pdfAction)
        self.view?.addAmountDateView(viewModel: viewModel)
    }
    
    func setFloatingButton() {
        self.isFloatingButtonEnabled = !(self.operativeData.bicSwift ?? "").isEmpty || !(self.operativeData.bankName ?? "").isEmpty
        self.isFloatingButtonEnabled = self.isFloatingButtonEnabled && self.operativeData.amount != nil
        self.view?.isEnabledFloattingButton(self.isFloatingButtonEnabled)
    }
    
    func goToNextStep() {
        let useCase = self.sendMoneyUseCaseProvider.getAmountNoSepaUseCase()
        self.view?.showLoading()
        Scenario(useCase: useCase, input: self.operativeData)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] ouput in
                self?.view?.hideLoading()
                guard let self = self else { return }
                self.container?.save(ouput)
                if let output = ouput.specialPricesOutput,
                   output.shouldShowSpecialPrices {
                    self.container?.stepFinished(presenter: self)
                } else {
                    self.container?.go(to: SendMoneyConfirmationPresenter.self)
                }
            }
            .onError { error in
                self.view?.hideLoading()
                self.container?.showGenericError()
            }
    }
}

extension SendMoneyAmountNoSepaPresenter: AutomaticScreenActionTrackable {
    var trackerPage: SendMoneyAmountAndDatePage {
        SendMoneyAmountAndDatePage(national: self.operativeData.type == .national, type: self.operativeData.type.trackerName)
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
