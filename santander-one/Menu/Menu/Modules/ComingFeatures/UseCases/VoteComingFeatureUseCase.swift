//
//  VoteComingFeaturesUseCase.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 21/02/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class VoteComingFeatureUseCase: UseCase<VoteComingFeatureUseCaseInput, Void, StringErrorOutput > {
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: VoteComingFeatureUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        
        let appRepositoryProtocol: AppRepositoryProtocol = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let globalPosition: GlobalPositionRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let userPrefDTO = appRepositoryProtocol.getUserPreferences(userId: globalPosition.userId ?? "")
        userPrefDTO.comingFeaturesVotedIds.append(requestValues.idea.identifier)
        appRepositoryProtocol.setUserPreferences(userPref: userPrefDTO)
        return .ok()
    }
    
}
 
struct VoteComingFeatureUseCaseInput {
    let idea: ComingFeatureEntity
}
