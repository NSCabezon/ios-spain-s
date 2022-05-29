//
//  GetReportMovementsPhoneNumberUseCase.swift
//  GlobalSearch
//
//  Created by alvola on 02/03/2020.
//

import CoreFoundationLib

class GetReportMovementsPhoneNumberUseCase: UseCase<GetReportMovementsPhoneNumberUseCaseInput, GetReportMovementsPhoneNumberUseCaseOkOutput, StringErrorOutput> {
    override func executeUseCase(requestValues: GetReportMovementsPhoneNumberUseCaseInput) throws -> UseCaseResponse<GetReportMovementsPhoneNumberUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository = requestValues.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let phone = appConfigRepository.getString("duplicatedMovementsPhoneNumber")
        
        return UseCaseResponse.ok(GetReportMovementsPhoneNumberUseCaseOkOutput(phone: phone))
    }
}

struct GetReportMovementsPhoneNumberUseCaseOkOutput {
    let phone: String?
}

struct GetReportMovementsPhoneNumberUseCaseInput {
    let dependenciesResolver: DependenciesResolver
}
