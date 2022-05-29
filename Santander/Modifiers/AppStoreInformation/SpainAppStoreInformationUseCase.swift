//
//  SpainAppStoreInformationUseCase.swift
//  Santander
//
//  Created by Mario Rosales Maillo on 1/2/22.
//

import Foundation
import RetailLegacy
import CoreFoundationLib

final class SpainAppStoreInformationUseCase: UseCase<Void, AppStoreInformationUseCaseOkOutput, StringErrorOutput>, AppStoreInformationUseCase {
    
    private enum Contants {
        static let appStoreId: Int = 408043474
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<AppStoreInformationUseCaseOkOutput, StringErrorOutput> {
        let info = AppStoreInformationUseCaseOkOutput(storeId: Contants.appStoreId)
        return .ok(info)
    }
}
