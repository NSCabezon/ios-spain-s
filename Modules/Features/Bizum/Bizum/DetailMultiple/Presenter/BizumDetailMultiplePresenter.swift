import Foundation
import CoreFoundationLib

protocol BizumDetailMultiplePresenterProtocol: class, MenuTextWrapperProtocol {
    var view: BizumDetailMultipleViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func showImage()
}

final class BizumDetailMultiplePresenter {
    weak var view: BizumDetailMultipleViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private let bizumTransaction: BizumTransactionEntity
    private var builder: BizumDetailMultipleBuilder?
    private var userName: String?

    init(dependenciesResolver: DependenciesResolver, detail: BizumHistoricOperationEntity) {
         self.dependenciesResolver = dependenciesResolver
         self.bizumTransaction = BizumTransactionEntity(operationEntity: detail, dependenciesResolver: dependenciesResolver)
     }
}

private extension BizumDetailMultiplePresenter {
    var detailMultipleModuleCoordinator: DetailMultipleModuleCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: DetailMultipleModuleCoordinatorProtocol.self)
    }
    
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var checkPaymentEntity: BizumCheckPaymentEntity {
        let configuration: BizumCheckPaymentConfiguration = dependenciesResolver.resolve()
        return configuration.bizumCheckPaymentEntity
    }

    var getGlobalPositionUseCase: GetGlobalPositionUseCaseAlias {
        return self.dependenciesResolver.resolve(for: GetGlobalPositionUseCaseAlias.self)
    }
    
    func performGetMultimediaContent() {
        guard bizumTransaction.hasAttachment else { return }
        self.view?.showLoading()
        let input = GetMultimediaContentInputUseCase(checkPayment: self.checkPaymentEntity,
                                                     operationId: self.bizumTransaction.operationId)
        let useCase = GetMultimediaContentUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                self?.view?.dismissLoading(completion: {
                    self?.getMultimediaContentSuccess(response)
                })
            }.onError { [weak self] _ in
                self?.view?.dismissLoading(completion: nil)
            }
    }

    func getMultimediaContentSuccess(_ response: GetMultimediaContentOutput) {
        self.bizumTransaction.multimedia = response.multimediaData
        guard let multimediaViewModel = builder?.buildMultimedia(response.multimediaData) else { return }
        self.view?.showMultimedia(multimediaViewModel)
    }
    
    func getUserName(_ success: @escaping (String?) -> Void, failure: @escaping () -> Void) {
        UseCaseWrapper(
            with: self.getGlobalPositionUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { response in
                success(response.globalPosition.fullName)
            },
            onError: { _ in
                failure()
            })
    }
    
    func finishSetupViewModel() {
        let phone = checkPaymentEntity.phone?.trim() ?? ""
        self.bizumTransaction.resolveOrigin(phone: phone)
    }

    func buildView() {
        self.builder = BizumDetailMultipleBuilder(with: self.bizumTransaction)
        self.builder?.build()
        self.performGetMultimediaContent()
        guard let builderItems = builder?.items else { return }
        self.view?.showDetail(builderItems)
    }
}

extension BizumDetailMultiplePresenter: BizumDetailMultiplePresenterProtocol {
    func viewDidLoad() {
        self.finishSetupViewModel()
        self.buildView()
        self.trackScreen()
    }

    func didSelectDismiss() {
        self.detailMultipleModuleCoordinator.didSelectDismiss()
    }

    func showImage() {
        guard let image = self.bizumTransaction.multimedia?.image else { return }
        self.detailMultipleModuleCoordinator.openImageDetail(image)
    }
}

extension BizumDetailMultiplePresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: BizumDetailPage {
        return BizumDetailPage()
    }
}
