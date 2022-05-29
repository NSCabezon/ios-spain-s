import Foundation
import CoreFoundationLib

protocol ScheduledTransfersPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: ScheduledTransfersViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectNewShipment()
    func didSelectScheduledTransfer(_ viewModel: ScheduledTransferViewModelProtocol)
    func didSelectPeriodicTransfer(_ viewModel: PeriodicTransferViewModelProtocol)
    func didChangeType(_ page: Int)
}

final class ScheduledTransfersPresenter {

    weak var view: ScheduledTransfersViewProtocol?
    let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    private var coordinatorDelegate: ScheduledTransfersCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: ScheduledTransfersCoordinatorDelegate.self)
    }

    private var coordinator: ScheduledTransfersCoordinator {
        self.dependenciesResolver.resolve(for: ScheduledTransfersCoordinator.self)
    }

    private var accountConfiguration: TransfersHomeConfiguration {
        self.dependenciesResolver.resolve(for: TransfersHomeConfiguration.self)
    }

    private lazy var getScheduledAndPeriodicTransfersManager: GetScheduledAndPeriodicTransfersManager = {
        return GetScheduledAndPeriodicTransfersManager(dependenciesResolver: dependenciesResolver, delegate: self)
    }()

    private lazy var detailUseCaseManager: GetScheduledTransfersManager = {
        GetScheduledTransfersManager(dependenciesResolver: dependenciesResolver)
    }()
    
    private lazy var detailUseCase: GetScheduledTransferDetailUseCase = {
        GetScheduledTransferDetailUseCase(dependenciesResolver: dependenciesResolver)
    }()

    private var detailConfigurationBuilder: ScheduledTransferDetailConfigurationBuilder {
        ScheduledTransferDetailConfigurationBuilder()
    }

    private var baseURLProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var selectedTransferModifier: ScheduledTransfersSelectedTransferModifierProtocol {
        return self.dependenciesResolver.resolve()
    }

    private let periodicParameterString = "periodica"
    private let scheduledParameterString = "diferida"
}

extension ScheduledTransfersPresenter: ScheduledTransfersPresenterProtocol {
    func viewDidLoad() {
        self.getScheduledAndPeriodicTransfersManager.execute()
        self.trackScreen()
    }

    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }

    func didSelectDismiss() {
        self.coordinatorDelegate.didSelectDismiss()
    }

    func didSelectNewShipment() {
        trackEvent(.new, parameters: [:])
        self.coordinatorDelegate
            .didSelectNewShipment(for: accountConfiguration.selectedAccount)
    }

    func didSelectScheduledTransfer(_ viewModel: ScheduledTransferViewModelProtocol) {
        trackEvent(.detail, parameters: [:])
        if let selectedInfo = selectedTransferModifier.scheduledTranferDetailFor(viewModel) {
            self.didSelectScheduledTransferDetail(for: selectedInfo.entity,
                                                  account: selectedInfo.account,
                                                  originAcount: accountConfiguration.selectedAccount,
                                                  scheduledTransferId: selectedInfo.scheduledTransferId)
        }
    }

    func didSelectPeriodicTransfer(_ viewModel: PeriodicTransferViewModelProtocol) {
        trackEvent(.detail, parameters: [:])
        if let selectedInfo = selectedTransferModifier.periodicTranferDetailFor(viewModel) {
            self.didSelectScheduledTransferDetail(for: selectedInfo.entity,
                                                  account: selectedInfo.account,
                                                  originAcount: accountConfiguration.selectedAccount,
                                                  scheduledTransferId: selectedInfo.scheduledTransferId)
        }
    }

    func didChangeType(_ page: Int) {
        let dimensionValueString = (page == 0) ? periodicParameterString : scheduledParameterString
        trackEvent(.type, parameters: [.scheduledTransferType: dimensionValueString])
    }
}

extension ScheduledTransfersPresenter: GetScheduledAndPeriodicTransfersManagerDelegate {
    func set(scheduledtransfers: [ScheduledTransferViewModelProtocol], periodicTransfers: [PeriodicTransferViewModelProtocol]) {
        let periodicViewModel = ScheduledTransferEmptyViewModel(
            titleLabelKey: "transfer_title_emptyPeriodic",
            descriptionLabelKey: "transfer_text_emptyPeriodic"
        )
        let scheduledViewModel = ScheduledTransferEmptyViewModel(
            titleLabelKey: "transfer_title_emptyScheduled",
            descriptionLabelKey: "transfer_text_emptyScheduled"
        )
        self.view?.setEmptyPeriodicViewModel(periodicViewModel)
        self.view?.setEmptyScheduledViewModel(scheduledViewModel)
        self.view?.showScheduledTransfer(scheduledtransfers)
        self.view?.showPeriodicTransfer(periodicTransfers)
    }

    func setNoResult() {
        self.view?.showEmptyResultView()
    }
}

extension ScheduledTransfersPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }

    var trackerPage: SendMoneyScheduledPage {
        return SendMoneyScheduledPage()
    }
}

private extension ScheduledTransfersPresenter {

    func didSelectScheduledTransferDetail(for entity: ScheduledTransferRepresentable,
                                          account: AccountEntity,
                                          originAcount: AccountEntity?,
                                          scheduledTransferId: String?) {
        view?.presentLoading()
        let input = GetScheduledTransferDetailUseCaseInput(account: account,
                                                           transfer: entity.transferEntity,
                                                           scheduledTransferId: scheduledTransferId)
        detailUseCaseManager.getScheduledTransferDetail(input: input) { [weak self] detail, error  in
            self?.view?.hideLoading({
                if let errorDescription = error?.getErrorDesc() {
                    self?.view?.showErrorDialogWithMessage(errorDescription)
                    return
                } else if error == nil && detail == nil {
                    self?.coordinator.showGenericError()
                    return
                }
                guard let sepaRepository = self?.dependenciesResolver.resolve(for: SepaInfoRepositoryProtocol.self),
                      let detailEntity = detail,
                      detailEntity.isValidForDetail else {
                    self?.coordinator.showGenericError()
                    return
                }
                guard let configuration = self?.detailConfigurationBuilder.configureWith(configuration: ScheduledTransferDetailConfigurationBuilder
                                                                                            .ScheduledTransferDetailConfiguration(scheduledTransferDetail: detail,
                                                                                                                                  transfer: entity,
                                                                                                                                  account: account,
                                                                                                                                  originAccount: originAcount,
                                                                                                                                  baseURL: self?.baseURLProvider.baseURL ?? "",
                                                                                                                                  sepaRepository: sepaRepository,
                                                                                                                                  withBalance: scheduledTransferId == nil)) else { return }
                self?.coordinator.gotoTransferDetailWithConfiguration(configuration)
            })
        }
    }
}
