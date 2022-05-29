
public protocol GetLanguagesSelectionUseCaseProtocol: UseCase<Void, GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {}

open class GetLanguagesSelectionUseCase: UseCase<Void, GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
    private let dependencies: DependenciesResolver
    private let appRepository: AppRepositoryProtocol
    
    public init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
        self.appRepository = dependencies.resolve()
    }
    
    override open func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
        let current: Language
        let response = appRepository.getLanguage()
        let responseUser = appRepository.getPersistedUser()
        let user = try responseUser.getResponseData()
        if let data = try response.getResponseData(), let languageType = data {
            current = Language.createFromType(languageType: languageType, isPb: user?.isPb)
        } else {
            let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
            let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
            current = Language.createDefault(isPb: user?.isPb, defaultLanguage: defaultLanguage, availableLanguageList: languageList)
        }
        return UseCaseResponse.ok(GetLanguagesSelectionUseCaseOkOutput(current: current))
    }
}

extension GetLanguagesSelectionUseCase: GetLanguagesSelectionUseCaseProtocol {}

public struct GetLanguagesSelectionUseCaseOkOutput {
    public let current: Language
    
    public init(current: Language) {
        self.current = current
    }
}
