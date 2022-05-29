import UIKit.UINavigationController
import CoreFoundationLib

/// A protocol that should implement every module coordinator (for any feature)
public protocol ModuleCoordinator {
    var navigationController: UINavigationController? { get set }
    func start()
}

public protocol ModuleInjectableCoordinator {
    func start(navigationController: UINavigationController)
}

/// A protocol that should implement every module coordinator that needs any precondition to be shown
public protocol LauncherModuleCoordinator {
    var navigationController: UINavigationController? { get set }
    func start(withLauncher launcher: ModuleLauncher, handleBy delegate: ModuleLauncherDelegate)
}

extension ModuleLauncherDelegate where Self: LoadingViewPresentationCapable & OldDialogViewPresentationCapable {
    
    public func launcherDidStar() {
        self.showLoading()
    }
    
    public func launcherDidFinishSuccessfully(completion: @escaping () -> Void) {
        self.dismissLoading(completion: completion)
    }
    
    public func launcherDidFinish<Error: StringErrorOutput>(withDependenciesResolver dependenciesResolver: DependenciesResolver, for error: UseCaseError<Error>) {
        self.dismissLoading {
            self.showOldDialog(
                withDependenciesResolver: dependenciesResolver,
                for: error,
                acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil),
                cancelAction: nil,
                isCloseOptionAvailable: false
            )
        }
    }
}

/// A protocol that should implement every module coordinator (for many features)
public protocol ModuleSectionedCoordinator {
    associatedtype SectionType: CaseIterable
    var navigationController: UINavigationController? { get set }
    func start(_ section: SectionType)
}

public protocol ModuleSectionedInjectableCoordinator {
    associatedtype SectionType: CaseIterable
    func start(_ section: SectionType, navigationController: UINavigationController)
}
