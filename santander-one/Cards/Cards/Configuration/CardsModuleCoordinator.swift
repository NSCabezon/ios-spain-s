//
//  CardsModuleCoordinator.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/22/19.
//

import CoreFoundationLib
import UI
public class CardsModuleCoordinator: ModuleSectionedCoordinator {
    
    public weak var navigationController: UINavigationController?
    private let homeCoordinator: CardsHomeModuleCoordinator
    private var applePayWelcomeCoordinator: ApplePayWelcomeCoordinator
    private var cardBoardingCoordinator: CardBoardingCoordinator
    private var cardBoardingWelcomeCoordinator: CardBoardingWelcomeCoordinator
    private var directMoneyCoordinator: DirectMoneyCoordinator
    private let externalDependencies: CardExternalDependenciesResolver
    public enum CardsSection: CaseIterable {
        case home
        case detail
        case applePay
        case cardBoarding
        case cardBoardingWelcome
        case directMoney
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController, externalDependencies: CardExternalDependenciesResolver) {
        self.externalDependencies = externalDependencies
        self.navigationController = navigationController
        self.homeCoordinator = CardsHomeModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController, externalDependencies: externalDependencies)
        self.applePayWelcomeCoordinator = ApplePayWelcomeCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
        self.cardBoardingCoordinator = CardBoardingCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController, externalDependencies: externalDependencies)
        self.cardBoardingWelcomeCoordinator = CardBoardingWelcomeCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController, externalDependencies: externalDependencies)
        self.directMoneyCoordinator = DirectMoneyCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
    }
    
    public func start(_ section: CardsSection) {
        switch section {
        case .home:
            self.homeCoordinator.start()
        case .detail:
            self.homeCoordinator.startInTransaction()
        case .applePay:
            self.applePayWelcomeCoordinator.start()
        case .cardBoardingWelcome:
            self.cardBoardingWelcomeCoordinator.start()
        case .directMoney:
            self.directMoneyCoordinator.start()
        default:
            break
        }
    }
    
    public func start(_ section: CardsSection, withLauncher launcher: ModuleLauncher, handleBy delegate: ModuleLauncherDelegate) {
        switch section {
        case .cardBoarding:
            self.cardBoardingCoordinator.start(withLauncher: launcher, handleBy: delegate)
        default:
            self.start(section)
        }
    }
}
