//
//  NewFavouritePreSetupUseCase.swift
//  Transfer
//
//  Created by Luis Escámez Sánchez on 10/6/21.
//

import Foundation
import SANLegacyLibrary
import CoreFoundationLib

protocol NewFavouritePreSetupUseCaseProtocol: UseCase<Void, NewFavouritePreSetupUseCaseOkOutput, StringErrorOutput> {}

class NewFavouritePreSetupUseCase: UseCase<Void, NewFavouritePreSetupUseCaseOkOutput, StringErrorOutput>, NewFavouritePreSetupUseCaseProtocol {
    private let dependenciesResolver: DependenciesResolver
    private var sepaInfoRepository: SepaInfoRepositoryProtocol {
        return self.dependenciesResolver.resolve(for: SepaInfoRepositoryProtocol.self)
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<NewFavouritePreSetupUseCaseOkOutput, StringErrorOutput> {
        let sepaInfoRepository = self.dependenciesResolver.resolve(for: SepaInfoRepositoryProtocol.self)
        let sepaInfoListEntity = SepaInfoListEntity(dto: sepaInfoRepository.getSepaList())
        return .ok(NewFavouritePreSetupUseCaseOkOutput(sepaList: sepaInfoListEntity))
    }
}

struct NewFavouritePreSetupUseCaseOkOutput {
    let sepaList: SepaInfoListEntity
}
