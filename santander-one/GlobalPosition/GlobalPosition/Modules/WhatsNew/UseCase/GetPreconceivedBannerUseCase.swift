//
//  GetPreconceivedBannerUseCase.swift
//  GlobalPosition
//
//  Created by Laura González on 21/07/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

final class GetPreconceivedBannerUseCase: GetPregrantedLimitsUseCase {
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPregrantedLimitsUseCaseOkOutput, StringErrorOutput> {
        let appconfigRepository: AppConfigRepositoryProtocol = self.resolver.resolve()
        guard appconfigRepository.getBool("enableWhatsNewPregrantedBanner") == true else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return try self.loadLoanBanner()
    }
}
