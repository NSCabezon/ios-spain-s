import TransferOperatives
import CoreFoundationLib
import SANLegacyLibrary
import UIOneComponents
import CoreDomain
import Operative
import UI

public protocol TransferActionCoordinator: AnyObject {
    func didSelectTransferBetweenAccounts(_ account: AccountEntity?, _ offer: OfferEntity?)
    func didSelectScheduledTransfers()
}

public protocol TransferActionDelegate: AnyObject {
    func didSelectTransfer(_ account: AccountEntity?)
    func didSelectOnePayFX(_ offer: OfferEntity?)
    func didSelectATMs()
    func didSelectDonations(_ account: AccountEntity?, _ offer: OfferEntity?)
    func didSelectCorreosCash(_ account: AccountEntity?, _ offer: OfferEntity?)
    func didSelectTransferAction(type: TransferActionType, account: AccountEntity?)
    func didSelectNewContact()
    func closeNewShipmentView(_ completion: @escaping (() -> Void))
}

public struct DialogConfiguration {
    public let acceptTitle: String?
    public let cancelTitle: String?
    public let title: String?
    public let body: String?
    public let source: UIViewController
    public let acceptAction: (() -> Void)?
    public let cancelAction: (() -> Void)?
    
    public init(acceptTitle: String?, cancelTitle: String?, title: String?, body: String?, source: UIViewController, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        self.acceptTitle = acceptTitle
        self.cancelTitle = cancelTitle
        self.title = title
        self.body = body
        self.source = source
        self.acceptAction = acceptAction
        self.cancelAction = cancelAction
    }
}

public protocol TransferHomeModuleCoordinatorDelegate: TransferActionDelegate {
    func showTransferDetail(_ transfer: TransferEmittedEntity, fromAccount: AccountEntity?, toAccount: AccountEntity, presentationBlock: @escaping (TransferDetailConfiguration) -> Void)
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func didSelectNewContact()
    func didSelectVirtualAssistant()
    func showDialog(configuration: DialogConfiguration)
    func handleWebView(with data: Data, title: String)
    func executeOffer(_ offer: OfferRepresentable)
    func goToWebView(configuration: WebViewConfiguration)
    func didSelectContact(contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate)
    func modifyDeferredTransfer(account: AccountEntity, transfer: TransferScheduledEntity, transferDetail: ScheduledTransferDetailEntity)
    func modifyPeriodicTransfer(account: AccountEntity, transfer: TransferScheduledEntity, transferDetail: ScheduledTransferDetailEntity)
}

public class TransferHomeModuleCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let legacyDependenciesEngine: DependenciesInjector & DependenciesResolver
    public let transferExternalDependencies: OneTransferHomeExternalDependenciesResolver
    private lazy var contactsEngine: ContactsEngineProtocol = {
        return legacyDependenciesEngine.resolve()
    }()
    
    private let newShipmentCoordinator: NewShipmentCoordinator
    private let contactSelectorCoordinator: ContactSelectorCoordinator
    private let contactsDetailCoordinator: ContactDetailCoordinator
    private let historicalTransferCoordinator: HistoricalTransferCoordinator
    private let transferDetailCoordinator: TransferDetailCoordinator
    private var childCoordinators: [BindableCoordinator] = []
    
    public init(transferExternalDependencies: OneTransferHomeExternalDependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.legacyDependenciesEngine = DependenciesDefault(father: transferExternalDependencies.resolve())
        self.transferExternalDependencies = transferExternalDependencies
        self.newShipmentCoordinator = NewShipmentCoordinator(legacyDependencies: legacyDependenciesEngine, transferExternalDependencies: transferExternalDependencies, navigationController: navigationController)
        self.contactSelectorCoordinator = ContactSelectorCoordinator(dependenciesResolver: legacyDependenciesEngine, navigationController: navigationController)
        self.contactsDetailCoordinator = ContactDetailCoordinator(dependenciesResolver: legacyDependenciesEngine, navigationController: navigationController)
        self.historicalTransferCoordinator = HistoricalTransferCoordinator(dependenciesResolver: legacyDependenciesEngine, navigationController: navigationController)
        self.transferDetailCoordinator = TransferDetailCoordinator(dependenciesResolver: legacyDependenciesEngine, navigationController: navigationController)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.legacyDependenciesEngine.resolve(for: TransferHomeViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    public func startOnInternalTransfer() {
        let transfersHomeConfiguration = self.legacyDependenciesEngine.resolve(for: TransfersHomeConfiguration.self)
        self.didSelectTransferBetweenAccounts(transfersHomeConfiguration.selectedAccount, nil)
    }
    
    func goToNewShipment(for account: AccountEntity?) {
        self.legacyDependenciesEngine.register(for: TransfersHomeConfiguration.self) { _ in
            return TransfersHomeConfiguration(selectedAccount: account, isScaForTransactionsEnabled: false)
        }
        self.newShipmentCoordinator.start()
    }
    
    func gotoTransferDetailWithConfiguration(_ configuration: TransferDetailConfiguration) {
        self.transferDetailCoordinator.goToDetail(with: configuration)
    }
    
    func reuseTransferFromAccount(_ account: AccountEntity, destination: IBANEntity, beneficiary: String) {
        self.legacyDependenciesEngine.register(for: TransfersHomeConfiguration.self) { _ in
            return TransfersHomeConfiguration(selectedAccount: account, isScaForTransactionsEnabled: false)
        }
        let homeModuleCoordinator = self.legacyDependenciesEngine.resolve(for: TransferHomeModuleCoordinatorDelegate.self)
        homeModuleCoordinator.didSelectTransferAction(type: .reuse(destination, beneficiary), account: account)
    }
    
    private func setupDependencies() {
        self.legacyDependenciesEngine.register(for: TransferHomeModuleCoordinator.self) { _ in
            return self
        }
        
        self.legacyDependenciesEngine.register(for: ContactsSortedHandlerProtocol.self) { _ in
            return ContactsSortedHandler()
        }
        
        self.legacyDependenciesEngine.register(for: TransferHomePresenterProtocol.self) { dependenciesResolver in
            return TransferHomePresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependenciesEngine.register(for: TransferHomeViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: TransferHomeViewController.self)
        }
        
        self.legacyDependenciesEngine.register(for: GetTransfersHomeUseCase.self) { _ in
            return GetTransfersHomeUseCase(dependenciesResolver: self.legacyDependenciesEngine)
        }
        
        self.legacyDependenciesEngine.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8)
        }
        
        self.legacyDependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependenciesEngine.register(for: TransferHomeViewController.self) { dependenciesResolver in
            let presenter = self.legacyDependenciesEngine.resolve(for: TransferHomePresenterProtocol.self)
            let viewController = TransferHomeViewController(nibName: "Transfer",
                                                            bundle: Bundle.module,
                                                            presenter: presenter,
                                                            dependenciesResolver: dependenciesResolver)
            presenter.view = viewController
            return viewController
        }
        
        self.legacyDependenciesEngine.register(for: GetGlobalPositionV2UseCase.self) { dependenciesResolver in
            return GetGlobalPositionV2UseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependenciesEngine.register(for: NewShipmentCoordinator.self) { _ in
            return self.newShipmentCoordinator
        }
        
        self.legacyDependenciesEngine.register(for: ScheduledTransfersCoordinator.self) { _ in
            return ScheduledTransfersCoordinator(dependenciesResolver: self.dependenciesResolver, navigationController: self.navigationController)
        }
        
        self.legacyDependenciesEngine.register(for: GetNoSepaPayeeDetailUseCase.self) { dependenciesResolver in
            return GetNoSepaPayeeDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependenciesEngine.register(for: GetFaqsUseCaseAlias.self) { dependenciesResolver in
            return GetFaqsUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependenciesEngine.register(for: SharedHandler.self) { _ in
            return SharedHandler()
        }
        
        self.legacyDependenciesEngine.register(for: ContactDetailCoordinator.self) { _ in
            return self.contactsDetailCoordinator
        }
        
        self.legacyDependenciesEngine.register(for: TransferActionCoordinator.self) { _ in
            return self
        }
        self.legacyDependenciesEngine.register(for: TransferHomeModifier.self) { dependenciesResolver in
            return TransferHomeModifier(dependenciesResolver: dependenciesResolver)
        }
        self.legacyDependenciesEngine.register(for: PreSetupInternalTransferUseCaseProtocol.self) { dependenciesResolver in
            return PreSetupInternalTransferUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.legacyDependenciesEngine.register(for: SetTransferHomeUseCaseProtocol.self) { dependenciesResolver in
            return SetTransferHomeUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}

// Remove this once the floating button is tested
extension TransferHomeModuleCoordinator: SendMoneyOperativeLauncher { }
extension TransferHomeModuleCoordinator {
    public func didSelectTestNewSendMoney() {
        self.goToSendMoney(handler: self)
    }
    func didSelectTestOneComponents() {
        let viewController = OneComponentsQAViewController(dependenciesResolver: self.legacyDependenciesEngine)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func didSelectNewInternalTransfer() {
        let internalCoordinator: InternalTransferOperativeCoordinator = transferExternalDependencies.resolve()
        internalCoordinator.start()
    }
    
    public func didSelectSendMoney() {
        self.goToSendMoney(handler: self)
    }
}

extension TransferHomeModuleCoordinator: TransferActionCoordinator {
    func didSelectHistoricalEmittedTransfers() {
        self.historicalTransferCoordinator.start()
    }
    
    public func didSelectTransferBetweenAccounts(_ account: AccountEntity?, _ offer: OfferEntity?) {
        let internalTransferLauncher: InternalTransferLauncher = self.transferExternalDependencies.resolve()
        if let account = account {
            internalTransferLauncher.set(account.representable)
        }
        internalTransferLauncher.start()
        childCoordinators.append(internalTransferLauncher)
        internalTransferLauncher.onFinish = { [weak self] in
            self?.childCoordinators.removeAll()
        }
    }
    
    public func didSelectScheduledTransfers() {
        let scheduledTransfersCoordinator = self.legacyDependenciesEngine.resolve(for: ScheduledTransfersCoordinator.self)
        scheduledTransfersCoordinator.start()
    }
    
    func didSelectContacts(_ presenter: TransferHomePresenterProtocol) {
        self.goToContacts(presenter)
    }
    
    func goToContacts(_ presenter: TransferHomePresenterProtocol) {
        self.legacyDependenciesEngine.register(for: ContactSelectorDelegate.self) { _ in
            return presenter
        }
        self.contactSelectorCoordinator.start()
    }
    
    func goToVirtualAssistant() {
        self.legacyDependenciesEngine.resolve(for: TransferHomeModuleCoordinatorDelegate.self).didSelectVirtualAssistant()
    }
    
    func didSelectContact(contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate) {
        let transferConfiguration = legacyDependenciesEngine.resolve(for: TransfersHomeConfiguration.self)
        self.legacyDependenciesEngine.register(for: ContactDetailConfiguration.self) { _ in
            return ContactDetailConfiguration(contact: contact, account: transferConfiguration.selectedAccount)
        }
        self.contactsDetailCoordinator.start(withLauncher: launcher, handleBy: delegate)
    }
    
    func showComingSoon() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}

extension TransferHomeModuleCoordinator: LegacyInternalTransferLauncher {}

extension TransferHomeModuleCoordinator: OperativeLauncherHandler {
    public var dependenciesResolver: DependenciesResolver {
        return self.legacyDependenciesEngine
    }
    
    public var operativeNavigationController: UINavigationController? {
        return navigationController
    }
    
    public func showOperativeLoading(completion: @escaping () -> Void) {
        self.showLoading(completion: completion)
    }
    
    public func hideOperativeLoading(completion: @escaping () -> Void) {
        self.dismissLoading(completion: completion)
    }
    
    public func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        let delegate = self.legacyDependenciesEngine.resolve(for: TransferHomeModuleCoordinatorDelegate.self)
        let viewController = self.legacyDependenciesEngine.resolve(for: TransferHomeViewController.self)
        delegate.showDialog(configuration: DialogConfiguration(acceptTitle: "generic_button_accept",
                                                               cancelTitle: nil,
                                                               title: keyTitle,
                                                               body: keyDesc,
                                                               source: viewController,
                                                               acceptAction: nil,
                                                               cancelAction: nil))
        completion?()
    }
}

extension TransferHomeModuleCoordinator: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        self.navigationController?.topViewController ?? UIViewController()
    }
}
