import CoreFoundationLib

protocol BizumSendAgainPresenterProtocol {
    var view: BizumSendAgainViewProtocol? { get set }
    func viewDidLoad()
    func didSelectReuseSendAgain()
}

final class BizumSendAgainPresenter {
    weak var view: BizumSendAgainViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private let configuration: BizumSendAgainConfiguration

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.configuration = self.dependenciesResolver.resolve()
    }
}

extension BizumSendAgainPresenter: BizumSendAgainPresenterProtocol {
    var coordinator: BizumSendAgainCoordinatorProtocol {
         return self.dependenciesResolver.resolve(for: BizumSendAgainCoordinatorProtocol.self)
     }

    func viewDidLoad() {
        let builder = BizumSendAgainBuilder(configuration: configuration)
            .addTitle()
            .addItems()
            .addContact()
            .addContinueButton()
        self.view?.setSendAgainView(builder.build())
        self.trackScreen()
    }

    func didSelectReuseSendAgain() {
        let viewModel = BizumSendAgainOperativeViewModel(contact: configuration.contact, bizumSendMoney: configuration.sendMoney)
        switch configuration.type {
        case .request:
            self.coordinator.didSelectRequestAgain(viewModel)
        case .send:
            self.coordinator.didSelectSendAgain(viewModel)
        }
    }
}

extension BizumSendAgainPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: BizumSendAgainConstants {
         return BizumSendAgainConstants()
     }
}
