import Foundation
import CoreFoundationLib
import Operative

protocol InternalTransferConfirmationPresenterProtocol: OperativeConfirmationPresenterProtocol {
    var view: InternalTransferConfirmationViewProtocol? { get set }
    func viewDidLoad()
    func close()
    func faqs()
    func trackFaqEvent(_ question: String, url: URL?)
}

class InternalTransferConfirmationPresenter {
    
    weak var view: InternalTransferConfirmationViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    lazy var operativeData: InternalTransferOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    private lazy var internalTransferModifier = self.dependenciesResolver.resolve(forOptionalType: InternalTransferModifierProtocol.self)

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    enum ConfirmationItem {
        case amount
        case concept
        case originAccount
        case periodicity
        case date
        case destinationAccount
    }
    
    func setupConfirmationItems() {
        let builder = InternalTransferConfirmationBuilder(internalTransfer: self.operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAmount(action:
            self.confirmationItemAction(.amount))
        builder.addConcept(action:
            self.confirmationItemAction(.amount))
        builder.addOriginAccount(action: self.confirmationItemAction(.originAccount))
        builder.addTransferType()
        builder.addDestinationAccount(action: self.confirmationItemAction(.destinationAccount))
        builder.addDate()
        self.view?.add(builder.build())
        guard let totalAmount = self.operativeData.internalTransfer?.netAmount else { return }
        self.view?.addTotalOperationAmount(totalAmount)
    }
    
    func didSelectContinue() {
        self.validateData()
    }
}

extension InternalTransferConfirmationPresenter: InternalTransferConfirmationPresenterProtocol {
    func viewDidLoad() {
        if let internalTransferModifier = internalTransferModifier {
            self.view?.setContinueTitle(localized(getContinueTitleKey(internalTransferModifier)))
        } else {
            self.view?.setContinueTitle(localized("generic_button_send"))
        }
        self.setupConfirmationItems()
        self.trackScreen()
    }

    func close() {
        self.container?.close()
    }

    func faqs() {
        let faqs = self.operativeData.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
        } ?? []
        self.trackerManager.trackScreen(screenId: InternalTransferFaqPage().page, extraParameters: [:])
        self.view?.showFaqs(faqs)
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question": question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: NSNotification.Name("transfer_faqs"), object: nil, userInfo: ["parameters": dic])
    }
}

extension InternalTransferConfirmationPresenter {
    
    func modifyAmountConceptOrPeriodicity() {
        self.container?.back(to: InternalTransferAmountAndTypeSelectorPresenter.self)
    }
    
    func modifyOriginAccount() {
        self.operativeData.amount = nil
        self.container?.save(self.operativeData)
        self.container?.back(
            to: InternalTransferAccountSelectorPresenter.self,
            creatingAt: 0,
            step: InternalTransferAccountSelectorStep(dependenciesResolver: dependenciesResolver)
        )
    }
    
    func modifyDestinationAccount() {
        self.operativeData.amount = nil
        self.container?.save(self.operativeData)
        self.container?.back(to: InternalTransferDestinationAccountSelectorPresenter.self)
    }
    
    func confirmationItemAction(_ type: ConfirmationItem) -> ConfirmationItemAction? {
        if let avaiableItemAction = self.internalTransferModifier?.avaiableItemAction, avaiableItemAction == false {
            return nil
        } else {
            return self.getConfirmationItemAction(type)
        }
    }
}

private extension InternalTransferConfirmationPresenter {
    
    func validateData() {
        guard
            let originAccount = self.operativeData.selectedAccount,
            let destinationAccount = self.operativeData.destinationAccount,
            let amount = self.operativeData.amount,
            let transferTime = self.operativeData.time
        else {
            return
        }
        self.view?.showLoading()
        let input = ConfirmInternalTransferUseCaseInput(
            originAccount: originAccount,
            destinationAccount: destinationAccount,
            amount: amount,
            concept: self.operativeData.concept,
            transferTime: transferTime,
            scheduledTransfer: self.operativeData.scheduledTransfer
        )
        UseCaseWrapper(
            with: self.dependenciesResolver.resolve(firstTypeOf: ConfirmInternalTransferUseCaseProtocol.self)
                .setRequestValues(requestValues: input),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.view?.dismissLoading {
                    self.operativeData.scheduledTransfer = result.scheduledTransfer
                    self.operativeData.internalTransfer = result.internalTransfer
                    self.container?.save(result.scaEntity)
                    self.container?.rebuildSteps()
                    self.container?.save(self.operativeData)
                    self.container?.stepFinished(presenter: self)
                }
            },
            onError: { [weak self] errorResult in
                self?.view?.dismissLoading {
                    guard let self = self else { return }
                    self.showErrorMessage(key: errorResult.getErrorDesc() ?? "generic_error_connection")
                    return
                }
            }
        )
    }
    
    func showErrorMessage(key: String) {
        self.view?.showOldDialog(
            title: nil,
            description: localized(key),
            acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil),
            cancelAction: nil,
            isCloseOptionAvailable: false
        )
    }
    
    func getConfirmationItemAction(_ type: ConfirmationItem) -> ConfirmationItemAction? {
        switch type {
        case .amount, .concept, .periodicity, .date:
            return ConfirmationItemAction(title: localized("generic_edit_link"), action: self.modifyAmountConceptOrPeriodicity)
        case .originAccount:
            return ConfirmationItemAction(title: localized("generic_edit_link"), action: self.modifyOriginAccount)
        case .destinationAccount:
            return ConfirmationItemAction(title: localized("generic_edit_link"), action: self.modifyDestinationAccount)
        }
    }
}

extension InternalTransferConfirmationPresenter: AutomaticScreenActionTrackable {
     var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: InternalTransferConfirmationPage {
        return InternalTransferConfirmationPage()
    }
    
    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.scheduledTransferType.key: self.operativeData.time?.trackerDescription ?? ""
        ]
    }
}

private extension InternalTransferConfirmationPresenter {
    func getContinueTitleKey(_ modifier: InternalTransferModifierProtocol) -> String {
        return modifier.getContinueTitleKey()
    }
}
