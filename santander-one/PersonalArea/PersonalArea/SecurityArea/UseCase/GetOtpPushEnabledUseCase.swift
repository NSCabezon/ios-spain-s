//
//  GetOtpPushEnabledUseCase.swift
//  PersonalArea
//
//  Created by Iván Estévez on 29/05/2020.
//

import CoreFoundationLib

final class GetOtpPushEnabledUseCase: UseCase<Void, GetOtpPushEnabledUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetOtpPushEnabledUseCaseOutput, StringErrorOutput> {
        let appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let otpPushEnabled = appConfigRepository.getBool("enableOtpPush") ?? false
        return UseCaseResponse.ok(GetOtpPushEnabledUseCaseOutput(otpPushEnabled: otpPushEnabled))
    }
}

public struct GetOtpPushEnabledUseCaseOutput {
    public let otpPushEnabled: Bool
}
