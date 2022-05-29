import Foundation
import CoreFoundationLib
import Operative
import UI

protocol InternalTransferDestinationAccountSelectorPresenterProtocol: OperativeStepPresenterProtocol {
    var view: InternalTransferDestinationAccountSelectorViewProtocol? { get set }
    func viewDidLoad()
    func didSelectAccount(_ viewModel: InternalTransferAccountSelectionViewModel)
    func close()
    func faqs()
    func trackFaqEvent(_ question: String, url: URL?)
}

class InternalTransferDestinationAccountSelectorPresenter {
    
    weak var view: InternalTransferDestinationAccountSelectorViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    lazy var operativeData: InternalTransferOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func modifyOriginAccount() {
        self.container?.back(
            to: InternalTransferAccountSelectorPresenter.self,
            creatingAt: 0,
            step: InternalTransferAccountSelectorStep(dependenciesResolver: dependenciesResolver)
        )
    }
}

extension InternalTransferDestinationAccountSelectorPresenter: InternalTransferDestinationAccountSelectorPresenterProtocol {
    func viewDidLoad() {
        guard let account = self.operativeData.selectedAccount else { return }
        let accountVisibles = self.operativeData.accountVisibles
            .filter { $0 != account }
            .map { InternalTransferAccountSelectionViewModel(account: $0, dependenciesResolver: self.dependenciesResolver) }
        let accountNotVisibles = self.operativeData.accountNotVisibles
            .filter { $0 != account }
            .map { InternalTransferAccountSelectionViewModel(account: $0, dependenciesResolver: self.dependenciesResolver) }
        self.view?.showAccounts(accountVisibles: accountVisibles, accountNotVisibles: accountNotVisibles)
        let viewModel = SelectedAccountHeaderViewModel(account: account, action: modifyOriginAccount, dependenciesResolver: self.dependenciesResolver)
        self.view?.showSelectedAccount(viewModel)
        self.trackScreen()
    }
    
    func didSelectAccount(_ viewModel: InternalTransferAccountSelectionViewModel) {
        self.operativeData.destinationAccount = viewModel.account
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

extension InternalTransferDestinationAccountSelectorPresenter: AutomaticScreenTrackable {
     var trackerManager: TrackerManager {
           return dependenciesResolver.resolve(for: TrackerManager.self)
       }
       
       var trackerPage: InternalTransferSelectDestinationPage {
           return InternalTransferSelectDestinationPage()
       }
}
