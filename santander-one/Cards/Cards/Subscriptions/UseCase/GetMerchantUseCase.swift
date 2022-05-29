//
//  GetMerchantUseCase.swift
//  CommonUseCase
//
//  Created by César González Palomino on 04/03/2021.
//

import Foundation
import CoreFoundationLib

public struct GetMerchantUseCaseOutput {
    public let list: [MerchantEntity]
}

public final class GetMerchantUseCase: UseCase<Void, GetMerchantUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetMerchantUseCaseOutput, StringErrorOutput> {
        let repository: MerchantRepositoryProtocol = self.dependenciesResolver.resolve(for: MerchantRepositoryProtocol.self)
        let appRepository: AppRepositoryProtocol = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        
        guard let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        let languageType = appRepository.getCurrentLanguage()
        repository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        
        guard let dtos = repository.getMerchantList()?.merchantList else {
            return UseCaseResponse.error(StringErrorOutput("No MerchantDTO to convert to entity"))
        }
        return UseCaseResponse.ok(GetMerchantUseCaseOutput(list: dtos.map(MerchantEntity.init)))
    }
}
