//
//  GetGlobalPositionUseCase.swift
//  CommonUseCase
//
//  Created by Laura González on 03/12/2020.
//

import Foundation

public typealias GetGlobalPositionUseCaseAlias = UseCase<Void, GetGlobalPositionUseCaseOkOutput, StringErrorOutput>

final public class GetGlobalPositionUseCase: GetGlobalPositionUseCaseAlias {
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetGlobalPositionUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        return UseCaseResponse.ok(GetGlobalPositionUseCaseOkOutput(globalPosition: globalPosition))
    }
}

public struct GetGlobalPositionUseCaseOkOutput {
    public let globalPosition: GlobalPositionWithUserPrefsRepresentable
}
