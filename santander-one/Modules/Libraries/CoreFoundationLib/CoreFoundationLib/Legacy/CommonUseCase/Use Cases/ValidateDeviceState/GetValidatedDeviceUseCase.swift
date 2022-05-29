//
//  GetValidatedDeviceUseCase.swift
//  PersonalArea
//
//  Created by Juan Carlos López Robles on 2/3/20.
//
import Foundation
import SANLegacyLibrary

public class GetValidatedDeviceUseCase: UseCase<Void, GetValidatedDeviceUseCaseOutput, StringErrorOutput> {

    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    override public func executeUseCase(requestValues: Void) throws ->
    UseCaseResponse<GetValidatedDeviceUseCaseOutput, StringErrorOutput> {
        let response = try self.provider.getBsanOTPPushManager().getValidatedDeviceState()

        guard response.isSuccess(),
              let data = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        let state = ValidatedDeviceStateEntity(rawValue: data.rawValue) ?? .notRegisteredDevice
        return .ok(GetValidatedDeviceUseCaseOutput(state: state))
    }
}

public struct GetValidatedDeviceUseCaseOutput {
    public let state: ValidatedDeviceStateEntity
}
