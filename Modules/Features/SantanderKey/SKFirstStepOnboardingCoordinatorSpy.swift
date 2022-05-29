//
//  SKFirstStepOnboardingCoordinatorSpy.swift
//  ExampleAppTests
//
//  Created by Ali Ghanbari Dolatshahi on 16/2/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import UI
@testable import SantanderKey

public class SKFirstStepOnboardingCoordinatorSpy : SKFirstStepOnboardingCoordinator {
    
    var goToPublicOfferCalled: Bool = false
    var goToSecondStepCalled: Bool = false

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
    
    public func goToPublicOffer(offer: OfferRepresentable) {
        self.goToPublicOfferCalled = true
    }
    
    public func goToSecondStep() {
        self.goToSecondStepCalled = true
    }
}
