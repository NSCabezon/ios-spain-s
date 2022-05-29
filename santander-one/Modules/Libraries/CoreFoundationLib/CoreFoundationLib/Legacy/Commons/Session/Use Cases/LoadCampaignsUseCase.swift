//
//  LoadCampaignsUseCase.swift
//  Session
//
//  Created by José Carlos Estela Anguita on 13/9/21.
//

import Foundation
import SANLegacyLibrary

final class LoadCampaignsUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    private let appRepository: AppRepositoryProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol

    init(dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = dependenciesResolver.resolve()
        self.appRepository = dependenciesResolver.resolve()
        self.appConfigRepository = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let pullOffersManager = bsanManagersProvider.getBsanPullOffersManager()
        let response = try pullOffersManager.loadCampaigns()
        guard response.isSuccess() else { return .error(StringErrorOutput(try response.getErrorMessage())) }
        guard
            let mixedUserIdCampaign: String = appConfigRepository.getString("mixedUserIdCampaign"),
            let userCampaingns = try? checkRepositoryResponse(pullOffersManager.getCampaigns()),
            let userCampaingnsUwnrapped = userCampaingns,
            userCampaingnsUwnrapped.count > 0,
            userCampaingnsUwnrapped.contains(mixedUserIdCampaign)
        else {
            _ = appRepository.setMixedUsed(isMixedUser: false)
            return .ok()
        }
        _ = appRepository.setMixedUsed(isMixedUser: true)
        return .ok()
    }
}
