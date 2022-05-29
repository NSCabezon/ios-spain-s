import CoreFoundationLib
import SANLegacyLibrary

class SetLanguageUseCase: UseCase<SetLanguageUseCaseInput, SetLanguageUseCaseOkOutput, StringErrorOutput> {
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider

    init(appRepository: AppRepository, bsanManagersProvider: BSANManagersProvider) {
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: SetLanguageUseCaseInput) throws -> UseCaseResponse<SetLanguageUseCaseOkOutput, StringErrorOutput> {
        _ = appRepository.setLanguage(language: requestValues.language)
        let isPB = try checkRepositoryResponse(bsanManagersProvider.getBsanSessionManager().isPB())
        let newLanguage = Language.createFromType(languageType: requestValues.language, isPb: isPB)
        return UseCaseResponse.ok(SetLanguageUseCaseOkOutput(language: newLanguage))
    }
}
struct SetLanguageUseCaseInput {
    let language: LanguageType
}

struct SetLanguageUseCaseOkOutput {
    let language: Language
}
