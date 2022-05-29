import CoreFoundationLib
import SANLegacyLibrary

class HasAnyManagerUseCase: UseCase<Void, HasAnyManagerUseCaseOkOutput, HasAnyManagerUseCaseErrorOutput> {

    private let bsanManagersProvider: BSANManagersProvider

    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
        super.init()
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<HasAnyManagerUseCaseOkOutput, HasAnyManagerUseCaseErrorOutput> {
        let response = try bsanManagersProvider.getBsanManagersManager().getManagers()
        if !response.isSuccess() {
            return UseCaseResponse.error(HasAnyManagerUseCaseErrorOutput(try response.getErrorMessage()))
        }
        let managerListDTO = try checkRepositoryResponse(response)

        let hasAny = (managerListDTO != nil)
            ? !managerListDTO!.managerList.isEmpty
            : false
        let managerName = managerListDTO?.managerList.first?.nameGest
    
        return UseCaseResponse.ok(HasAnyManagerUseCaseOkOutput(hasAny: hasAny, managerName: managerName))
    }
}

class HasAnyManagerUseCaseOkOutput {

    let hasAny: Bool
    let managerName: String?

    init(hasAny: Bool, managerName: String? = nil) {
        self.hasAny = hasAny
        self.managerName = managerName
    }
}

class HasAnyManagerUseCaseErrorOutput: StringErrorOutput {}
