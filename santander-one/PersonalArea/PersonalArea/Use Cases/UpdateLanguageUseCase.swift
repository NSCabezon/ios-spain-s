import CoreFoundationLib
import SANLegacyLibrary

class UpdateLanguageUseCase: UseCase<UpdateLanguageUseCaseInput, UpdateLanguageUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(_ dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: UpdateLanguageUseCaseInput) throws -> UseCaseResponse<UpdateLanguageUseCaseOkOutput, StringErrorOutput> {
        let provider: BSANManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let isPb: Bool = (try? provider.getBsanSessionManager().isPB().getResponseData()) ?? false
        let appRepositoryProtocol: AppRepositoryProtocol = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        appRepositoryProtocol.changeLanguage(language: requestValues.language)
        
        let newLanguage = Language.createFromType(languageType: requestValues.language, isPb: isPb)
        return UseCaseResponse.ok(UpdateLanguageUseCaseOkOutput(language: newLanguage))
    }
}

struct UpdateLanguageUseCaseInput {
    let language: LanguageType
}

struct UpdateLanguageUseCaseOkOutput {
    let language: Language
}
