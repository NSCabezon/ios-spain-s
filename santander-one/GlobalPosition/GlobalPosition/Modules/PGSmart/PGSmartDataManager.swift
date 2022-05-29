//
//  PGSmartDataManager.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 19/12/2019.
//

import CoreFoundationLib
import CoreDomain

protocol PGSmartDataManagerProtocol: AnyObject {
    func getUserPreferencesValues(userId: String?, _ success: @escaping (GetUserPreferencesUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func getPGValues(_ success: @escaping (GetPGUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func monthsInfoAreReady() -> [MonthlyBalanceRepresentable]?
    func setPFMSubscriber(_ subscriber: PfmControllerSubscriber)
}

final class PGSmartDataManager: PGSmartDataManagerProtocol {
    func monthsInfoAreReady() -> [MonthlyBalanceRepresentable]? {
        let pfmController = resolver.resolve(for: PfmControllerProtocol.self)
        return pfmController.monthsHistory
    }
    
    func setPFMSubscriber(_ subscriber: PfmControllerSubscriber) {
        let pfmController = resolver.resolve(for: PfmControllerProtocol.self)
        pfmController.registerPFMSubscriber(with: subscriber)
    }    
    
    private var resolver: DependenciesResolver
    
    var locations: [PullOfferLocation] {
           return PullOffersLocationsFactoryEntity().globalPosition
    }
    
    init(resolver: DependenciesResolver) {
        self.resolver = resolver
    }
    
    func getUserPreferencesValues(userId: String?, _ success: @escaping (GetUserPreferencesUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let input: GetUserPreferencesUseCaseInput = GetUserPreferencesUseCaseInput(dependenciesResolver: resolver, userId: userId)
        let usecase: GetUserPreferencesUseCase = self.resolver.resolve(for: GetUserPreferencesUseCase.self)
        let usecaseHandler: UseCaseHandler = self.resolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input), useCaseHandler: usecaseHandler, onSuccess: success, onError: failure)
    }
    
    func getPGValues(_ success: @escaping (GetPGUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let input: GetPGUseCaseInput = GetPGUseCaseInput(locations: locations)
        let usecase: GetPGUseCase = self.resolver.resolve(for: GetPGUseCase.self)
        let usecaseHandler: UseCaseHandler = self.resolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input), useCaseHandler: usecaseHandler, onSuccess: success, onError: failure)
    }
}
