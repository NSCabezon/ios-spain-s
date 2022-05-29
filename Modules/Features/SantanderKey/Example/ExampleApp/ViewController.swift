//
//  ViewController.swift
//  ExampleApp
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import UIKit
import QuickSetup
import SantanderKey
import UI
import CoreDomain
import CoreTestData
import CoreFoundationLib
import OpenCombine

class ViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var goToSKFirstButton: UIButton!
    let rootNavigationController = UINavigationController()
    
    var childCoordinators: [Coordinator] = []
    
    override func viewDidAppear(_ animated: Bool) {
        UIStyle.setup()
        activityIndicator.isHidden = true
        goToSKFirstButton.isHidden = false
        super.viewDidAppear(animated)
        Toast.enable()
    }
    
    @IBAction func gotoSKModule(_ sender: Any) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        goToSKFirstButton.isHidden = true
        rootNavigationController.modalPresentationStyle = .fullScreen
        self.present(rootNavigationController, animated: false, completion: {
            self.goToSKFirst()
        })
    }
    
    private lazy var dependenciesResolver: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: UINavigationController.self) { _ in
            return self.rootNavigationController
        }
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        return defaultResolver
    }()
}

extension ViewController {
    
    func goToSKFirst() {
        let dependencies = ModuleDependencies(dependenciesResolver: dependenciesResolver)
        dependencies.skFirstStepOnboardingCoordinator().start()
    }
}

//MARK: Loans dependenceies

class ModuleDependencies: SKExternalDependenciesResolver {
    func resolve() -> DefaultSKOperativeCoordinator {
        DefaultSKOperativeCoordinator(dependencies: self)
    }
    
    func resolve() -> CompilationProtocol {
        CompilationMock()
    }
    
    var dependenciesResolver: DependenciesInjector & DependenciesResolver
    
    init(dependenciesResolver: DependenciesInjector & DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func resolve() -> UINavigationController {
        return dependenciesResolver.resolve(for: UINavigationController.self)
    }
    
    func resolve() -> DependenciesResolver {
        return dependenciesResolver
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> GetCandidateOfferUseCase {
        return GetCandidateOfferUseCaseMock()
    }
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        return ToastCoordinator("")
    }

    func resolve() -> LocalAuthenticationPermissionsManagerProtocol {
        return LocalAuthenticationPermissionsManagerMock()
    }
    
    func SKCardSelectorCoordinator() -> BindableCoordinator {
        return dependenciesResolver.resolve()
    }
}

class GetCandidateOfferUseCaseMock: GetCandidateOfferUseCase {
    var fetchCandidateOfferPublisherCalled: Bool = false
    
    func fetchCandidateOfferPublisher(location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable, Error> {
        fetchCandidateOfferPublisherCalled = true
        let offer = OfferRepresentableMock(identifier: "", transparentClosure: true, productDescription: "", rulesIds: [""])
        return Just(offer).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    struct OfferRepresentableMock: OfferRepresentable {
        var pullOfferLocation: PullOfferLocationRepresentable?
        var bannerRepresentable: BannerRepresentable?
        var action: OfferActionRepresentable?
        var id: String?
        var identifier: String
        var transparentClosure: Bool
        var productDescription: String
        var rulesIds: [String]
        var startDateUTC: Date?
        var endDateUTC: Date?
    }
}
