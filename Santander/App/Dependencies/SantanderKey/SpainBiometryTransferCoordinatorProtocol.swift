import RetailLegacy
import BiometryValidator
import CoreFoundationLib
import UI
import UIKit

public class SpainSanKeyTransferDependencies {
    private let drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    private lazy var spainSanKeyCoordinator: SpainSanKeyTransferCoordinator = {
        return SpainSanKeyTransferCoordinator(dependenciesResolver: self.dependenciesEngine)
    }()
    
    init(drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
    }
    
    func registerDependencies() {
        self.dependenciesEngine.register(for: SpainSanKeyTransferCoordinatorProtocol.self) { _ in
            return self.spainSanKeyCoordinator
        }
        self.dependenciesEngine.register(for: SanKeyNavigatorProtocol.self) { _ in
            return self.spainSanKeyCoordinator
        }
        self.dependenciesEngine.register(for: BiometryValidatorModuleCoordinatorDelegate.self) { _ in
            return self.spainSanKeyCoordinator
        }
    }
}

public protocol SpainSanKeyTransferCoordinatorProtocol {
    func start()
}

public class SpainSanKeyTransferCoordinator {
    var dependenciesResolver: DependenciesResolver
    weak var delegate: SanKeyValidatorDelegate?
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension SpainSanKeyTransferCoordinator: SpainSanKeyTransferCoordinatorProtocol {
    public func start() {
        
    }
}

extension SpainSanKeyTransferCoordinator: SanKeyNavigatorProtocol {
    public func openSanKeyNavigatorFrom(_ navController: UINavigationController,
                                        delegate: SanKeyValidatorDelegate) {
        self.delegate = delegate
        let coordinator = BiometryValidatorModuleCoordinator(
            dependenciesResolver: dependenciesResolver,
            navigationController: navController)
        coordinator.start()
    }
}

extension SpainSanKeyTransferCoordinator: BiometryValidatorModuleCoordinatorDelegate {
    public func success(deviceToken: String, footprint: String, onCompletion: @escaping (Bool, String?) -> Void) {
        delegate?.success(deviceToken: deviceToken, footprint: footprint, onCompletion: onCompletion)
    }
    
    public func continueSignProcess() {
        delegate?.continueSignProcess()
    }
    
    public func biometryDidSuccessfullyDisappear() {
        delegate?.biometryDidSuccessfullyDisappear()
    }
    
    public func biometryDidDisappear(withError error: String?) {
        delegate?.biometryDidDisappear(withError: error)
    }
    
    public func getScreen() -> String {
        delegate?.getScreen() ?? ""
    }
}
