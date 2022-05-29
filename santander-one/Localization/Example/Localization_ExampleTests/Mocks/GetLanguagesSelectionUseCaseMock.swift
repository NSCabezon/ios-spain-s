//
//  File.swift
//  Localization_ExampleTests
//
//  Created by Francisco del Real Escudero on 11/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CoreFoundationLib
@testable import CoreFoundationLib

class GetLanguagesSelectionUseCaseMock: GetLanguagesSelectionUseCase {
    private var output: GetLanguagesSelectionUseCaseOkOutput!
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
        return .ok(output)
    }
    
    func updateOutput(language: Language, list: [LanguageType]) {
        self.output = GetLanguagesSelectionUseCaseOkOutput(current: language)
    }
}
