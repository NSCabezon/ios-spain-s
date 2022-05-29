//
//  GlobalSearchEnabledManager.swift
//  Commons
//
//  Created by alvola on 24/02/2020.
//

import SANLegacyLibrary

public protocol GlobalSearchEnabledManagerProtocol: AnyObject { }

public extension GlobalSearchEnabledManagerProtocol {
    func getIsSearchEnabled(with resolver: DependenciesResolver, _ completion: @escaping (Bool) -> Void) {
        let input: GetSearchEnabledUseCaseInput = GetSearchEnabledUseCaseInput(dependenciesResolver: resolver)
        let usecase = GetSearchEnabledUseCase()
        let usecaseHandler: UseCaseHandler = resolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input),
                       useCaseHandler: usecaseHandler,
                       onSuccess: { (resp) in
                        completion(resp.isSearchEnabled)
        },
                       onError: { (_) in
                        completion(false) })
    }
}

public class GetSearchEnabledUseCase: UseCase<GetSearchEnabledUseCaseInput, GetSearchEnabledUseCaseOkOutput, StringErrorOutput> {
    override public func executeUseCase(requestValues: GetSearchEnabledUseCaseInput) throws -> UseCaseResponse<GetSearchEnabledUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository = requestValues.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let searchEnabled = appConfigRepository.getBool("enableGlobalSearch") ?? false
        return UseCaseResponse.ok(GetSearchEnabledUseCaseOkOutput(
            isSearchEnabled: searchEnabled)
        )
    }
}

public struct GetSearchEnabledUseCaseInput {
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    let dependenciesResolver: DependenciesResolver
}

public struct GetSearchEnabledUseCaseOkOutput {
    public let isSearchEnabled: Bool
}
