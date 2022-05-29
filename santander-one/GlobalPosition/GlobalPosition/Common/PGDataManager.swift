//
//  PGDataManager.swift
//  Models
//
//  Created by alvola on 15/10/2019.
//

import CoreFoundationLib
import CoreDomain

protocol PGDataManagerProtocol: GlobalSearchEnabledManagerProtocol {
    func getPGValues(_ success: @escaping (GetPGUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func getMovementsOfAccount(_ account: AccountEntity, _ success: @escaping (GetAccountMovementsUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func getUnreadMovementsOfAccount(_ account: AccountEntity, _ success: @escaping (GetAccountUnreadMovementsUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func getUnreadMovementsOfCard(_ card: CardEntity, _ success: @escaping (GetCardUnreadMovementsUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func accountInfoIsReady(_ account: AccountEntity) -> Bool
    func cardInfoIsReady(_ card: CardEntity) -> Bool
    func setPFMSubscriber(_ subscriber: PfmControllerSubscriber)
    func getUserPreferencesValues(userId: String?, _ success: @escaping (GetUserPreferencesUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func updateUserPreferencesValues(userPrefEntity: UserPrefEntity)
    func setInterventionFilter(_ filter: PGInterventionFilter)
    func getInterventionFilter() -> PGInterventionFilter
    func getFavouritesContacts(_ success: @escaping (GetFavouriteContactsUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func getLocalFavouritesContacts(_ success: @escaping (() -> Void), failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func didExpireOffer(_ offer: OfferEntity)
    func disableOffer(_ offerId: String, _ success: @escaping (() -> Void))
    func getLoanSimulatorLimits(_ completion: @escaping (LoanSimulationLimitsEntity?) -> Void)
    func getLoanBannerLimits(_ completion: @escaping (LoanBannerLimitsEntity?) -> Void)
    func getMonthlyBalance(_ completion: @escaping ([MonthlyBalanceRepresentable]) -> Void)
}

final class PGDataManager: PGDataManagerProtocol {
    
    private var resolver: DependenciesResolver
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().globalPosition
    }
    
    private var currentInterventionFilter: PGInterventionFilter = .all
    
    private var getLoadPregrantedBannerLimits: GetPregrantedLimitsUseCase {
        self.resolver.resolve(for: GetPregrantedLimitsUseCase.self)
    }
    
    private var getLoadSimulatorLimits: LoadLoanSimulatorUseCase {
        self.resolver.resolve(for: LoadLoanSimulatorUseCase.self)
    }
    
    private var getMonthlyBalanceUseCase: GetMonthlyBalanceUseCase {
        return self.resolver.resolve(firstTypeOf: GetMonthlyBalanceUseCase.self)
    }
    
    private lazy var downloadUnreadMovementsScheduler: UseCaseScheduler = {
        return UseCaseHandler(maxConcurrentOperationCount: 1, qualityOfService: .background)
    }()
    
    init(resolver: DependenciesResolver) {
        self.resolver = resolver
    }
    
    func getPGValues(_ success: @escaping (GetPGUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let input: GetPGUseCaseInput = GetPGUseCaseInput(locations: locations)
        let usecase: GetPGUseCase = self.resolver.resolve(for: GetPGUseCase.self)
        let usecaseHandler: UseCaseHandler = self.resolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input),
                       useCaseHandler: usecaseHandler,
                       onSuccess: success,
                       onError: failure)
    }
    
    func getMovementsOfAccount(_ account: AccountEntity, _ success: @escaping (GetAccountMovementsUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let input: GetAccountMovementsUseCaseInput = GetAccountMovementsUseCaseInput(dependenciesResolver: resolver, account: account)
        let usecase: GetAccountMovementsUseCase = self.resolver.resolve(for: GetAccountMovementsUseCase.self)
        let usecaseHandler: UseCaseHandler = self.resolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input),
                       useCaseHandler: usecaseHandler,
                       onSuccess: success,
                       onError: failure)
    }
    
    func getUnreadMovementsOfAccount(_ account: AccountEntity, _ success: @escaping (GetAccountUnreadMovementsUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let input = GetAccountUnreadMovementsUseCaseInput(account: account.representable)
        let usecase: GetAccountUnreadMovementsUseCase = self.resolver.resolve(firstTypeOf: GetAccountUnreadMovementsUseCase.self)
        Scenario(useCase: usecase, input: input)
            .execute(on: downloadUnreadMovementsScheduler)
            .onSuccess(success)
            .onError(failure)
    }
    
    func getUnreadMovementsOfCard(_ card: CardEntity, _ success: @escaping (GetCardUnreadMovementsUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let input = GetCardUnreadMovementsUseCaseInput(card: card.representable)
        let usecase: GetCardUnreadMovementsUseCase = self.resolver.resolve(firstTypeOf: GetCardUnreadMovementsUseCase.self)
        Scenario(useCase: usecase, input: input)
            .execute(on: downloadUnreadMovementsScheduler)
            .onSuccess(success)
            .onError(failure)
    }
    
    func accountInfoIsReady(_ account: AccountEntity) -> Bool {
        let pfmController = resolver.resolve(for: PfmControllerProtocol.self)
        return pfmController.isPFMAccountReady(account: account)
    }
    
    func cardInfoIsReady(_ card: CardEntity) -> Bool {
        let pfmController = resolver.resolve(for: PfmControllerProtocol.self)
        return pfmController.isPFMCardReady(card: card)
    }
    
    func setPFMSubscriber(_ subscriber: PfmControllerSubscriber) {
        let pfmController = resolver.resolve(for: PfmControllerProtocol.self)
        pfmController.removePFMSubscriber(subscriber)
        pfmController.registerPFMSubscriber(with: subscriber)
    }
    
    func getUserPreferencesValues(userId: String?, _ success: @escaping (GetUserPreferencesUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let input: GetUserPreferencesUseCaseInput = GetUserPreferencesUseCaseInput(dependenciesResolver: resolver, userId: userId)
        let usecase: GetUserPreferencesUseCase = self.resolver.resolve(for: GetUserPreferencesUseCase.self)
        let usecaseHandler: UseCaseHandler = self.resolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input), useCaseHandler: usecaseHandler, onSuccess: success, onError: failure)
    }
    
    func updateUserPreferencesValues(userPrefEntity: UserPrefEntity) {
        let input: UpdateUserPreferencesUseCaseInput = UpdateUserPreferencesUseCaseInput(dependenciesResolver: resolver, userPref: userPrefEntity)
        let usecase: UpdateUserPreferencesUseCase = self.resolver.resolve(for: UpdateUserPreferencesUseCase.self)
        let usecaseHandler: UseCaseHandler = self.resolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input), useCaseHandler: usecaseHandler, onSuccess: nil, onError: nil)
    }
    
    func setInterventionFilter(_ filter: PGInterventionFilter) { currentInterventionFilter = filter }
    func getInterventionFilter() -> PGInterventionFilter { return currentInterventionFilter }
    
    func getOtherOperativesChecks(_ otherLocations: [PullOfferLocation], _ success: @escaping (GetOtherOperativesChecksUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let input: GetOtherOperativesChecksUseCaseInput = GetOtherOperativesChecksUseCaseInput(dependenciesResolver: resolver, locations: otherLocations)
        let usecase: GetOtherOperativesChecksUseCase = self.resolver.resolve(for: GetOtherOperativesChecksUseCase.self)
        let usecaseHandler: UseCaseHandler = self.resolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input),
                       useCaseHandler: usecaseHandler,
                       onSuccess: success, 
                       onError: failure
        )
    }
    
    func getFavouritesContacts(_ success: @escaping (GetFavouriteContactsUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let useCase: FavouriteContactsUseCase = resolver.resolve(for: FavouriteContactsUseCase.self)
        let useCaseHandler: UseCaseHandler = self.resolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, onSuccess: success, onError: failure)
    }
    
    func getLocalFavouritesContacts(_ success: @escaping (() -> Void), failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let useCase: GetLocalFavouriteContactsUseCase = resolver.resolve(for: GetLocalFavouriteContactsUseCase.self)
        let useCaseHandler: UseCaseHandler = self.resolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, onSuccess: success, onError: failure)
    }
    
    func didExpireOffer(_ offer: OfferEntity) {
        let useCase: ExpirePullOfferUseCase = resolver.resolve(for: ExpirePullOfferUseCase.self)
        let useCaseHandler: UseCaseHandler = self.resolver.resolve(for: UseCaseHandler.self)
        guard let offerId = offer.id else { return }
        UseCaseWrapper(with: useCase.setRequestValues(requestValues: ExpirePullOfferUseCaseInput(offerId: offerId)), useCaseHandler: useCaseHandler)
    }
    
    func disableOffer(_ offerId: String, _ success: @escaping (() -> Void)) {
        Scenario(useCase: resolver.resolve(for: DisableOnSessionPullOfferUseCase.self),
                 input: DisableOnSessionPullOfferUseCaseInput(offerId: offerId))
            .execute(on: self.resolver.resolve())
            .onSuccess(success)
    }
    
    func getLoanSimulatorLimits(_ completion: @escaping (LoanSimulationLimitsEntity?) -> Void) {
        Scenario(useCase: getLoadSimulatorLimits)
            .execute(on: self.resolver.resolve())
            .onSuccess { output in
                completion(output.loanLimits)
            }
            .onError { _ in
                completion(nil)
            }
    }
    
    func getLoanBannerLimits(_ completion: @escaping (LoanBannerLimitsEntity?) -> Void) {
        Scenario(useCase: getLoadPregrantedBannerLimits)
            .execute(on: self.resolver.resolve())
            .onSuccess { output in
                completion(output.loanBanner)
            }
            .onError { _ in
                completion(nil)
            }
    }
    
    func getMonthlyBalance(_ completion: @escaping ([MonthlyBalanceRepresentable]) -> Void) {
        Scenario(useCase: getMonthlyBalanceUseCase)
            .execute(on: resolver.resolve())
            .map { $0.data }
            .onSuccess { data in
                completion(data)
            }
            .onError { _ in
                completion([])
            }
    }
}
