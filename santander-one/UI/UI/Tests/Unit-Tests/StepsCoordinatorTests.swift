//
//  StepsCoordinatorTests.swift
//  UI_ExampleTests
//
//  Created by José Carlos Estela Anguita on 30/11/21.
//

import XCTest
import UnitTestCommons
import UIKit
import OpenCombine
import CoreFoundationLib
@testable import UI

protocol MockStepsDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> Step1ViewController
    func resolve() -> Step2ViewController
    func resolve() -> Step3ViewController
    func resolve(for identifier: String) -> StepIdentifiable
}

class StepsCoordinatorTests: XCTestCase {
    
    enum TestStep: Equatable {
        case step1
        case step2
        case step3
        case custom(identifier: String)
    }
    
    fileprivate var navigationController: InstantNavigationController!
    var stepsCoordinator: StepsCoordinator<TestStep>!
    
    struct Dependencies: MockStepsDependenciesResolver {
        
        let navigationController: UINavigationController
        let step1: Step1ViewController
        let step2: Step2ViewController
        let step3: Step3ViewController
        let step4: Step4ViewController
        let step5: Step5ViewController
        
        func resolve() -> UINavigationController {
            return navigationController
        }
        
        func resolve() -> Step1ViewController {
            return step1
        }
        
        func resolve() -> Step2ViewController {
            return step2
        }
        
        func resolve() -> Step3ViewController {
            return step3
        }
        
        func resolve(for identifier: String) -> StepIdentifiable {
            switch identifier {
            case "Step4":
                return step4
            case "Step5":
                return step5
            default:
                fatalError()
            }
        }
    }
    
    var step1: Step1ViewController!
    var step2: Step2ViewController!
    var step3: Step3ViewController!
    var step4: Step4ViewController!
    var step5: Step5ViewController!
    var dependencies: Dependencies!

    override func setUpWithError() throws {
        // G
        step1 = Step1ViewController()
        step2 = Step2ViewController()
        step3 = Step3ViewController()
        step4 = Step4ViewController()
        step5 = Step5ViewController()
        navigationController = InstantNavigationController()
        dependencies = Dependencies(navigationController: navigationController, step1: step1, step2: step2, step3: step3, step4: step4, step5: step5)
        stepsCoordinator = StepsCoordinator(
            navigationController: navigationController, provider: provideStep, steps: [.step1, .step2, .step3].map({ .step($0) }))
    }

    override func tearDownWithError() throws {
        navigationController = nil
        stepsCoordinator = nil
        step1 = nil
        step2 = nil
        step3 = nil
        step4 = nil
        step5 = nil
    }

    func provideStep(_ step: TestStep) -> StepIdentifiable {
        switch step {
        case .step1: return dependencies.resolve() as Step1ViewController
        case .step2: return dependencies.resolve() as Step2ViewController
        case .step3: return dependencies.resolve() as Step3ViewController
        case .custom(identifier: let identifier): return dependencies.resolve(for: identifier)
        }
    }
    
    func test_stepsCoordinator_shouldReturn3NumberOfSteps_whenWeConfigure3StepsAsEnabled() {
        // G
        stepsCoordinator.start()
        // T
        XCTAssert(stepsCoordinator.totalSteps == 3)
    }
    
    func test_stepsCoordinator_shouldReturn2NumberOfSteps_whenWeConfigure2StepsAsEnabled_and1AsDisabled() {
        // G
        stepsCoordinator.start()
        // W
        stepsCoordinator.update(state: .disabled, for: .step2)
        // T
        XCTAssert(stepsCoordinator.totalSteps == 2)
    }
    
    func test_stepsCoordinator_shouldReturnStep3_whenWeConfigureTheStep2AsDisabled_andWeGoToTheNext() {
        // G
        stepsCoordinator.start()
        // W
        stepsCoordinator.update(state: .disabled, for: .step2)
        stepsCoordinator.next()
        // T
        XCTAssert(navigationController.topViewController == step3)
        XCTAssert(stepsCoordinator.progress.current == 2)
    }
    
    func test_stepsCoordinator_shouldReturnStep2_whenWePerformNextFromStep1() {
        // G
        stepsCoordinator.start()
        // W
        stepsCoordinator.next()
        // T
        XCTAssert(navigationController.topViewController == step2)
        XCTAssert(stepsCoordinator.progress.current == 1)
    }
    
    func test_stepsCoordinator_shouldReturnStep1_whenWeGoBackFromStep2() {
        // G
        stepsCoordinator.start()
        stepsCoordinator.next()
        // W
        stepsCoordinator.back()
        // T
        XCTAssert(navigationController.topViewController == step1)
        XCTAssert(stepsCoordinator.progress.current == 0)
    }
    
    func test_stepsCoordinator_shouldReturnStep1_whenWeGoBackFromStep3ToTheSpecificStep1() {
        // G
        stepsCoordinator.start()
        stepsCoordinator.next()
        stepsCoordinator.next()
        // W
        stepsCoordinator.back(to: .step1)
        // T
        XCTAssert(navigationController.topViewController == step1, String(describing: navigationController.topViewController))
        XCTAssert(stepsCoordinator.progress.current == 0)
    }
    
    func test_stepsCoordinator_shouldReturnStep1_whenWeGoBackFromStep2_andTheNavigationHasAnotherViewControllerInFirstPosition() {
        // G
        navigationController.pushViewController(UIViewController(), animated: false)
        stepsCoordinator.start()
        stepsCoordinator.next()
        // W
        stepsCoordinator.back()
        // T
        XCTAssert(navigationController.topViewController == step1)
        XCTAssert(stepsCoordinator.progress.current == 0)
    }
    
    func test_stepsCoordinator_shouldReturnStep1_whenWeGoBackFromStep3ToTheSpecificStep1_andTheNavigationHasAnotherViewControllerInFirstPosition() {
        // G
        navigationController.pushViewController(UIViewController(), animated: false)
        stepsCoordinator.start()
        stepsCoordinator.next()
        stepsCoordinator.next()
        // W
        stepsCoordinator.back(to: .step1)
        // T
        XCTAssert(navigationController.topViewController == step1)
        XCTAssert(stepsCoordinator.progress.current == 0)
    }
    
    func test_stepsCoordinator_shouldReturnStep2_whenWeGoBackFromStep3ToTheSpecificStep2_andTheStep2WasOriginallyDisabled() {
        // G
        navigationController.pushViewController(UIViewController(), animated: false)
        stepsCoordinator.update(state: .disabled, for: .step2)
        stepsCoordinator.start()
        stepsCoordinator.next()
        // W
        stepsCoordinator.update(state: .enabled, for: .step2)
        stepsCoordinator.back(to: .step2)
        // T
        XCTAssert(navigationController.topViewController == step2)
        XCTAssert(stepsCoordinator.progress.current == 1)
    }
    
    func test_stepsCoordinator_shouldReturnStep1_whenWeGoBackFromStep3ToTheSpecificStep1_andTheStep1WasOriginallyDisabled() {
        // G
        navigationController.pushViewController(UIViewController(), animated: false)
        stepsCoordinator.update(state: .disabled, for: .step1)
        stepsCoordinator.start()
        stepsCoordinator.next()
        // W
        stepsCoordinator.update(state: .enabled, for: .step1)
        stepsCoordinator.back(to: .step1)
        // T
        XCTAssert(navigationController.topViewController == step1)
        XCTAssert(stepsCoordinator.progress.current == 0)
    }
    
    func test_stepsCoordinator_shouldReturnStep4_whenWeGoBackToTheSpecificStep4_andThisStepIsConfiguredWithACustomIdentifier() {
        // G
        stepsCoordinator = StepsCoordinator(navigationController: navigationController, provider: provideStep, steps: [.custom(identifier: "Step4"), .custom(identifier: "Step5"), .step1, .step2, .step3].map({ .step($0) }))
        stepsCoordinator.start()
        stepsCoordinator.next()
        stepsCoordinator.next()
        // W
        stepsCoordinator.back(to: .custom(identifier: "Step4"))
        // T
        XCTAssert(navigationController.topViewController == step4)
        XCTAssert(stepsCoordinator.progress.current == 0)
    }
    
    func test_stepsCoordinator_shouldReturn4Steps_whenWeHave3StepsAtCreation_andWeAddedOneAfterTheStep3() {
        // W
        stepsCoordinator.add(step: .custom(identifier: "Step4"), after: .step3)
        // T
        XCTAssert(stepsCoordinator.progress.total == 4)
    }
    
    func test_stepsCoordinator_shouldReturn4Steps_whenWeHave3StepsAtCreation_andWeAddedOneBeforeTheStep3() {
        // W
        stepsCoordinator.add(step: .custom(identifier: "Step4"), before: .step3)
        // T
        XCTAssert(stepsCoordinator.progress.total == 4)
    }
    
    func test_stepsCoordinator_shouldReturn4Steps_whenWeHave3StepsAtCreation_andWeAddedOneBeforeTheStep1() {
        // W
        stepsCoordinator.add(step: .custom(identifier: "Step4"), before: .step1)
        // T
        XCTAssert(stepsCoordinator.progress.total == 4)
    }
    
    func test_stepsCoordinator_shouldReturn4Steps_whenWeHave3StepsAtCreation_andWeAddedOneAfterTheStep1() {
        // W
        stepsCoordinator.add(step: .custom(identifier: "Step4"), after: .step1)
        // T
        XCTAssert(stepsCoordinator.progress.total == 4)
    }
    
    func test_stepsCoordinator_shouldReturnStep4_whenWeHave3StepsAtCreation_weAddedOneAfterTheStep3_andWeGoToThisStep() {
        // G
        stepsCoordinator.start()
        // W
        stepsCoordinator.add(step: .custom(identifier: "Step4"), after: .step3)
        stepsCoordinator.next()
        stepsCoordinator.next()
        stepsCoordinator.next()
        // T
        XCTAssert(navigationController.topViewController == step4)
        XCTAssert(stepsCoordinator.progress.current == 3)
    }
    
    func test_stepsCoordinator_shouldReturnToOrigin_whenWeFinishIt() {
        // G
        let viewController = UIViewController()
        navigationController.pushViewController(viewController, animated: false)
        stepsCoordinator.start()
        // W
        stepsCoordinator.finish()
        // T
        XCTAssert(navigationController.topViewController == viewController)
        XCTAssert(stepsCoordinator.progress.current == -1)
    }
}

class Step1ViewController: UIViewController, StepIdentifiable {}
class Step2ViewController: UIViewController, StepIdentifiable {}
class Step3ViewController: UIViewController, StepIdentifiable {}
class Step4ViewController: UIViewController, StepIdentifiable {}
class Step5ViewController: UIViewController, StepIdentifiable {}

private class InstantNavigationController: UINavigationController {
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: false)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: false)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        super.popToViewController(viewController, animated: false)
    }
}
