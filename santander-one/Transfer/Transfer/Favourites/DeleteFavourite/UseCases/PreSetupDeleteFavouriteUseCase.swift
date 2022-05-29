import CoreFoundationLib

protocol PreSetupDeleteFavouriteUseCaseProtocol: UseCase<Void, PreSetupDeleteUseCaseOkOutput, StringErrorOutput> { }

final class PreSetupDeleteFavouriteUseCase: UseCase<Void, PreSetupDeleteUseCaseOkOutput, StringErrorOutput> {
    private let dependencies: DependenciesResolver
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupDeleteUseCaseOkOutput, StringErrorOutput> {
        let sepaInfoRepository = self.dependencies.resolve(for: SepaInfoRepositoryProtocol.self)
        let sepaInfoListEntity = SepaInfoListEntity(dto: sepaInfoRepository.getSepaList())
        return .ok(PreSetupDeleteUseCaseOkOutput(sepaList: sepaInfoListEntity))
    }
}

struct PreSetupDeleteUseCaseOkOutput {
    let sepaList: SepaInfoListEntity
}

extension PreSetupDeleteFavouriteUseCase: PreSetupDeleteFavouriteUseCaseProtocol { }
