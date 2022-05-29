//
//  AppStoreInformationUseCase.swift
//  RetailLegacy
//
//  Created by Mario Rosales Maillo on 18/1/22.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public protocol AppStoreInformationUseCase: UseCase<Void, AppStoreInformationUseCaseOkOutput, StringErrorOutput> {}

public struct AppStoreInformationUseCaseOkOutput {
    let storeId: Int
    
    public init(storeId: Int) {
        self.storeId = storeId
    }
}
