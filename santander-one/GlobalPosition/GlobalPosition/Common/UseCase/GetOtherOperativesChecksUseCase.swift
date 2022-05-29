//
//  GetOtherOperativesChecksUseCase.swift
//  GlobalPosition
//
//  Created by Tania Castellano Brasero on 12/02/2020.
//

import CoreFoundationLib
import SANLegacyLibrary
import Cards

class GetOtherOperativesChecksUseCase: UseCase<GetOtherOperativesChecksUseCaseInput, GetOtherOperativesChecksUseCaseOkOutput, StringErrorOutput> {
    override func executeUseCase(requestValues: GetOtherOperativesChecksUseCaseInput) throws -> UseCaseResponse<GetOtherOperativesChecksUseCaseOkOutput, StringErrorOutput> {
        let globalPositionConfiguration: GlobalPositionConfiguration = requestValues.dependenciesResolver.resolve(for: GlobalPositionConfiguration.self)
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = requestValues.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let pullOffersInterpreter: PullOffersInterpreter = requestValues.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let appConfigRepository = requestValues.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let bsanManagersProvider: BSANManagersProvider = requestValues.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let applePayEnrollment = ApplePayEnrollmentManager(dependenciesResolver: requestValues.dependenciesResolver)
        let isEnrollingCardEnabled = applePayEnrollment.isEnrollingCardEnabled()
        
        var outputCandidates: [PullOfferLocation: OfferEntity] = [:]
        if let userId: String = globalPosition.userId {
            for location in requestValues.locations {
                if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                    outputCandidates[location] = OfferEntity(candidate, location: location)
                }
            }
        }
        
        // MARK: - OTPExcepted
        
        let cmpsResponse = try bsanManagersProvider.getBsanSendMoneyManager().getCMPSStatus()
        var otpExcepted: Bool = false
        
        if cmpsResponse.isSuccess(), let cmpsDTO = try cmpsResponse.getResponseData() {
            let cmps = CMPSEntity.createFromDTO(dto: cmpsDTO)
            otpExcepted = cmps.isOTPExcepted
        }
        
        // MARK: - Demo
        
        let isDemoResponse = try bsanManagersProvider.getBsanSessionManager().isDemo()
        var isDemo: Bool = false
        
        if isDemoResponse.isSuccess(), let demoResponseData = try isDemoResponse.getResponseData() {
            isDemo = demoResponseData
        }
        
        // MARK: Allianz plans
        
        let accountDescriptorRepository: AccountDescriptorRepositoryProtocol = requestValues.dependenciesResolver.resolve(for: AccountDescriptorRepositoryProtocol.self)
        let allianzPlans = (accountDescriptorRepository.getAccountDescriptor()?.plansArray ?? []).map(ProductAllianz.init)
        let shouldShowPensionOperatives = !allianzPlans.isEmpty &&
            globalPosition.pensions.visibles().contains(where: { !$0.isAllianz(filterWith: allianzPlans)})
        
        return UseCaseResponse.ok(GetOtherOperativesChecksUseCaseOkOutput(
                                    isPb: globalPosition.isPb ?? false,
                                    isDemo: isDemo,
                                    isSavingInsuranceBalanceAvailable: globalPositionConfiguration.isInsuranceBalanceEnabled,
                                    pullOfferCandidates: outputCandidates,
                                    visibleAccounts: globalPosition.accounts.visibles(),
                                    allAccounts: globalPosition.accounts.all(),
                                    cards: globalPosition.cards.visibles(),
                                    stockAccount: globalPosition.stockAccounts.visibles(),
                                    loans: globalPosition.loans.visibles(),
                                    deposits: globalPosition.deposits.visibles(),
                                    pensions: globalPosition.pensions.visibles(),
                                    funds: globalPosition.funds.visibles(),
                                    notManagedPortfolio: globalPosition.notManagedPortfolios.visibles(),
                                    managedPortfolio: globalPosition.managedPortfolios.visibles(),
                                    insuranceSavings: globalPosition.insuranceSavings.visibles(),
                                    protectionInsurances: globalPosition.protectionInsurances.visibles(),
                                    userPref: globalPosition.userPref,
                                    isOTPExcepted: otpExcepted,
                                    shouldShowPensionOperatives: shouldShowPensionOperatives,
                                    appConfigRepository: appConfigRepository,
                                    isEnrollingCardEnabled: isEnrollingCardEnabled)
        )
    }
}

struct GetOtherOperativesChecksUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let locations: [PullOfferLocation]
}

struct GetOtherOperativesChecksUseCaseOkOutput {
    let isPb: Bool
    let isDemo: Bool
    let isSavingInsuranceBalanceAvailable: Bool
    let pullOfferCandidates: [PullOfferLocation: OfferEntity]
    let visibleAccounts: [AccountEntity]
    let allAccounts: [AccountEntity]
    let cards: [CardEntity]
    let stockAccount: [StockAccountEntity]
    let loans: [LoanEntity]
    let deposits: [DepositEntity]
    let pensions: [PensionEntity]
    let funds: [FundEntity]
    let notManagedPortfolio: [PortfolioEntity]
    let managedPortfolio: [PortfolioEntity]
    let insuranceSavings: [InsuranceSavingEntity]
    let protectionInsurances: [InsuranceProtectionEntity]
    let userPref: UserPrefEntity?
    let isOTPExcepted: Bool
    let shouldShowPensionOperatives: Bool
    let appConfigRepository: AppConfigRepositoryProtocol
    let isEnrollingCardEnabled: Bool
}
