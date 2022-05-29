import Operative
import CoreFoundationLib
import UI

public protocol PersonalManagerMainModuleCoordinatorDelegate: class {
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectSearch()
    func canOpenUrl(_ url: String) -> Bool
    func open(url: String)
    func openAppStore()
    func openChatWith(configuration: WebViewConfiguration)
    func handleOpinator(_ opinator: OpinatorInfoRepresentable)
    func didSelectOffer(offer: OfferEntity)
    func showLoading(completion: (() -> Void)?)
    func hideLoading(completion: (() -> Void)?)
    func showDialog(acceptTitle: LocalizedStylableText?, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText?, showsCloseButton: Bool, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?)
}

public protocol ModuleCoordinatorReplacer {
    func startReplacingCurrent()
}

public protocol ModuleSectionInternalCoordinator: class {
    func switchToChildSection(_ section: PersonalManagerSection)
}

public enum PersonalManagerSection: CaseIterable {
    case withoutManager
    case withManager
}

public final class PersonalManagerModuleCoordinator: ModuleSectionedCoordinator, ModuleSectionInternalCoordinator {
    public weak var navigationController: UINavigationController?
    private let withManagercoordinator: WithPersonalManagerModuleCoordinator & ModuleCoordinatorReplacer
    private let noManagerCoordinator: NoPersonalManagerCoordinator & ModuleCoordinatorReplacer
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.withManagercoordinator = WithPersonalManagerModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
        self.noManagerCoordinator = NoPersonalManagerCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
        self.withManagercoordinator.coordinator = self
        self.noManagerCoordinator.coordinator = self
    }
    
    public func start(_ section: PersonalManagerSection) {
        switch section {
        case .withoutManager:
            return self.noManagerCoordinator.start()
        case .withManager:
            return self.withManagercoordinator.start()
        }
    }
    
    public func switchToChildSection(_ section: PersonalManagerSection) {
        switch section {
        case .withManager:
            withManagercoordinator.startReplacingCurrent()
        case .withoutManager:
            noManagerCoordinator.startReplacingCurrent()
        }
    }
}
