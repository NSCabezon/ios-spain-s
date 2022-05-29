import Foundation
import CoreFoundationLib
import Operative
import UI

protocol InternalTransferAccountSelectorPresenterProtocol: OperativeStepPresenterProtocol {
    var view: InternalTransferAccountSelectorViewProtocol? { get set }
    func viewDidLoad()
    func didSelectAccount(_ viewModel: InternalTransferAccountSelectionViewModel)
    func close()
    func faqs()
    func trackFaqEvent(_ question: String, url: URL?)
}

final class InternalTransferAccountSelectorPresenter {
    
    weak var view: InternalTransferAccountSelectorViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var shouldShowProgressBar: Bool { return true }
    lazy var operativeData: InternalTransferOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension InternalTransferAccountSelectorPresenter: InternalTransferAccountSelectorPresenterProtocol {
    
    func viewDidLoad() {
        self.view?.showAccounts(
            accountVisibles: self.operativeData.accountVisibles.map {InternalTransferAccountSelectionViewModel(account: $0, dependenciesResolver: self.dependenciesResolver) },
            accountNotVisibles: self.operativeData.accountNotVisibles.map {InternalTransferAccountSelectionViewModel(account: $0, dependenciesResolver: self.dependenciesResolver) })
        self.trackScreen()
    }
    
    func didSelectAccount(_ viewModel: InternalTransferAccountSelectionViewModel) {
        self.operativeData.selectedAccount = viewModel.account
        self.container?.save(self.operativeData)
        self.container?.stepFinished(presenter: self)
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

extension InternalTransferAccountSelectorPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: InternalTransferSelectOriginPage {
        return InternalTransferSelectOriginPage()
    }
}
