import CoreFoundationLib
import UI
import SANLegacyLibrary
import Operative
import CoreDomain

public protocol BillHomeModuleCoordinatorDelegate: AnyObject {
    func didSelectSearch()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectTimeLine()
    func didSelectPayment(accountEntity: AccountEntity?, type: BillsAndTaxesTypeOperativePayment?)
    func didSelectDirectDebit(accountEntity: AccountEntity?)
    func didSelectLastBill(detail: LastBillDetail, detailList: [LastBillDetail])
    func didSelectReturnReceipt(bill: LastBillEntity, billDetail: LastBillDetailEntity)
    func didSelectSeePDF(_ document: Data)
    func showAlertDialog(body: String?)
    func showAlertDialog(title: String?, body: String?)
    func goToBillFinancing(_ offer: OfferEntity)
}

protocol BillHomeCoordinatorProtocol {
    func didSelectSearch()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectTimeLine()
    func didSelectSeePDF(_ document: Data)
    func didSelectLastBill(detail: LastBillDetail, detailList: [LastBillDetail])
    func didSelectReturnReceipt(bill: LastBillEntity, billDetail: LastBillDetailEntity)
    func showAlertDialog(body: String?)
    func goToDirectDebit(with account: AccountEntity?)
    func goToPayment(_ isBillEmitterPaymentEnable: Bool)
    func goToFilters(filter: BillFilter?)
    func goToFutureBill(_ bill: AccountFutureBillRepresentable, in bills: [AccountFutureBillRepresentable], for entity: AccountEntity)
    func goToBillFinancing(_ offerEntity: OfferEntity)
}

public class BillHomeModuleCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let directDebitCoordinator: DirectDebitCoordinator
    private let paymentCoordinator: PaymentCoordinator
    private let nextReceiptsCoordinator: NextReceiptsDetailCoordinator
    private var delegate: BillHomeModuleCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: BillHomeModuleCoordinatorDelegate.self)
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.directDebitCoordinator = DirectDebitCoordinator(
            dependenciesResolver: self.dependenciesEngine,
            navigationController: navigationController
        )
        self.paymentCoordinator = PaymentCoordinator(
            dependenciesResolver: self.dependenciesEngine,
            navigationController: navigationController
        )
        self.nextReceiptsCoordinator = NextReceiptsDetailCoordinator(
            dependenciesResolver: self.dependenciesEngine,
            navigationController: self.navigationController
        )
        self.setupDependencies()
    }
    
    lazy var presenter: BillHomePresenter = {
        return BillHomePresenter(dependenciesResolver: self.dependenciesEngine)
    }()
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: BillHomeViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: BillHomeModuleCoordinator.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: BillHomePresenterProtocol.self) { _ in
            return self.presenter
        }

        self.dependenciesEngine.register(for: BillSearchFiltersDelegate.self) { _ in
            return self.presenter
        }
        
        self.dependenciesEngine.register(for: BillHomeViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: BillHomeViewController.self)
        }
        
        self.dependenciesEngine.register(for: GetAccountUseCase.self) { dependenciesResolver in
            return GetAccountUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetLastBillUseCase.self) { dependenciesResolver in
            return GetLastBillUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetLastBillSuperUseCase.self) { dependenciesResolver in
            return GetLastBillSuperUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetFutureBillUseCase.self) { dependenciesResolver in
            return GetFutureBillUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetFutureBillSuperUseCase.self) {dependenciesResolver in
            return GetFutureBillSuperUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetGlobalPositionV2UseCase.self) { dependenciesResolver in
            return GetGlobalPositionV2UseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetAppConfigurationUseCase.self) { dependenciesResolver in
            return GetAppConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetDetailBillUseCase.self) { dependenciesResolver in
            return GetDetailBillUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetBillPdfDocumentUseCase.self) { dependenciesResolver in
            return GetBillPdfDocumentUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: BillHomeCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: BillHomeViewController.self) { dependenciesResolver in
            var presenter: BillHomePresenterProtocol = dependenciesResolver.resolve(for: BillHomePresenterProtocol.self)
            let viewController = BillHomeViewController(nibName: "Bills", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension BillHomeModuleCoordinator: BillHomeCoordinatorProtocol {
    func didSelectSearch() {
        self.delegate.didSelectSearch()
    }
    
    func didSelectMenu() {
        self.delegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.delegate.didSelectDismiss()
    }
    
    func didSelectTimeLine() {
        self.delegate.didSelectTimeLine()
    }
    
    func didSelectSeePDF(_ document: Data) {
        self.delegate.didSelectSeePDF(document)
    }
    
    func didSelectLastBill(detail: LastBillDetail, detailList: [LastBillDetail]) {
        self.delegate.didSelectLastBill(detail: detail, detailList: detailList)
    }
    
    func didSelectReturnReceipt(bill: LastBillEntity, billDetail: LastBillDetailEntity) {
        self.delegate.didSelectReturnReceipt(bill: bill, billDetail: billDetail)
    }
    
    func showAlertDialog(body: String?) {
        self.delegate.showAlertDialog(body: body)
    }
    
    func goToDirectDebit(with account: AccountEntity?) {
        self.dependenciesEngine.register(for: DirectDebitConfiguration.self) { _ in
            return DirectDebitConfiguration(account: account)
        }
        self.directDebitCoordinator.start()
    }
    
    func goToPayment(_ isBillEmitterPaymentEnable: Bool) {
        self.dependenciesEngine.register(for: PaymentConfiguration.self) { _ in
            return PaymentConfiguration(isBillEmitterPaymentEnable)
        }
        self.paymentCoordinator.start()
    }
    
    func goToFilters(filter: BillFilter?) {
        self.dependenciesEngine.register(for: FilterConfiguration.self) { _ in
            return FilterConfiguration(filter: filter)
        }
        BillSearchFiltersCoordinator(
            dependenciesResolver: self.dependenciesEngine,
            navigationController: self.navigationController
        ).start()
    }
    
    func goToFutureBill(_ bill: AccountFutureBillRepresentable, in bills: [AccountFutureBillRepresentable], for entity: AccountEntity) {
        self.dependenciesEngine.register(for: NextReceiptsDetailConfiguration.self) { _ in
            return NextReceiptsDetailConfiguration(bill, in: bills, for: entity)
        }
        nextReceiptsCoordinator.start()
    }
    
    func goToBillFinancing(_ offerEntity: OfferEntity) {
        delegate.goToBillFinancing(offerEntity)
    }
}

extension BillHomeModuleCoordinator: BillEmittersPaymentLauncher {}

extension BillHomeModuleCoordinator: OperativeLauncherHandler {
    public var operativeNavigationController: UINavigationController? {
        return self.navigationController
    }
    
    public var dependenciesResolver: DependenciesResolver {
        return self.dependenciesEngine
    }
    
    public func showOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    public func hideOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    public func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        let delegate = self.dependenciesEngine.resolve(for: BillHomeModuleCoordinatorDelegate.self)
        delegate.showAlertDialog(title: keyTitle, body: keyDesc)
        completion?()
    }
}
