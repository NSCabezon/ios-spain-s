//
//  PhotoThemeSelectorCoordinator.swift
//  PersonalArea
//
//  Created by alvola on 09/03/2020.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary

final class PhotoThemeSelectorCoordinator: ModuleCoordinator {

    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let photoThemeView = dependenciesEngine.resolve(for: PhotoThemeSelectorViewProtocol.self)
        self.navigationController?.blockingPushViewController(photoThemeView, animated: true)
    }
    
    func end() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: PhotoThemeSelectorPresenterProtocol.self) { [weak self] dependenciesResolver in
            let presenter = PhotoThemeSelectorPresenter(resolver: dependenciesResolver)
            presenter.dataManager = self?.dependenciesEngine.resolve(for: PersonalAreaDataManagerProtocol.self)
            presenter.moduleCoordinator = self
            return presenter
        }
        self.dependenciesEngine.register(for: LoadBackgroundImagesUseCase.self) { resolver in
            return LoadBackgroundImagesUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: PhotoThemeSelectorViewProtocol.self) { dependenciesResolver in
            var presenter: PhotoThemeSelectorPresenterProtocol = dependenciesResolver.resolve(for: PhotoThemeSelectorPresenterProtocol.self)
            let viewController = PhotoThemeSelectorViewController(nibName: "PhotoThemeSelectorViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            
            return viewController
        }
    }
}
