import CoreFoundationLib

public protocol GetInfoSideMenuUseCaseProtocol: UseCase<GetInfoSideMenuUseCaseInput, GetInfoSideMenuUseCaseOkOutput, StringErrorOutput> {}

public final class GetInfoSideMenuUseCase: UseCase<GetInfoSideMenuUseCaseInput, GetInfoSideMenuUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: GetInfoSideMenuUseCaseInput) throws -> UseCaseResponse<GetInfoSideMenuUseCaseOkOutput, StringErrorOutput> {
        let localAppConfig = self.dependenciesResolver.resolve(for: LocalAppConfig.self)
        if localAppConfig.isPortugal {
            return self.getAlias(requestValues)
        } else {
            return self.getName(requestValues)
        }
    }
}

private extension GetInfoSideMenuUseCase {
    func getName(_ requestValues: GetInfoSideMenuUseCaseInput) -> UseCaseResponse<GetInfoSideMenuUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetInfoSideMenuUseCaseOkOutput(infoSideMenuEntity: InfoSideMenuEntity(availableName: requestValues.globalPosition.availableName.camelCasedString, initials: requestValues.globalPosition.initials)))
    }
    
    func getAlias(_ requestValues: GetInfoSideMenuUseCaseInput) -> UseCaseResponse<GetInfoSideMenuUseCaseOkOutput, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = self.dependenciesResolver.resolve()
        guard let userId = appRepositoryProtocol.getSharedPersistedUser()?.userId,
              !appRepositoryProtocol.getUserPreferences(userId: userId).pgUserPrefDTO.alias.isEmpty
              else {
            return self.getName(requestValues)
        }
        let userPrefEntity = appRepositoryProtocol.getUserPreferences(userId: userId)
        let entity = InfoSideMenuEntity(availableName: userPrefEntity.pgUserPrefDTO.alias, initials: userPrefEntity.pgUserPrefDTO.alias.nameInitials)
        return .ok(GetInfoSideMenuUseCaseOkOutput(infoSideMenuEntity: entity))
    }
}

public struct GetInfoSideMenuUseCaseInput {
    let globalPosition: GlobalPositionNameProtocol
    
    public init(globalPosition: GlobalPositionNameProtocol) {
        self.globalPosition = globalPosition
    }
}

public struct GetInfoSideMenuUseCaseOkOutput {
    public let infoSideMenuEntity: InfoSideMenuEntityRepresentable
}

extension GetInfoSideMenuUseCase: GetInfoSideMenuUseCaseProtocol { }
