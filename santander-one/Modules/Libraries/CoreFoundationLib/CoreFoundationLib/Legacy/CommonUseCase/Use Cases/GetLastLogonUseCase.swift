//
//  GetLastLogonUseCase.swift
//  CommonUseCase
//
//  Created by Luis Escámez Sánchez on 05/08/2020.
//

import Foundation
import SANLegacyLibrary

public protocol GetLastLogonUseCaseProtocol: UseCase<Void, LastLogonInfoOkOutput, StringErrorOutput> { }

public class GetLastLogonUseCase: UseCase<Void, LastLogonInfoOkOutput, StringErrorOutput> {
    
    private let managersProvider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    private let timeManager: TimeManager
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.managersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.timeManager = dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LastLogonInfoOkOutput, StringErrorOutput> {
        let manager = managersProvider.getLastLogonManager()
        let response = try manager.getLastLogonInfo()
        guard response.isSuccess(), let lastLogonDTO = try response.getResponseData() else {
            let errorMessage = try response.getErrorMessage()
            return  UseCaseResponse.error(StringErrorOutput(errorMessage))
        }
        return UseCaseResponse.ok(LastLogonInfoOkOutput(lastLogonInfoEntity: createLastLogonEntity(from: lastLogonDTO)))
    }
}

    // MARK: - Private Methods
private extension GetLastLogonUseCase {
    
    func createLastLogonEntity(from dto: LastLogonDTO) -> GetLastLogonInfoEntity? {
        guard let date = dto.lastConnection else { return nil }
        let lastConnection = timeManager.fromString(input: date, inputFormat: .yyyyMMddHHmmss, timeZone: .local)
        return GetLastLogonInfoEntity(lastConnection: lastConnection, uid: dto.uid)
    }
}

public struct LastLogonInfoOkOutput {
    public let lastLogonInfoEntity: GetLastLogonInfoEntity?
    
    public init(lastLogonInfoEntity: GetLastLogonInfoEntity?) {
        self.lastLogonInfoEntity = lastLogonInfoEntity
    }
}

extension GetLastLogonUseCase: GetLastLogonUseCaseProtocol { }
