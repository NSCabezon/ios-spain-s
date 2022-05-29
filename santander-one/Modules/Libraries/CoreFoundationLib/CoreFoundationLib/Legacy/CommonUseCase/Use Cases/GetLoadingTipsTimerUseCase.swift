//
//  GetLoadingTipsTimerUseCase.swift
//  CommonUseCase
//
//  Created by Luis Escámez Sánchez on 22/04/2020.
//

import Foundation

public class GetLoadingTipsTimerUseCase: UseCase<Void, GetLoadingTipsTimerUseCaseOutput, StringErrorOutput> {
    
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    public init(appConfigRepository: AppConfigRepositoryProtocol) {
        self.appConfigRepository = appConfigRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLoadingTipsTimerUseCaseOutput, StringErrorOutput> {
        return UseCaseResponse.ok(GetLoadingTipsTimerUseCaseOutput(timer: appConfigRepository.getString("timerLoadingTips")))
    }
}

public struct GetLoadingTipsTimerUseCaseOutput {
    public let timer: String?
}
