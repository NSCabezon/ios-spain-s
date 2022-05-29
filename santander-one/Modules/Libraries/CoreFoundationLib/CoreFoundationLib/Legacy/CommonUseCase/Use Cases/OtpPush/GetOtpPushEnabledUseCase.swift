//
//  GetOtpPushEnabledUseCase.swift
//  PersonalArea
//
//  Created by Iván Estévez on 29/05/2020.
//


public final class GetOtpPushEnabledUseCase: UseCase<Void, GetOtpPushEnabledUseCaseOutput, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetOtpPushEnabledUseCaseOutput, StringErrorOutput> {
        let otpPushEnabled = appConfigRepository.getBool("enableOtpPush") ?? false
        return UseCaseResponse.ok(GetOtpPushEnabledUseCaseOutput(otpPushEnabled: otpPushEnabled))
    }
}

public struct GetOtpPushEnabledUseCaseOutput {
    public let otpPushEnabled: Bool
}
