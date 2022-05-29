//
//  SepaListUseCase.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 4/8/21.
//

import CoreFoundationLib

protocol SepaListUseCaseProtocol: UseCase<Void, PreSetupDeleteUseCaseOkOutput, StringErrorOutput> {}

final class SepaListUseCase: UseCase<Void, PreSetupDeleteUseCaseOkOutput, StringErrorOutput> {
    private let dependencies: DependenciesResolver
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupDeleteUseCaseOkOutput, StringErrorOutput> {
        let sepaInfoRepository = self.dependencies.resolve(for: SepaInfoRepositoryProtocol.self)
        let sepaInfoListEntity = SepaInfoListEntity(dto: sepaInfoRepository.getSepaList())
        return .ok(PreSetupDeleteUseCaseOkOutput(sepaList: sepaInfoListEntity))
    }
}

struct SepaListUseCaseUseCaseOkOutput {
    let sepaList: SepaInfoListEntity
}

extension SepaListUseCase: SepaListUseCaseProtocol { }
