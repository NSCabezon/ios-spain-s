//
//  GetOneFaqsUseCase.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 16/12/21.
//

import Foundation
import OpenCombine
import CoreDomain

public struct OneFooterData {
    public var faqs: [FaqRepresentable]
    public var virtualAssistant: Bool
    public var tips: [PullOfferTipRepresentable]
    
    public init (faqs: [FaqRepresentable], tips: [PullOfferTipRepresentable], virtualAssistant: Bool) {
        self.faqs = faqs
        self.virtualAssistant = virtualAssistant
        self.tips = tips
    }
}

public protocol GetOneFaqsUseCase {
    func fetchFaqs(type: FaqsType) -> AnyPublisher<OneFooterData, Never>
}

struct DefaultGetOneFaqsUseCase {
    private let faqsRepository: FaqsRepositoryProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependencies: FaqsDependenciesResolver) {
        faqsRepository = dependencies.resolve()
        appConfigRepository = dependencies.resolve()
    }
}

extension DefaultGetOneFaqsUseCase: GetOneFaqsUseCase {
    public func fetchFaqs(type: FaqsType) -> AnyPublisher<OneFooterData, Never> {
        let showVirtualAssistant = appConfigRepository.getBool("enableVirtualAssistant") ?? true
        let faqsList = faqsRepository
            .getFaqsList(type)
        return Just(OneFooterData(faqs: faqsList, tips: [], virtualAssistant: showVirtualAssistant))
            .eraseToAnyPublisher()
    }
}
