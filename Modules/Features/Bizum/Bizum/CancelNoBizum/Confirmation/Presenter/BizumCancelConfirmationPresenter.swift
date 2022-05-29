import CoreFoundationLib
import Operative

protocol BizumCancelConfirmationPresenterProtocol: OperativeConfirmationPresenterProtocol {
    var view: BizumCancelConfirmationViewProtocol? { get set }
    func viewDidLoad()
    func didTapClose()
}

final class BizumCancelConfirmationPresenter {
    var view: BizumCancelConfirmationViewProtocol?
    // MARK: - OperativeStepPresenterProtocol
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    // MARK: - Private Var
    private var dependenciesResolver: DependenciesResolver
    private lazy var operativeData: BizumCancelOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func viewDidLoad() {
        self.trackScreen()
        self.loadData()
        self.view?.setContinueTitle(localized("generic_button_continue"))
    }
}

private extension BizumCancelConfirmationPresenter {
    func loadData() {
        let builder = BizumCancelConfirmationBuilder(data: self.operativeData)
        builder.addAmountAndConcept()
        builder.addSendingDate()
        builder.addOriginAccount()
        builder.addTransferType()
        builder.addContactPhone()
        builder.addTotal()
        self.view?.add(builder.build())
    }
}

extension BizumCancelConfirmationPresenter: BizumCancelConfirmationPresenterProtocol {
    func didSelectContinue() {
        guard let document = operativeData.document,
              let operationEntity = operativeData.operationEntity.bizumOperationEntity,
              let date = operativeData.operationEntity.bizumOperationEntity?.date
        else { return }
        self.view?.showLoading()
        
        let input = BizumCancelUseCaseInput(checkPayment: operativeData.bizumCheckPaymentEntity, document: document, bizumOperation: operationEntity, dateTime: date)
        let useCase = self.dependenciesResolver.resolve(for: BizumCancelUseCase.self).setRequestValues(requestValues: input)
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { _ in
                self.view?.dismissLoading {
                    self.container?.stepFinished(presenter: self)
                }
            }, onError: { result in
                self.view?.dismissLoading {
                    self.view?.showDialog(
                        withDependenciesResolver: self.dependenciesResolver,
                        description: result.getErrorDesc()
                    )
                }
            }
        )
    }
    
    func didTapClose() {
        self.container?.close()
    }
}

extension BizumCancelConfirmationPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumCancelConfirmationPage {
        return BizumCancelConfirmationPage()
    }
}
