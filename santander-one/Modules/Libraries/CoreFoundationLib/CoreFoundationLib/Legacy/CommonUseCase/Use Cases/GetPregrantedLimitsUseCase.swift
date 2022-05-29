//
//  GetLimitsUseCase.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 29/06/2020.
//

import SANLegacyLibrary

 open class GetPregrantedLimitsUseCase: UseCase<Void, GetPregrantedLimitsUseCaseOkOutput, StringErrorOutput> {
    public let resolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let appConfigEnableSimulationcampaignsCode = "simulationcampaignsCode"
    private let appConfigEnableSimulationfamilyCode = "simulationfamilyCode"
    private let appConfigPregrantedCampaignsCode = "pregrantedCampaignsCode"

    public init(resolver: DependenciesResolver) {
        self.resolver = resolver
        self.provider = resolver.resolve(for: BSANManagersProvider.self)
    }
    
    override open func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPregrantedLimitsUseCaseOkOutput, StringErrorOutput> {
        return try loadLoanBanner()
    }
    
    public func loadLoanBanner() throws -> UseCaseResponse<GetPregrantedLimitsUseCaseOkOutput, StringErrorOutput> {
        let loanSimulatorManager = resolver.resolve(for: BSANManagersProvider.self).getBSANLoanSimulatorManager()
        let appConfigRepository: AppConfigRepositoryProtocol = resolver.resolve()
        guard let candidateCampaignCodes = appConfigRepository.getAppConfigListNode(self.appConfigEnableSimulationcampaignsCode),
              let simulationfamilyCodes = appConfigRepository.getAppConfigListNode(self.appConfigEnableSimulationfamilyCode),
              let pregrantedCampaignCodes = appConfigRepository.getAppConfigListNode(self.appConfigPregrantedCampaignsCode) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let responseCampaigns = try provider.getBsanPullOffersManager().getCampaigns()
        guard responseCampaigns.isSuccess(),
              let data = try responseCampaigns.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let campaignCodesPregrantedFiltered = pregrantedCampaignCodes.filter { (itemCode) in
            guard let campaignsData = data else {
                return false
            }
            let campaignCodesDataFiltered = campaignsData.filter({ $0 == itemCode })
            return !campaignCodesDataFiltered.isEmpty
        }
        guard !campaignCodesPregrantedFiltered.isEmpty else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let responseActiveCampaigns = try loanSimulatorManager.getActiveCampaigns()
        guard responseActiveCampaigns.isSuccess(),
              let dto = try responseActiveCampaigns.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let simulationAlreadyInProgress = !(dto.proposalList ?? []).isEmpty && dto.campaigns.isEmpty
        var loanBannerEntity = LoanBannerLimitsEntity(
            simulationAlreadyInProgress: simulationAlreadyInProgress,
            amountLimit: nil
        )
        guard let selectedCampaigne = getCandidateCampaign(
                from: dto.campaigns,
                candidateCampaignCodes: candidateCampaignCodes,
                simulationfamilyCodes: simulationfamilyCodes
        ) else {
            return responseWithLoanBanner(loanBannerEntity)
        }
        loanBannerEntity.amountLimit = selectedCampaigne.maxAmount
        return UseCaseResponse.ok(GetPregrantedLimitsUseCaseOkOutput(loanBanner: loanBannerEntity))
    }
}

private extension GetPregrantedLimitsUseCase {
    func getCandidateCampaign(from campaigns: [LoanSimulatorCampaignDTO],
                              candidateCampaignCodes: [String],
                              simulationfamilyCodes: [String]) -> LoanSimulatorCampaignDTO? {
        return campaigns
            .filter {
                let familyCode = $0.familyCode
                    .trim()
                    .uppercased()
                    .substring(0, 3) ?? ""
                return simulationfamilyCodes.contains(familyCode)
            }
            .filter {
                let campaignCode = $0.campaignCode
                    .trim()
                    .uppercased()
                    .substring(0, 3) ?? ""
                return candidateCampaignCodes.contains(campaignCode)
            }
            .max {
                return $0.maxAmount > $1.maxAmount
            }
    }
    
    func responseWithLoanBanner(_ bannerEntity: LoanBannerLimitsEntity) -> UseCaseResponse<GetPregrantedLimitsUseCaseOkOutput, StringErrorOutput> {
        guard bannerEntity.simulationAlreadyInProgress else { return UseCaseResponse.error(StringErrorOutput(nil)) }
        return UseCaseResponse.ok(GetPregrantedLimitsUseCaseOkOutput(loanBanner: bannerEntity))
    }
}

public struct GetPregrantedLimitsUseCaseOkOutput {
    public let loanBanner: LoanBannerLimitsEntity
    
    public init(loanBanner: LoanBannerLimitsEntity) {
        self.loanBanner = loanBanner
    }
}
