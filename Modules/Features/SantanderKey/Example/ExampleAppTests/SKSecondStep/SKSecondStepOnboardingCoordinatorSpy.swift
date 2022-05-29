//
//  SKSecondStepOnboardingCoordinatorSpy.swift
//  ExampleAppTests
//
//  Created by Ali Ghanbari Dolatshahi on 17/2/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import UI
@testable import SantanderKey
import XCTest

public class SKSecondStepOnboardingCoordinatorSpy: SKSecondStepOnboardingCoordinator {
    var goToGlobalPositionCalled: Bool = false

    public var dataBinding: DataBinding
    public var childCoordinators: [Coordinator]
    public var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    
    init() {
        childCoordinators = []
        dataBinding = DataBindingObject()
    }
    
    public func start() {
    }
    
    public func goToGlobalPosition() {
        self.goToGlobalPositionCalled = true
    }
    
    public func goToBiometricsStep() {
        XCTAssertTrue(true)
    }
    
}
