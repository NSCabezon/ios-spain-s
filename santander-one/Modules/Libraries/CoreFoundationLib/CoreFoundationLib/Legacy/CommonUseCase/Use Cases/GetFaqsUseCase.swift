//
//  FAQSUseCase.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 2/27/20.
//

import Foundation
import SANLegacyLibrary

public typealias GetFaqsUseCaseAlias = UseCase<FaqsUseCaseInput, FaqsUseCaseOutput, StringErrorOutput>

public final class GetFaqsUseCase: GetFaqsUseCaseAlias {
    private let dependenciesResolver: DependenciesResolver
    private let faqsRepository: FaqsRepositoryProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.faqsRepository = self.dependenciesResolver.resolve(for: FaqsRepositoryProtocol.self)
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override public func executeUseCase(requestValues: FaqsUseCaseInput) throws -> UseCaseResponse<FaqsUseCaseOutput, StringErrorOutput> {
        let faqsList = self.faqsRepository
            .getFaqsList(requestValues.type)
            .map { FaqsEntity($0) }
        let showVirtualAssistant = appConfigRepository.getBool("enableVirtualAssistant") ?? true
        return .ok(FaqsUseCaseOutput(faqs: faqsList, showVirtualAssistant: showVirtualAssistant))
    }
}

public struct FaqsUseCaseInput {
    public let type: FaqsType
    public init(type: FaqsType) {
        self.type = type
    }
}

public struct FaqsUseCaseOutput {
    public let faqs: [FaqsEntity]
    public let showVirtualAssistant: Bool
}
