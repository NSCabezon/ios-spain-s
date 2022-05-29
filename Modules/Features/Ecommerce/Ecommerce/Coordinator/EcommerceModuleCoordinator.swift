import CoreFoundationLib
import UI

public protocol EcommerceMainModuleCoordinatorDelegate: AnyObject {
    func openUrl(_ url: String)
    func handleOpinator(_ opinator: OpinatorInfoRepresentable)
}

public final class EcommerceModuleCoordinator: ModuleSectionedCoordinator {
    public var navigationController: UINavigationController?
    private var dependenciesResolver: DependenciesResolver
    private lazy var coordinator: EcommerceCoordinator = {
        EcommerceCoordinator(dependenciesResolver: self.dependenciesResolver,
                             navigationController: self.navigationController)
    }()
    private lazy var fintechCoordinator: FintechTPPConfirmationCoordinator = {
        return FintechTPPConfirmationCoordinator(dependenciesResolver: self.dependenciesResolver,
                                                 navigationController: self.navigationController)
    }()
    
    public enum EcommerceSection: CaseIterable {
        public static var allCases: [EcommerceSection] {
            return [.mainDefault, .mainPushNotification, .fintechTPPConfirmation(nil)]
        }
        case mainDefault
        case mainPushNotification
        case fintechTPPConfirmation(_ userAuthentication: FintechUserAuthenticationRepresentable?)
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependenciesResolver = DependenciesDefault(father: dependenciesResolver)
    }
    
    // MARK: - Module Coordinator Actions
    
    public func start(_ section: EcommerceSection) {
        switch section {
        case .fintechTPPConfirmation(let userAuthentication):
            self.fintechCoordinator.start(userAuthentication)
        default:
            self.coordinator.start(section)
        }
    }
}
