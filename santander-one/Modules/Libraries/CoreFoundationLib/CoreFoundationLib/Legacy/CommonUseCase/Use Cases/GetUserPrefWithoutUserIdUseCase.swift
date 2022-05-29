//
//  GetUserPrefWithoutUserIdUseCase.swift
//  CommonUseCase
//
//  Created by David Gálvez Alonso on 17/07/2020.
//


public class GetUserPrefWithoutUserIdUseCase: UseCase<Void, GetUserPrefWithoutUserIdUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetUserPrefWithoutUserIdUseCaseOkOutput, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = dependenciesResolver.resolve()
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve()
        guard let userId = globalPosition.userId else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let userPrefDTO = appRepositoryProtocol.getUserPreferences(userId: userId)
        
        return UseCaseResponse.ok(GetUserPrefWithoutUserIdUseCaseOkOutput(userPref: UserPrefEntity.from(dto: userPrefDTO)))
    }
}

public struct GetUserPrefWithoutUserIdUseCaseOkOutput {
    public let userPref: UserPrefEntity
}
