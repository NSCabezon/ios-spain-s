//
//  GetRecoveryLevelUseCase.swift
//  CommonUseCase
//
//  Created by alvola on 20/10/2020.
//

import SANLegacyLibrary

public class  GetRecoveryLevelUseCase: UseCase<Void, GetRecoveryLevelUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let appConfig: AppConfigRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetRecoveryLevelUseCaseOutput, StringErrorOutput> {
        guard shouldContinue else { return .error(StringErrorOutput(nil)) }
        let response = try self.provider.getRecoveryNoticesManager().getRecoveryNotices()
        guard response.isSuccess(), let recoveryDTOs = try response.getResponseData() else {
            let errorMessage = try response.getErrorMessage()
            return .error(StringErrorOutput(errorMessage))
        }
        guard let parsedResponse = parseResponse(recoveryDTOs) else { return .error(StringErrorOutput(nil)) }
        return .ok(parsedResponse)
    }
}

private extension GetRecoveryLevelUseCase {
    enum Constants {
        static let cardsGroup = ["1804", "A435"]
        static let accountGroup = ["1805", "A436"]
        static let loansGroup = ["1810", "1808", "1801", "1803", "1815", "1811", "1802", "A448", "A441", "A439", "A432", "A444", "A446", "A433"]
        static let validNoticeLevels = [2, 3]
    }
    
    var shouldContinue: Bool {
           isRecoveryEnabled && userHasValidCampaings
       }
   
    var isRecoveryEnabled: Bool {
        let enableRecoveryPG = appConfig.getBool("enableRecoveryPG") ?? false
        return enableRecoveryPG
    }
    
    var userHasValidCampaings: Bool {
        guard
            let recoveryCampaigns = appConfig.getAppConfigListNode("campaignsRecoveryPG"),
                !recoveryCampaigns.isEmpty,
            let userCampaigns = try? provider.getBsanPullOffersManager().getCampaigns().getResponseData() ?? [],
            !userCampaigns.isEmpty
        else { return false }
        return recoveryCampaigns.contains(where: { userCampaigns.contains($0) == true })
    }
    
    func parseResponse(_ response: [RecoveryDTO]) -> GetRecoveryLevelUseCaseOutput? {
        var debtCount = 0
        var debtTitle = ""
        var amount = 0.0
        var level = 0
        let addNotice: (String, Double, Int) -> Void = {
            debtCount += 1
            debtTitle = $0
            amount += $1
            level = max(level, $2)
        }
        response.forEach {
            guard
                let noticeLevel = $0.noticeLevel,
                let totalUnpaidAmount = $0.totalUnpaidAmount,
                let description = $0.description,
                let groupType = $0.groupType,
                totalUnpaidAmount != 0.0,
                Constants.validNoticeLevels.contains(noticeLevel),
                [Constants.cardsGroup, Constants.accountGroup, Constants.loansGroup]
                    .reduce([], +)
                    .contains(groupType)
            else { return }
            if totalUnpaidAmount < 0.0 && Constants.accountGroup.contains(groupType) {
                addNotice(description, abs(totalUnpaidAmount), noticeLevel)
            } else if totalUnpaidAmount > 0.0 && !Constants.accountGroup.contains(groupType) {
                addNotice(description, totalUnpaidAmount, noticeLevel)
            }
        }
        guard debtCount > 0 else { return nil }
        return GetRecoveryLevelUseCaseOutput(debtCount: debtCount,
                                             debtTitle: debtTitle,
                                             amount: amount,
                                             level: level)
    }
}

public struct GetRecoveryLevelUseCaseOutput {
    public let debtCount: Int
    public let debtTitle: String
    public let amount: Double
    public let level: Int
}
