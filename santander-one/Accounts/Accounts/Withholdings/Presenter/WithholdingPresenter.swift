import Foundation
import CoreFoundationLib

protocol WithholdingPresenterProtocol: AnyObject {
    var view: WithholdingViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
}

final class WithholdingPresenter {
    weak var view: WithholdingViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var configuration: WithholdingConfiguration {
        self.dependenciesResolver.resolve(for: WithholdingConfiguration.self)
    }
    
    private var amount: WithholdingAmountViewModel {
        guard let amount = configuration.detailEntity.withholdingAmount, let amountValue = amount.value else {
            return WithholdingAmountViewModel(amount: AmountEntity.empty)
        }
        let unsignedAmount = amountValue.isSignMinus ? amount.changedSign : amount
        return WithholdingAmountViewModel(amount: unsignedAmount)
    }
    
    private var accountDetail: AccountDetailEntity {
        configuration.detailEntity
    }
    
    private var getWithholdingUseCase: GetWithholdingUseCase {
        dependenciesResolver.resolve(for: GetWithholdingUseCase.self)
    }
    
    private var coordinator: WithholdingCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: WithholdingCoordinatorProtocol.self)
    }
    
    private func loadWithHolding() {
        UseCaseWrapper(
            with: getWithholdingUseCase.setRequestValues(requestValues: GetWithholdingInput(account: accountDetail)),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] response in
                switch response.withholding {
                case let .withholding(withholdingListEntiy):
                    self?.handleWithholdingList(withholdingListEntiy)
                case .disabled:
                    self?.view?.didLoadWithholding([])
                }
            },
            onError: { [weak self] _ in
                self?.view?.didErrorWithholding()
            }
        )
    }
    
    private func handleWithholdingList(_ withholdingListEntiy: WithholdingListEntity) {
        let currency = accountDetail.withholdingAmount?.currency
        let fixedWithholdingString: String = localized("withholding_label_consolidated")
        let viewModels = withholdingListEntiy.transactions.map {
            WithholdingViewModel(entity: $0, currency: currency ?? "", fixedLabel: fixedWithholdingString)
        }
        if viewModels.count == 0 {
            self.view?.showEmptyView()
        } else {
            self.view?.didLoadWithholding(viewModels)
        }
    }
}

extension WithholdingPresenter: WithholdingPresenterProtocol {
    
    func viewDidLoad() {
        view?.showTotalAmount(amount)
        view?.showLoadingView()
        loadWithHolding()
        trackScreen()
    }
    
    func didSelectDismiss() {
        coordinator.didSelectDismiss()
    }
}

extension WithholdingPresenter: AutomaticScreenTrackable {
    var trackerPage: WithholdingPage {
        WithholdingPage()
    }
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
