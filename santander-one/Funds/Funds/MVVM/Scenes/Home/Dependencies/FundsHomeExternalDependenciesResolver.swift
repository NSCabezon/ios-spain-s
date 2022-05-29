//
//  FundsHomeExternalDependenciesResolver.swift
//  Funds
//

import UI
import CoreDomain
import CoreFoundationLib

public protocol FundsHomeExternalDependenciesResolver: ShareDependenciesResolver, NavigationBarExternalDependenciesResolver {
    var common: FundsCommonExternalDependenciesResolver { get }
    func fundsHomeCoordinator() -> BindableCoordinator
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> FundsHomeHeaderModifier?
    func resolve() -> GetFundDetailUsecase
    func resolve() -> FundReactiveRepository
    func resolve() -> GetFundOptionsUsecase
    func resolve() -> StringLoader
    func resolve() -> FundsDetailFieldsModifier?
    func resolve() -> TrackerManager
    func resolve() -> FundMovementDetailFieldsModifier?
    func fundCustomeOptionCoordinator() -> BindableCoordinator
    func fundTransactionsCoordinator() -> BindableCoordinator
    func fundsTransactionsFilterCoordinator() -> BindableCoordinator
}

public extension FundsHomeExternalDependenciesResolver {

    func fundsHomeCoordinator() -> BindableCoordinator {
        return DefaultFundsHomeCoordinator(dependencies: self, navigationController: resolve())
    }

    func resolve() -> GetFundDetailUsecase {
        return DefaultGetFundDetailUsecase(dependencies: self)
    }

    func resolve() -> FundsHomeHeaderModifier? {
        nil
    }

    func resolve() -> GetFundOptionsUsecase {
        return DefaultGetFundOptionsUsecase()
    }

    func fundCustomeOptionCoordinator() -> BindableCoordinator {
        ToastCoordinator("generic_alert_notAvailableOperation")
    }

    func resolve() -> FundsDetailFieldsModifier? {
        nil
    }
}
