//
//  SendMoneyConfirmationPresenter.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import Operative
import CoreFoundationLib

protocol SendMoneyConfirmationPresenterProtocol: OperativeStepPresenterProtocol {
    var view: SendMoneyConfirmationView? { get set }
    func viewDidLoad()
    func back()
    func close()
    func saveEmail(_ email: String?)
    func didTapOnContinue()
}

class SendMoneyConfirmationPresenter {
    var number: Int = 0
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var container: OperativeContainerProtocol?
    weak var view: SendMoneyConfirmationView?
    let dependenciesResolver: DependenciesResolver
    var shouldShowProgressBar: Bool { return true }
    
    lazy var operativeData: SendMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    var modifier: SendMoneyModifierProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func getConfirmationItemsViewModels() -> [OneListFlowItemViewModel] {
        fatalError("Implement in childs")
    }
    
    func setupTransferAmount() {
        fatalError("Implement in childs")
    }
    
    func setupNotifyEmail() {
        guard self.operativeData.transferDateType != nil,
              let notify = self.modifier?.isEditConfirmationEnabled
        else { return }
        if notify {
            self.view?.addNotifyByEmail()
        }
    }
    
    func getCostWaringLabel() -> String? {
        fatalError("Implement in childs")
    }
    
    func didTapOnContinue() {
        fatalError("Implement in childs")
    }
    
    func trackScreen() {
        guard let amountRepresentable = self.operativeData.amount,
              let amount = amountRepresentable.value,
              let currency = amountRepresentable.currencyRepresentable?.currencyName else { return }
        self.trackerManager.trackScreen(screenId: trackerPage.page,
                                        extraParameters: self.operativeData.type == .national ? ["transaction_currency" : "\(currency)",
                                                                                                 "transaction_amount" : "\(amount)",
                                                                                                 "transfer_country": self.operativeData.type.trackerName] : [:])
    }
    
    func goToAccountSelector() {
        self.container?.back(to: SendMoneyAccountSelectorPresenter.self, creatingAt: 0, step: SendMoneyAccountSelectorStep(dependenciesResolver: self.dependenciesResolver))
    }
    
    func goToSendDate() {
        self.container?.back()
    }
    
    func goToDestinationAccount() {
        self.container?.back(to: SendMoneyDestinationAccountPresenter.self)
    }
}

extension SendMoneyConfirmationPresenter: SendMoneyConfirmationPresenterProtocol {
    func viewDidLoad() {
        self.setupConfirmationItems()
        self.setupTransferAmount()
        self.setupCostWarning()
        self.setupNotifyEmail()
        self.trackScreen()
    }
    
    func back() {
        self.container?.back()
    }
    
    func close() {
        self.container?.close()
    }
    
    func saveEmail(_ email: String?) {
        let data = self.operativeData
        data.beneficiaryMail = email
        self.container?.save(data)
        self.trackEvent(.notifyEmail, parameters: self.operativeData.type == .national ? ["transfer_country" : self.operativeData.type.trackerName] : [:])
    }
}

extension SendMoneyConfirmationPresenter {
    func setupConfirmationItems() {
        let items = self.getConfirmationItemsViewModels()
        self.view?.setConfirmationItems(items)
    }
    
    func setupCostWarning() {
        self.view?.addCostsWarningWith(labelValue: self.getCostWaringLabel())
    }
}

extension SendMoneyConfirmationPresenter: AutomaticScreenActionTrackable {
    var trackerPage: SendMoneyConfirmationPage {
        SendMoneyConfirmationPage(national: self.operativeData.type == .national, type: self.operativeData.type.trackerName)
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
