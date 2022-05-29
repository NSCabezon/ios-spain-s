import Foundation
import CoreFoundationLib
import Operative
import UI

protocol BillEmittersPaymentConfirmationPresenterProtocol: OperativeConfirmationPresenterProtocol, MenuTextWrapperProtocol {
    var view: BillEmittersPaymentConfirmationViewProtocol? { get set }
    func viewDidLoad()
    func didTapFaqs()
    func didTapClose()
    func trackFaqEvent(_ question: String, url: URL?)
}

class BillEmittersPaymentConfirmationPresenter {
    
    weak var view: BillEmittersPaymentConfirmationViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var operativeData: BillEmittersPaymentOperativeData {
        guard let container = self.container else { fatalError() }
        return container.get()
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BillEmittersPaymentConfirmationPresenter: BillEmittersPaymentConfirmationPresenterProtocol {
    
    func viewDidLoad() {
        self.trackScreen()
        let builder = BillEmittersPaymentConfirmationBuilder(operativeData: self.operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAmount {
            self.container?.back(to: BillEmittersManualPaymentPresenter.self)
        }
        builder.addOriginAccount()
        builder.addType()
        builder.addEmitter()
        builder.addEmitterCode()
        builder.addItems()
        builder.addDate()
        self.view?.setContinueTitle(localized("generic_button_confirm"))
        self.view?.add(builder.build())
    }
    
    func didSelectContinue() {
        guard let selectedEmitter = self.operativeData.selectedEmitter, let selectedIncome = self.operativeData.selectedIncome else { return }
        self.fetchFields(forEmitter: selectedEmitter, income: selectedIncome)
    }
    
    func fetchFields(forEmitter emitter: EmitterEntity, income: IncomeEntity) {
        guard let account = self.operativeData.selectedAccount else { return }
        self.view?.showLoading()
        let input = GetBillEmittersPaymentFieldsUseCaseInput(account: account, emitterCode: emitter.code, productIdentifier: income.productIdentifier, collectionTypeCode: income.typeCode, collectionCode: income.code)
        UseCaseWrapper(
            with: self.dependenciesResolver.resolve(for: GetBillEmittersPaymentFieldsUseCase.self).setRequestValues(requestValues: input),
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { [weak self] output in
                guard let self = self else { return }
                self.container?.save(output.formats.signature)
                self.view?.dismissLoading {
                    self.container?.stepFinished(presenter: self)
                }
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                let acceptAction = DialogButtonComponents(titled: localized("generic_button_accept"), does: nil)
                self.view?.dismissLoading {
                    self.view?.showOldDialog(
                        withDependenciesResolver: self.dependenciesResolver,
                        for: error,
                        acceptAction: acceptAction,
                        cancelAction: nil,
                        isCloseOptionAvailable: true
                    )
                }
            }
        )
    }
    
    func didTapFaqs() {
        trackEvent(.faq, parameters: [:])
        let faqModel = operativeData.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
        } ?? []
        trackerManager.trackScreen(screenId: BillEmittersPaymentFaqPage().page, extraParameters: [:])
        self.view?.showFaqs(faqModel)
    }
    
    func didTapClose() {
        container?.close()
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question": question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: NSNotification.Name("billsFaqsAnalytics"), object: nil, userInfo: ["parameters": dic])
    }
}

extension BillEmittersPaymentConfirmationPresenter: AutomaticScreenActionTrackable {
    
    var trackerPage: BillEmittersPaymentConfirmationPage {
        BillEmittersPaymentConfirmationPage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
