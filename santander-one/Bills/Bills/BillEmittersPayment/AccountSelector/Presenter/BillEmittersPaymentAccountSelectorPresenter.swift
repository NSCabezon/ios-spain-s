import Foundation
import CoreFoundationLib
import Operative
import UI

protocol BillEmittersPaymentAccountSelectorPresenterProtocol: OperativeStepPresenterProtocol, MenuTextWrapperProtocol {
    var view: BillEmittersPaymentAccountSelectorViewProtocol? { get set }
    func viewDidLoad()
    func didSelectAccount(_ viewModel: BillAccountSelectionViewModel)
    func didTapFaqs()
    func didTapClose()
    func trackFaqEvent(_ question: String, url: URL?)
}

class BillEmittersPaymentAccountSelectorPresenter {
    weak var view: BillEmittersPaymentAccountSelectorViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    lazy var operativeData: BillEmittersPaymentOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BillEmittersPaymentAccountSelectorPresenter: BillEmittersPaymentAccountSelectorPresenterProtocol {
    func viewDidLoad() {
        self.view?.showAccounts(self.operativeData.accounts.map(BillAccountSelectionViewModel.init))
    }
    
    func didSelectAccount(_ viewModel: BillAccountSelectionViewModel) {
        self.operativeData.selectedAccount = viewModel.account
        self.container?.save(self.operativeData)
        self.container?.stepFinished(presenter: self)
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

extension BillEmittersPaymentAccountSelectorPresenter: AutomaticScreenActionTrackable {
    
    var trackerPage: BillEmittersPaymentAccountSelectorPage {
        BillEmittersPaymentAccountSelectorPage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
