import CoreFoundationLib

class GetPublicCategoryUseCase: UseCase<GetPublicCategoryUseCaseInput, GetPublicCategoryUseCaseOkOutput, StringErrorOutput> {
    private let pullOffersRepository: PullOffersConfigRepository
    private let pullOffersInterpreter: PullOffersInterpreter
    
    init(pullOffersRepository: PullOffersConfigRepository, pullOffersInterpreter: PullOffersInterpreter) {
        self.pullOffersRepository = pullOffersRepository
        self.pullOffersInterpreter = pullOffersInterpreter
    }
    
    override public func executeUseCase(requestValues: GetPublicCategoryUseCaseInput) throws -> UseCaseResponse<GetPublicCategoryUseCaseOkOutput, StringErrorOutput> {
        var categoriesDTO = pullOffersRepository.get()?.pullOffersConfig.categories
        
        //Filter category by identifier
        categoriesDTO = categoriesDTO?.filter { $0.identifier == requestValues.identifier }
        
        var outputCategory: PullOffersConfigCategory?
        for categoryDTO in categoriesDTO ?? [] {
            if let offers = pullOffersInterpreter.validForContract(category: categoryDTO, reload: false), let pullOffersConfigCategory = PullOffersConfigCategory.createFromDTO(categoryDTO, offers) {
                outputCategory = pullOffersConfigCategory
            }
        }
        guard let output = outputCategory else {
            return .error(StringErrorOutput("deeplink_alert_errorOffer"))
        }
        return .ok(GetPublicCategoryUseCaseOkOutput(category: output))
    }
}

struct GetPublicCategoryUseCaseInput {
    let identifier: String
}

struct GetPublicCategoryUseCaseOkOutput {
    let category: PullOffersConfigCategory?
}
