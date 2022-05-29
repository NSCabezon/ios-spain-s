//  
//  SceneCoordinator.swift
//  TransferOperatives
//
//  Created by Francisco del Real Escudero on 3/12/21.
//

import TransferOperatives
import CoreFoundationLib
import CoreDomain
import UI

protocol OneTransferHomeCoordinator: BindableCoordinator, ModuleLauncherDelegate {
    func showMenu()
    func showSearch()
    func showTooltip()
    func showComingSoon()
    func goToNewContact()
    func goToNewTransfer()
    func goToNewInternalTransfer()
    func goToContactsList()
    func goToSeeHistorical()
    func goToContactDetail(contact: PayeeRepresentable, launcher: ModuleLauncher)
    func goToPastTransfer(transfer: TransferRepresentable, launcher: ModuleLauncher)
    func goToOffer(_ offer: OfferRepresentable?)
    func goToAtm()
    func goToScheduledTransfers()
    func goToReuse()
    func goToCustomSendMoneyAction(_ actionType: SendMoneyHomeActionType)
    func goToVirtualAssistant()
}

final class DefaultOneTransferHomeCoordinator: OneTransferHomeCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: OneTransferHomeExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()

    init(dependencies: OneTransferHomeExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultOneTransferHomeCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func goToSeeHistorical() {
        externalDependencies.historicalEmitters().start()
    }
    
    func goToPastTransfer(transfer: TransferRepresentable, launcher: ModuleLauncher) {
        externalDependencies.transferDetail().start()
    }
    
    func goToNewContact() {
        externalDependencies.newContact().start()
    }
    
    func goToNewInternalTransfer() {
        let coordinator: InternalTransferOperativeCoordinator = externalDependencies.resolve()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToNewTransfer() {
        externalDependencies.newTransfer().didSelectTestNewSendMoney()
    }
    
    func goToContactsList() {
        externalDependencies.contactList().start()
    }
    
    func showTooltip() {
        externalDependencies.transferHomeTooltip().start()
    }
    
    func showSearch() {
        externalDependencies.globalSearchCoordinator().start()
    }
    
    func showComingSoon() {
        externalDependencies.comingSoonCoordinator().start()
    }
    
    func showMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToContactDetail(contact: PayeeRepresentable, launcher: ModuleLauncher) {
        let moduleLauncherDelegate: ModuleLauncherDelegate = self
        let coordinator = externalDependencies.contactDetail()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToCustomSendMoneyAction(_ actionType: SendMoneyHomeActionType) {
        switch actionType {
        case .custom(let identifier, _, _, _, _):
            let coordinator = externalDependencies
                .resolveCustomSendMoneyActionCoordinator()
                .set(identifier)
            coordinator.start()
            append(child: coordinator)
        default: break
        }
    }
    
    func goToOffer(_ offer: OfferRepresentable?) {
        externalDependencies.resolveOfferCoordinator().set(offer).start()
    }
    
    func goToAtm() {
        externalDependencies.resolveAtmCoordinator().start()
    }
    
    func goToReuse() {
        externalDependencies.resolveReuseCoordinator().start()
    }
    
    func goToScheduledTransfers() {
        externalDependencies.resolveScheduledTransfersCoordinator().start()
    }
    
    func goToVirtualAssistant() {
        externalDependencies.virtualAssistant().start()
    }
}

extension DefaultOneTransferHomeCoordinator: ModuleLauncherDelegate {
    func launcherDidFinish<Error>(withDependenciesResolver dependenciesResolver: DependenciesResolver, for error: UseCaseError<Error>) {
        dismiss()
    }
}

extension DefaultOneTransferHomeCoordinator: LoadingViewPresentationCapable & OldDialogViewPresentationCapable {
    var associatedLoadingView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
    
    var associatedOldDialogView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
    
    var associatedGenericErrorDialogView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
}

private extension DefaultOneTransferHomeCoordinator {
    struct Dependency: OneTransferHomeDependenciesResolver {
        let dependencies: OneTransferHomeExternalDependenciesResolver
        let coordinator: OneTransferHomeCoordinator
        let dataBinding = DataBindingObject()
        var external: OneTransferHomeExternalDependenciesResolver {
            return dependencies
        }
        func resolve() -> OneTransferHomeCoordinator {
            return coordinator
        }
    
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
