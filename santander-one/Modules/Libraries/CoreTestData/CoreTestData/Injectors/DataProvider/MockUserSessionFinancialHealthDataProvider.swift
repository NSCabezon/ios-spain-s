//
//  MockUserSessionFinancialHealthDataProvider.swift
//  CoreTestData
//
//  Created by Miguel Ferrer Fornali on 7/3/22.
//

import Foundation
import CoreDomain
import SANLegacyLibrary

public class MockUserSessionFinancialHealthDataProvider {
    public var saveUserData: Void!
    public var getUserData: MockFinancialHealthUserData!
}

// MARK: GetUserData
public struct MockFinancialHealthUserData: UserDataAnalysisAreaRepresentable {
    public var periodSelector: PeriodSelectorRepresentable? = MockPeriodSelectorRepresentable()
    public var timeSelector: TimeSelectorRepresentable? = MockTimeSelectorRepresentable()
}

public struct MockPeriodSelectorRepresentable: PeriodSelectorRepresentable {
    public var startPeriod: Date = Date()
    public var endPeriod: Date = Date()
    public var indexSelected: Int = 0
}

public struct MockTimeSelectorRepresentable: TimeSelectorRepresentable {
    public var timeViewSelected: TimeViewOptions = .mounthly
    public var startDateSelected: Date?
    public var endDateSelected: Date = Date()
    public func clearDates() {}
}
