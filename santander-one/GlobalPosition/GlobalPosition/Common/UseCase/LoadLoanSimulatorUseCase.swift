//
//  LoadLoanSimulatorUseCase.swift
//  RetailClean
//
//  Created by César González Palomino on 28/01/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib
import SANLegacyLibrary

open class LoadLoanSimulatorUseCase: UseCase<Void, LoadLoanSimulatorUseCaseOkOutput, StringErrorOutput> {
    public let resolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let appConfigEnableSimulationcampaignsCode = "simulationcampaignsCode"
    private let appConfigEnableSimulationfamilyCode = "simulationfamilyCode"
    private let appConfigPregrantedCampaignsCode = "pregrantedCampaignsCode"
    private let appConfigEnablePregrantedWidget = "enablePregrantedWidget"

    public init(resolver: DependenciesResolver) {
        self.resolver = resolver
        self.provider = resolver.resolve(for: BSANManagersProvider.self)
    }
    
    override open func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadLoanSimulatorUseCaseOkOutput, StringErrorOutput> {
        return try loadLoanSimulator()
    }
 }

private extension LoadLoanSimulatorUseCase {
    func loadLoanSimulator() throws -> UseCaseResponse<LoadLoanSimulatorUseCaseOkOutput, StringErrorOutput> {
        let loanSimulatorManager = resolver.resolve(for: BSANManagersProvider.self).getBSANLoanSimulatorManager()
        let appConfigRepository: AppConfigRepositoryProtocol = resolver.resolve()
        let localAppConfig: LocalAppConfig = self.resolver.resolve()
        guard appConfigRepository.getBool(self.appConfigEnablePregrantedWidget) == true && localAppConfig.isEnabledPregranted,
              let candidateCampaignCodes = appConfigRepository.getAppConfigListNode(self.appConfigEnableSimulationcampaignsCode),
              let simulationfamilyCodes = appConfigRepository.getAppConfigListNode(self.appConfigEnableSimulationfamilyCode),
              let pregrantedCampaignCodes = appConfigRepository.getAppConfigListNode(self.appConfigPregrantedCampaignsCode) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let responseCampaigns = try provider.getBsanPullOffersManager().getCampaigns()
        guard responseCampaigns.isSuccess(), let data = try responseCampaigns.getResponseData() else {
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
        guard responseActiveCampaigns.isSuccess(), let dto = try responseActiveCampaigns.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let simulationAlreadyInProgress = (!(dto.proposalList ?? []).isEmpty) && dto.campaigns.isEmpty
        var loanBannerEntity = LoanBannerLimitsEntity(simulationAlreadyInProgress: simulationAlreadyInProgress,
                                                      amountLimit: nil)
        guard let selectedCampaigne = getCandidateCampaign(from: dto.campaigns,
                                                           candidateCampaignCodes: candidateCampaignCodes,
                                                           simulationfamilyCodes: simulationfamilyCodes) else {
            return responseWithLoanBanner(loanBannerEntity)
        }
        let loanLimitsInput = LoadLimitsInput(employee: dto.employee,
                                              group: getGroupId(from: selectedCampaigne.campaignPurpose),
                                              campaigns: [selectedCampaigne],
                                              smartInd: dto.indSmart,
                                              accountInd: dto.indAccount123)
        let responseLoadLimits = try loanSimulatorManager.loadLimits(input: loanLimitsInput,
                                                                     selectedCampaignCurrency: selectedCampaigne.currency)
        guard responseLoadLimits.isSuccess() else {
            return responseWithLoanBanner(loanBannerEntity)
        }
        let responseGetLimits = try loanSimulatorManager.getLimits()
        guard responseGetLimits.isSuccess(), let loanSimulatorLimitsDTO = try responseGetLimits.getResponseData() else {
            return responseWithLoanBanner(loanBannerEntity)
        }
        let loanSimulatorEntity = LoanSimulationLimitsEntity(loanSimulatorLimitsDTO)
        loanBannerEntity.amountLimit = loanSimulatorLimitsDTO.amountUntil
        return UseCaseResponse.ok(LoadLoanSimulatorUseCaseOkOutput(loanLimits: loanSimulatorEntity))
    }
    
    func getCandidateCampaign(from campaigns: [LoanSimulatorCampaignDTO],
                              candidateCampaignCodes: [String],
                              simulationfamilyCodes: [String]) -> LoanSimulatorCampaignDTO? {
        return campaigns
            .filter { simulationfamilyCodes.contains( $0.familyCode.trim().uppercased().substring(0, 3) ?? "" )}
            .filter { candidateCampaignCodes.contains( $0.campaignCode.trim().uppercased().substring(0, 3) ?? "" )}
            .max { $0.maxAmount > $1.maxAmount }
    }
    
    func getGroupId(from campaignPurpose: String) -> String {
        switch campaignPurpose.uppercased() {
        case "C":
            return "2551"
        case "N":
            return "2549"
        case "T":
            return "2549"
        default:
            return "2549"
        }
    }
    
    func responseWithLoanBanner(_ bannerEntity: LoanBannerLimitsEntity) -> UseCaseResponse<LoadLoanSimulatorUseCaseOkOutput, StringErrorOutput> {
        guard bannerEntity.simulationAlreadyInProgress else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return UseCaseResponse.ok(LoadLoanSimulatorUseCaseOkOutput(loanLimits: nil))
    }
}

public struct LoadLoanSimulatorUseCaseOkOutput {
    public let loanLimits: LoanSimulationLimitsEntity?
    
    public init(loanLimits: LoanSimulationLimitsEntity?) {
        self.loanLimits = loanLimits
    }
}
