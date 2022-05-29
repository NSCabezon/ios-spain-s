//
//  GetLanguagesSelectionUseCaseMock.swift
//  ExampleApp
//
//  Created by Rubén Márquez Fernández on 6/7/21.
//  Copyright © 2021 Jose Carlos Estela Anguita. All rights reserved.
//

import Foundation
import CoreFoundationLib


final class GetLanguagesSelectionUseCaseMock: UseCase<Void, GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetLanguagesSelectionUseCaseOkOutput(current: .createDefault(isPb: false, defaultLanguage: .spanish, availableLanguageList: [.spanish])))
    }
}

extension GetLanguagesSelectionUseCaseMock: GetLanguagesSelectionUseCaseProtocol {}
