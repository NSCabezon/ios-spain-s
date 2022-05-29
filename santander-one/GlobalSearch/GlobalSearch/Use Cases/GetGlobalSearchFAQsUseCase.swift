//
//  GetGlobalSearchFAQsUseCase.swift
//  GlobalSearch
//
//  Created by alvola on 27/04/2020.
//

import CoreFoundationLib

class GetGlobalSearchFAQsUseCase: UseCase<Void, GetGlobalSearchFAQsUseCaseOkOutput, StringErrorOutput> {
    
    private var dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetGlobalSearchFAQsUseCaseOkOutput, StringErrorOutput> {
        let faqsRepository = dependenciesResolver.resolve(for: FaqsRepositoryProtocol.self)
        let faqsListDTO = faqsRepository.getFaqsList()
        
        return UseCaseResponse.ok(GetGlobalSearchFAQsUseCaseOkOutput(faqs: faqsListDTO?.globalSearch?.map { FaqsEntity($0) }))
    }
}

struct GetGlobalSearchFAQsUseCaseOkOutput {
    let faqs: [FaqsEntity]?
}
