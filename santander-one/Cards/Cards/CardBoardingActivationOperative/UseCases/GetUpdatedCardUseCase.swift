//
//  GetUpdatedCardUseCase.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 19/10/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetUpdatedCardUseCase: UseCase<GetUpdatedCardUseCaseInput, GetUpdatedCardUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetUpdatedCardUseCaseInput) throws -> UseCaseResponse<GetUpdatedCardUseCaseOkOutput, StringErrorOutput> {
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let updatedCard = globalPosition.cards.visibles().first(where: { $0 == requestValues.card })
        return .ok(GetUpdatedCardUseCaseOkOutput(updatedCard: updatedCard ?? requestValues.card))
    }
}

struct GetUpdatedCardUseCaseInput {
    let card: CardEntity
}

struct GetUpdatedCardUseCaseOkOutput {
    let updatedCard: CardEntity
}
