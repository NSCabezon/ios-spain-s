import CoreFoundationLib

class GetPublicCategoriesUseCase: UseCase<Void, GetPublicCategoriesUseCaseOkOutput, StringErrorOutput> {
    private let pullOffersRepository: PullOffersConfigRepository
    private let pullOffersInterpreter: PullOffersInterpreter

    init(pullOffersRepository: PullOffersConfigRepository, pullOffersInterpreter: PullOffersInterpreter) {
        self.pullOffersRepository = pullOffersRepository
        self.pullOffersInterpreter = pullOffersInterpreter
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPublicCategoriesUseCaseOkOutput, StringErrorOutput> {
        let categoriesDTO = pullOffersRepository.get()?.pullOffersConfig.categories
       
        var outputCategories = [PullOffersConfigCategory]()
        for categoryDTO in categoriesDTO ?? [] {
            if let offers = pullOffersInterpreter.validForContract(category: categoryDTO, reload: false), let pullOffersConfigCategory = PullOffersConfigCategory.createFromDTO(categoryDTO, offers) {
                outputCategories.append(pullOffersConfigCategory)
            }
        }
        return UseCaseResponse.ok(GetPublicCategoriesUseCaseOkOutput(categories: outputCategories))
    }
}

struct GetPublicCategoriesUseCaseOkOutput {
    let categories: [PullOffersConfigCategory]?
}
