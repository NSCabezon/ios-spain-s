//
//  XCTestCase+Extension.swift
//  UnitTestCommons
//
//  Created by José Carlos Estela Anguita on 15/12/20.
//

import XCTest
import CoreFoundationLib

public extension XCTestCase {
    
    func XCTAssertUseCaseResult<Output, Error: StringErrorOutput>(for useCase: UseCase<Void, Output, Error>, output: (Output) -> Bool) {
        do {
            let response = try useCase.executeUseCase(requestValues: ()).getOkResult()
            XCTAssert(output(response))
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func XCTAssertUseCaseResult<Input, Output, Error: StringErrorOutput>(for useCase: UseCase<Input, Output, Error>, input: Input, output: (Output) -> Bool) {
        do {
            let response = try useCase.executeUseCase(requestValues: input).getOkResult()
            XCTAssert(output(response))
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
