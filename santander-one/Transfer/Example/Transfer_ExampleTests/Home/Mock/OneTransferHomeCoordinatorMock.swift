import CoreFoundationLib
import CoreDomain
import UIKit
import UI
@testable import Transfer

class OneTransferHomeCoordinatorMock: BindableCoordinator, OneTransferHomeCoordinator {
    lazy var dataBinding: DataBinding = dependencies.resolve()
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    var navigationController: UINavigationController?
    private var dependencies: OneTransferHomeDependenciesResolver
    
    var didGoToTransfer = false
    var didGoToSwitches = false
    var didGoToATM = false
    var didGoToScheduleTransfers = false
    var didGoToCustome = false
    var didGoToReuse = false
    var didGoToContactList = false
    var didGoToHistorical = false
    var didGoToPastTransfer = false
    var isPastTransferEmitted = false
    var isPastTransferReceived = false
    var didGoToMenu = false
    var didGoToSearch = false
    var didGoToTooltip = false
    var didGoToNewContact = false
    var didGoToContactDetail = false
    var lastFavoriteId: String?
    var didGoToClose = false
    var didGoToVirtualAssistant = false

    var executedOfferId = ""

    init(dependencies: OneTransferHomeDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func start() {}
    
    func dismiss() {
        didGoToClose = true
    }
    
    func showMenu() {
        didGoToMenu = true
    }
    
    func showSearch() {
        didGoToSearch = true
    }
    
    func goToNewInternalTransfer() {
        didGoToSwitches = true
    }
    
    func showTooltip() {
        didGoToTooltip = true
    }
    
    func goToNewContact() {
        didGoToNewContact = true
    }
    
    func goToNewTransfer() {
        didGoToTransfer = true
    }
    
    func goToContactsList() {
        didGoToContactList = true
    }
    
    func goToSeeHistorical() {
        didGoToHistorical = true
    }
    
    func goToContactDetail(contact: PayeeRepresentable, launcher: ModuleLauncher) {
        didGoToContactDetail = true
        lastFavoriteId = contact.payeeAlias
    }
    
    func goToPastTransfer(transfer: TransferRepresentable, launcher: ModuleLauncher) {
        didGoToPastTransfer = true
        if transfer.typeOfTransfer == .emitted {
            isPastTransferEmitted = true
        } else if transfer.typeOfTransfer == .received {
            isPastTransferReceived = true
        }
    }
    
    func goToOffer(_ offer: OfferRepresentable?) {
        executedOfferId = offer?.id ?? "no_offer"
    }
    
    func goToTransferBetweenAccounts() {
        didGoToSwitches = true
    }
    
    func goToAtm() {
        didGoToATM = true
    }
    
    func goToScheduledTransfers() {
        didGoToScheduleTransfers = true
    }
    
    func goToReuse() {
        didGoToReuse = true
    }
    
    func goToCustomSendMoneyAction(_ actionType: SendMoneyActionType) {
        didGoToCustome = true
    }
    
    func goToVirtualAssistant() {
        didGoToVirtualAssistant = true
    }
    
    func launcherDidStar() {}
    
    func launcherDidFinishSuccessfully(completion: @escaping () -> Void) {
        completion()
    }
    
    func launcherDidFinish<Error>(withDependenciesResolver dependenciesResolver: DependenciesResolver, for error: UseCaseError<Error>) where Error : StringErrorOutput {}
}
