//
//  GetLoadingTipsUseCase.swift
//  CommonUseCase
//
//  Created by Luis Escámez Sánchez on 04/02/2020.
//

import Foundation

public class GetLoadingTipsUseCase: UseCase<Void, GetLoadingTipsUseCaseOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLoadingTipsUseCaseOutput, StringErrorOutput> {
        
        let tipsRepository = dependenciesResolver.resolve(for: LoadingTipsRepositoryProtocol.self)
        
        guard let tips = getLoadingTips(tipsRepository: tipsRepository) else {
            return UseCaseResponse.error(StringErrorOutput("No LoadingTipsDtos to convert to entity"))
        }
        
        return UseCaseResponse.ok(GetLoadingTipsUseCaseOutput(imageNamesLists: getImageNames(),
                                                              tipsList: tips
            )
        )
    }
}

public struct GetLoadingTipsUseCaseOutput {
    public let imageNamesLists: [String]
    public let tipsList: [LoadingTipEntity]
}

// Private Methods
fileprivate extension GetLoadingTipsUseCase {
    
    private func getLoadingTips(tipsRepository: LoadingTipsRepositoryProtocol) -> [LoadingTipEntity]? {
        guard let dtos = tipsRepository.getLoadingTips() else {
            return nil
        }
        return LoadingTipsListEntity(dtos).loadingTipsEntities
    }
    
    private func getImageNames() -> [String] {
        if let loadingTipsImageModifier = self.dependenciesResolver.resolve(forOptionalType: GetLoadingTipsImagesModifierProtocol.self) {
            return loadingTipsImageModifier.getLoadingImagesNames()
        } else {
            return ["loader1", "loader2", "loader3"]
        }
    }
}
