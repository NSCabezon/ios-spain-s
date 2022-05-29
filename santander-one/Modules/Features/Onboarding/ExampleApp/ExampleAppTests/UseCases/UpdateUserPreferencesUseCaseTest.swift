//
//  UpdateUserPreferencesUseCaseTest.swift
//  ExampleAppTests
//
//  Created by Jose Ignacio de Juan Díaz on 31/12/21.
//

import Foundation
import XCTest
import OpenCombine
import CoreTestData
import CoreDomain
import UnitTestCommons
import QuickSetup
@testable import Onboarding

class UpdateUserPreferencesUseCaseTest: XCTestCase {
    private var anySubscriptions: Set<AnyCancellable> = []
    let external = TestOnboardingExternalDependencies()
    lazy var sut: DefaultUpdateUserPreferencesUseCase = {
        return DefaultUpdateUserPreferencesUseCase(dependencies: external)
    }()
    
    func test_fetch() throws {
        let userPreferences = UserPreferences()
        sut.updatePreferences(update: userPreferences)
        let userPreferencesRepository: UserPreferencesRepository = external.resolve()
        let mockedUserPreferencesRepository = userPreferencesRepository as? UserPreferencesRepositoryMock
        let updatedUserPreferences = mockedUserPreferencesRepository?.spyUpdateUserPreferences
        XCTAssertEqual(userPreferences.userId, updatedUserPreferences?.userId)
        XCTAssertEqual(userPreferences.alias, updatedUserPreferences?.alias)
        XCTAssertEqual(userPreferences.photoThemeOptionSelected, updatedUserPreferences?.photoThemeOptionSelected)
        XCTAssertEqual(userPreferences.globalPositionOptionSelected, updatedUserPreferences?.globalPositionOptionSelected)
        XCTAssertEqual(userPreferences.pgColorMode, updatedUserPreferences?.pgColorMode)
    }
}

private extension UpdateUserPreferencesUseCaseTest {
    struct UserPreferences: UpdateUserPreferencesRepresentable {
        let userId = "12345"
        let alias: String? = "UpdatedAlias"
        var photoThemeOptionSelected: Int? = 9
        var globalPositionOptionSelected: GlobalPositionOptionEntity? = .smart
        var pgColorMode: PGColorMode?  = .black
    }
}
