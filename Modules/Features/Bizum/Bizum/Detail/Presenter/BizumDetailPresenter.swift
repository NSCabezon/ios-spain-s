import CoreFoundationLib

protocol BizumDetailPresenterProtocol: MenuTextWrapperProtocol {
    var view: BizumDetailViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func showImage()
    func actionDidTap(type: BizumActionType)
    func didTapShare()
    func didTapReuseContact()
}

final class BizumDetailPresenter {
    weak var view: BizumDetailViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private let bizumTransaction: BizumTransactionEntity
    private var builder: BizumDetailBuilder?
    private var userName: String?

    init(dependenciesResolver: DependenciesResolver, detail: BizumHistoricOperationEntity) {
         self.dependenciesResolver = dependenciesResolver
         self.bizumTransaction = BizumTransactionEntity(operationEntity: detail, dependenciesResolver: dependenciesResolver)
     }
}

private extension BizumDetailPresenter {
    var detailModuleCoordinator: DetailModuleCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: DetailModuleCoordinatorProtocol.self)
    }
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }

    var getMultimediaContentUseCase: GetMultimediaContentUseCase {
        return dependenciesResolver.resolve(for: GetMultimediaContentUseCase.self)
    }
    var checkPaymentEntity: BizumCheckPaymentEntity {
        let configuration: BizumCheckPaymentConfiguration = dependenciesResolver.resolve()
        return configuration.bizumCheckPaymentEntity
    }

    var getGlobalPositionUseCase: GetGlobalPositionUseCaseAlias {
        return self.dependenciesResolver.resolve(for: GetGlobalPositionUseCaseAlias.self)
    }
    
    var actionsEnabledByAppConfigUseCase: BizumActionsAppConfigUseCase {
        return self.dependenciesResolver.resolve(for: BizumActionsAppConfigUseCase.self)
    }
    
    func performGetMultimediaContent() {
        guard bizumTransaction.hasAttachment else { return }
        self.view?.showLoading()
        let request = GetMultimediaContentInputUseCase(checkPayment: checkPaymentEntity,
                                                       operationId: bizumTransaction.operationId)
        let useCase = self.getMultimediaContentUseCase.setRequestValues(requestValues: request)
        UseCaseWrapper(with: useCase,
                       useCaseHandler: dependenciesResolver.resolve(), onSuccess: { [weak self] response in
                        self?.view?.dismissLoading(completion: {
                            self?.getMultimediaContentSuccess(response)
                        })
                       }, onError: { [weak self] _ in
                        self?.view?.dismissLoading(completion: nil)
                       })
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

    func getAppconfigActions() {
        Scenario(useCase: self.actionsEnabledByAppConfigUseCase)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                let appConfigStatus = BizumAppConfigOperationsStatus(accept: result.acceptEnabled, refund: result.refundEnabled, cancelNotRegistered: result.cancelEnabled)
                guard let transaction = self?.bizumTransaction else { return }
                self?.builder = BizumDetailBuilder(with: transaction, appConfigActionStatus: appConfigStatus)
                self?.buildView()
            }
    }
    
    func finishSetupViewModel() {
        let phone = checkPaymentEntity.phone?.trim() ?? ""
        self.bizumTransaction.resolveOrigin(phone: phone)
    }

    func buildView() {
        self.builder?.build()
        self.performGetMultimediaContent()
        guard let builderItems = builder?.items else { return }
        self.view?.showDetail(builderItems)
    }

    func trackActionTapped(_ type: BizumActionType) {
        switch type {
        case .acceptRequest:
            trackEvent(.acceptSendRequest, parameters: [:])
        case .rejectRequest:
            trackEvent(.rejectSendRequest, parameters: [:])
        case .cancelSend:
            trackEvent(.cancelSend, parameters: [:])
        case .sendAgain(let type):
            switch type {
            case .donation, .send:
                trackEvent(.sendAgain, parameters: [TrackerDimension.bizumDeliveryType: BizumDetailTrack.sendOrDonation.rawValue])
            case .purchase:
                trackEvent(.sendAgain, parameters: [TrackerDimension.bizumDeliveryType: BizumDetailTrack.purchase.rawValue])
            case .request:
                trackEvent(.sendAgain, parameters: [TrackerDimension.bizumDeliveryType: BizumDetailTrack.request.rawValue])
            case nil:
                break
            }
        case .share:
            trackEvent(.share, parameters: [:])
        case .reuseContact:
            trackEvent(.reuseContact, parameters: [:])
        case .refund:
            trackEvent(.refund, parameters: [:])
        case .cancelRequest:
            break
        }
    }

    func getContactToSendAgain() -> BizumContactEntity? {
        return self.bizumTransaction.getContacts().first
    }

    func getMoneyToSendAgain() -> BizumSendMoney {
        let amountEntity = AmountEntity(value: Decimal(bizumTransaction.amount))
        return BizumSendMoney(amount: amountEntity, totalAmount: amountEntity, concept: bizumTransaction.concept ?? "")
    }
}

extension BizumDetailPresenter: BizumDetailPresenterProtocol {

    func viewDidLoad() {
        self.getAppconfigActions()
        self.trackScreen()
        self.finishSetupViewModel()
    }

    func didSelectDismiss() {
        self.detailModuleCoordinator.didSelectDismiss()
    }

    func showImage() {
        guard let image = bizumTransaction.multimedia?.image else { return }
        self.detailModuleCoordinator.openImageDetail(image)
    }

    func actionDidTap(type: BizumActionType) {
        switch type {
        case .reuseContact:
            self.didTapReuseContact()
        case .share:
            self.didTapShare()
        case .cancelSend:
            self.didTapCancelNotRegistered()
        case .acceptRequest:
            self.didTapAcceptRequest()
        case .rejectRequest:
            self.didTapRejectRequest()
        case .refund:
            self.didTapRefund()
        case .sendAgain:
            self.didTapSendAgain()
        case .cancelRequest:
            self.didTapCancelRequest()
        }
        trackActionTapped(type)
    }

    func didTapAcceptRequest() {
        guard let entity = bizumTransaction.historicOperationEntity else { return }
        self.detailModuleCoordinator.didSelectAcceptRequest(entity)
    }
    
    func didTapRejectRequest() {
        guard let entity = bizumTransaction.historicOperationEntity else { return }
        self.detailModuleCoordinator.didSelectRejectRequest(entity)
    }
    
    func didTapReuseContact() {
        let contacts = self.bizumTransaction.getContacts()
        self.detailModuleCoordinator.didSelectReuseContact(contacts)
    }
    
    func didTapRefund() {
        guard let entity = bizumTransaction.historicOperationEntity else { return }
        self.detailModuleCoordinator.didSelectRefund(entity)
    }
    
    func didTapCancelNotRegistered() {
        guard let operation = self.bizumTransaction.historicOperationEntity else { return }
        self.detailModuleCoordinator.didSelectCancelNotRegistered(operation)
    }
    
    func didTapCancelRequest() {
        guard let operation = self.bizumTransaction.historicOperationEntity else { return }
        self.detailModuleCoordinator.didSelectCancelRequest(operation)
    }
    
    func didTapRejectSend() {
        guard let operation = self.bizumTransaction.historicOperationEntity else { return }
        self.detailModuleCoordinator.didSelectRejectSend(operation)
    }
    
    func didTapShare() {
        self.getUserName({ [weak self] userName in
            guard let self = self else { return }
            let viewModel = ShareBizumDetailViewModel(bizumTransfer: self.bizumTransaction, userName: userName)
            self.view?.didTapShare(viewModel)
        }, failure: {})
    }

    func didTapSendAgain() {
        guard let type = self.bizumTransaction.getEmitterTypeTransaction(),
              let contact = self.getContactToSendAgain(),
              let items = self.builder?.items else { return }
        self.detailModuleCoordinator.didSelectSendAgain(type, contact: contact, sendMoney: self.getMoneyToSendAgain(), items: items)
    }
}

extension BizumDetailPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: BizumDetailPage {
        return BizumDetailPage()
    }
}
