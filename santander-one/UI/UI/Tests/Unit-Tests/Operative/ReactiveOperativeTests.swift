//
//  ReactiveOperativeTests.swift
//  UI_ExampleTests
//
//  Created by José Carlos Estela Anguita on 10/1/22.
//

import Foundation
import XCTest
import UI
import CoreFoundationLib
import UnitTestCommons
import RxCombine
import OpenCombine
@testable import Operative

// TODO: Move to Operative

final class ReactiveOperativeTests: XCTestCase {
    
    fileprivate var navigationController: InstantNavigationController!
    var setupCapability: MockSetupCapability<MockOperative>!
    var preSetupCapability: MockPreSetupCapability<MockOperative>!
    var giveUpDialogCapability: DefaultGiveUpDialogCapability<MockOperative>!
    var shouldShowCapability: ShouldShowStepCapability<MockOperative>!
    var reloadGlobalPositionCapability: DefaultReloadGlobalPositionCapability<MockOperative>!
    
    override func setUpWithError() throws {
        navigationController = InstantNavigationController()
    }
    
    override func tearDownWithError() throws {
        navigationController = nil
        setupCapability = nil
        reloadGlobalPositionCapability = nil
    }
    
    func test_operative_onOperativeStart_whenTheOperativeIsOfTypeSetupCapable_shouldCallSetup() throws {
        // G
        let coordinator = MockEmptyOperativeCoordinator()
        let operative = MockOperative(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator) { _ in
            return [
                self.setupCapability.asAnyCapability()
            ]
        }
        setupCapability = MockSetupCapability(operative: operative)
        // W
        operative.start()
        // T
        XCTAssertForPublisher(setupCapability.spySetupSubject, output: true)
    }
    
    func test_operative_onOperativeStart_whenTheOperativeIsOfTypeSetupCapable_andTheSetupFails_shouldNotCallNext() throws {
        // G
        let coordinator = MockEmptyOperativeCoordinator()
        let operative = MockOperative(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator) { _ in
            return [
                self.setupCapability.asAnyCapability()
            ]
        }
        setupCapability = MockSetupCapability(operative: operative)
        setupCapability.result = .failure
        // W
        operative.start()
        // T
        let subject = CurrentValueSubject<Bool, Never>(false)
        operative.stepsCoordinator
            .willShowNextPublisher
            .dropFirst()
            .sink { _ in
                subject.send(true)
            }
            .store(in: &operative.subscriptions)
        XCTAssertForPublisher(subject, toEventuallyNot: true)
    }
    
    func test_operative_onOperativeStart_whenTheOperativeHasThePreSetupCapability_andAlsoHasTheSetupCapability_shouldCallPreSetupAndSetup() throws {
        // G
        let coordinator = MockEmptyOperativeCoordinator()
        let operative = MockOperative(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator) { _ in
            return [
                self.preSetupCapability.asAnyCapability(),
                self.setupCapability.asAnyCapability()
            ]
        }
        setupCapability = MockSetupCapability(operative: operative)
        preSetupCapability = MockPreSetupCapability(operative: operative)
        // W
        operative.start()
        // T
        XCTAssertForPublisher(preSetupCapability.spyPreSetupSubject, output: true)
        XCTAssertForPublisher(setupCapability.spySetupSubject, output: true)
    }
    
    func test_operative_onOperativeStart_whenTheOperativeHasThePreSetupCapability_andAlsoHasTheSetupCapability_andThePreSetupFails_shouldNotCallToSetup() throws {
        // G
        let coordinator = MockEmptyOperativeCoordinator()
        let operative = MockOperative(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator) { _ in
            return [
                self.preSetupCapability.asAnyCapability(),
                self.setupCapability.asAnyCapability()
            ]
        }
        setupCapability = MockSetupCapability(operative: operative)
        preSetupCapability = MockPreSetupCapability(operative: operative)
        preSetupCapability.result = .failure
        // W
        operative.start()
        // T
        XCTAssertForPublisher(preSetupCapability.spyPreSetupSubject, output: true)
        XCTAssertForPublisher(setupCapability.spySetupSubject, toEventuallyNot: true)
    }
    
    func test_operative_onOperativeFinish_whenTheOperativeHasTheGiveUpDialogCapability_andWeAreNotInTheFinalStep_shouldShowOldDialog() {
        // G
        let coordinator = MockOperativeCoordinatorGiveUpDialog()
        let operative = MockOperative(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator) { _ in
            return [
                self.giveUpDialogCapability.asAnyCapability()
            ]
        }
        giveUpDialogCapability = DefaultGiveUpDialogCapability(operative: operative)
        // W
        operative.start()
        operative.finish()
        // T
        XCTAssertForPublisher(coordinator.spyGiveUpDialogPublisher, output: true)
    }
    
    func test_operative_onOperativeFinish_whenTheOperativeHasTheGiveUpDialogCapability_andWeAreInTheFinalStep_shouldNotCallGiveUpDialog() {
        // G
        let coordinator = MockOperativeCoordinatorGiveUpDialog()
        let operative = MockOperative(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator) { _ in
            return [
                self.giveUpDialogCapability.asAnyCapability()
            ]
        }
        giveUpDialogCapability = DefaultGiveUpDialogCapability(operative: operative)
        // W
        operative.start()
        operative.next()
        operative.next()
        operative.next()
        operative.finish()
        // T
        XCTAssertForPublisher(coordinator.spyGiveUpDialogPublisher, assert: { $0 != true })
    }
    
    func test_operative_whenTheOperativeHasTheGiveUpOpinatorCapability_shouldCallGiveUpOpinator() {
        // G
        let opinatorCoordinator = MockOpinatorCoordinator()
        let coordinator = MockEmptyOperativeCoordinator()
        let operative = MockOperativeWithGiveUpOpinator(coordinator: coordinator, opinatorCoordinator: opinatorCoordinator, stepsCoordinator: coordinator.stepsCoordinator)
        // W
        operative.start()
        operative.finish()
        // T
        let opinator: OpinatorInfoRepresentable? = opinatorCoordinator.dataBinding.get()
        XCTAssert(opinator?.endPoint == "mock")
        XCTAssertForPublisher(opinatorCoordinator.spyStartPublisher, output: true)
    }
    
    func test_operative_whenTheOperativeHasTheProgressBarCapability_onOperativeStart_shouldShowTheProgressBar_ifTheProgressBarIsEnabledForFirstStep() {
        // G
        let coordinator = MockEmptyOperativeCoordinator(navigationController: navigationController)
        let operative = MockOperativeWithProgressBar(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator, shouldShowProgress: { step in
            switch step {
            default: return true
            }
        })
        // W
        operative.start()
        // T
        XCTAssertForObservation(object: operative.capability.progressBar, keyPath: \.isHidden, expectedValue: false)
    }
    
    func test_operative_whenTheOperativeHasTheProgressBarCapability_onOperativeStart_shouldNotShowTheProgressBar_ifTheProgressBarIsDisabledForFirstStep() {
        // G
        let coordinator = MockEmptyOperativeCoordinator(navigationController: navigationController)
        let operative = MockOperativeWithProgressBar(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator, shouldShowProgress: { step in
            switch step {
            case .step1: return false
            default: return true
            }
        })
        // W
        operative.start()
        // T
        XCTAssertForObservation(object: operative.capability.progressBar, keyPath: \.isHidden, expectedValue: true)
    }
    
    func test_operative_whenTheOperativeHasTheProgressBarCapability_onOperativeNext_shouldDismissTheProgressBar_ifTheProgressBarIsDisabledInTheNextStep() {
        // G
        let coordinator = MockEmptyOperativeCoordinator(navigationController: navigationController)
        let operative = MockOperativeWithProgressBar(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator, shouldShowProgress: { step in
            switch step {
            case .step1: return true
            case .step2: return false
            default: return false
            }
        })
        // W
        operative.start()
        operative.next()
        // T
        XCTAssertForObservation(object: operative.capability.progressBar, keyPath: \.isHidden, expectedValue: true)
    }
    
    func test_operative_whenTheOperativeHasTheProgressBarCapability_onOperativeNext_shouldShowTheProgressBar_ifTheProgressBarIsEnabledInTheNextStep() {
        // G
        let coordinator = MockEmptyOperativeCoordinator(navigationController: navigationController)
        let operative = MockOperativeWithProgressBar(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator, shouldShowProgress: { step in
            switch step {
            case .step1: return false
            case .step2: return true
            default: return false
            }
        })
        // W
        operative.start()
        operative.next()
        // T
        XCTAssertForObservation(object: operative.capability.progressBar, keyPath: \.isHidden, expectedValue: false)
    }
    
    func test_operative_whenTheOperativeHasTheProgressBarCapability_onOperativeStart_shouldUpdateTheProgress_withATotalOf10_andTheCurrentAs0() {
        // G
        let coordinator = MockEmptyOperativeCoordinator(navigationController: navigationController)
        let operative = MockOperativeWithProgressBar(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator, shouldShowProgress: { step in
            switch step {
            default: return true
            }
        })
        // W
        operative.start()
        // T
        XCTAssertForPublisher(operative.stepsCoordinator.progressPublisher, assert: {
            return $0.total == 4 && $0.current == 0
        })
    }
    
    func test_operative_whenTheOperativeHasTheProgressBarCapability_onOperativeNext_shouldUpdateTheProgress_withATotalOf10_andTheCurrentAs1() {
        // G
        let coordinator = MockEmptyOperativeCoordinator(navigationController: navigationController)
        let operative = MockOperativeWithProgressBar(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator, shouldShowProgress: { step in
            switch step {
            default: return true
            }
        })
        // W
        operative.start()
        operative.next()
        // T
        XCTAssertForPublisher(operative.stepsCoordinator.progressPublisher, assert: {
            return $0.total == 4 && $0.current == 1
        })
    }
    
    func test_operative_whenTheOperativeHasTheProgressBarCapability_onOperativeBack_shouldShowTheProgressBar_ifTheProgressBarIsEnabledInThePreviousStep() {
        // G
        let coordinator = MockEmptyOperativeCoordinator(navigationController: navigationController)
        let operative = MockOperativeWithProgressBar(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator, shouldShowProgress: { step in
            switch step {
            case .step1: return true
            case .step2: return false
            default: return false
            }
        })
        // W
        operative.start()
        operative.next()
        operative.back()
        // T
        XCTAssertForObservation(object: operative.capability.progressBar, keyPath: \.isHidden, expectedValue: false)
    }
    
    func test_operative_whenTheOperativeHasTheShouldShowStepCapability_onOperativeNext_ifTheSecondStepIsNotAvailable_shouldGoToTheThird() {
        // G
        let coordinator = MockEmptyOperativeCoordinator(navigationController: navigationController)
        let operative = MockOperative(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator) { _ in
            return [
                self.shouldShowCapability.asAnyCapability()
            ]
        }
        shouldShowCapability = ShouldShowStepCapability(operative: operative, shouldShowStep: { step in
            switch step {
            case .step2: return false
            default: return true
            }
        })
        // W
        operative.start()
        operative.next()
        // T
        XCTAssertForPublisher(operative.stepsCoordinator.progressPublisher, assert: {
            return $0.total == 4 && $0.current == 2
        })
    }
    
    func test_operative_whenTheOperativeHasTheDefaultReloadGlobalPositionCapability_onOperativeFinish_shouldCallSessionDataManager_andFinishCorrectly_whenTheReloadWorks() {
        // G
        let coordinator = MockEmptyOperativeCoordinator()
        let operative = MockOperative(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator) { _ in
            return [
                self.reloadGlobalPositionCapability.asAnyCapability()
            ]
        }
        reloadGlobalPositionCapability = DefaultReloadGlobalPositionCapability(operative: operative, dependencies: Dependencies(sessionDataManager: MockSessionDataManager(result: .success(()))))
        // W
        operative.start()
        operative.finish()
        // T
        XCTAssertForPublisher(coordinator.spyDismissPublisher, output: true)
    }
    
    func test_operative_whenTheOperativeHasTheDefaultReloadGlobalPositionCapability_onOperativeFinish_shouldCallSessionDataManager_andShowAnError_whenTheReloadDoesntWork() {
        // G
        let coordinator = MockEmptyOperativeCoordinator()
        let operative = MockOperative(coordinator: coordinator, stepsCoordinator: coordinator.stepsCoordinator) { _ in
            return [
                self.reloadGlobalPositionCapability.asAnyCapability()
            ]
        }
        reloadGlobalPositionCapability = DefaultReloadGlobalPositionCapability(operative: operative, dependencies: Dependencies(sessionDataManager: MockSessionDataManager(result: .failure(NSError(description: "error-reloading-global-position")))))
        // W
        operative.start()
        operative.finish()
        // T
        XCTAssertForPublisher(coordinator.spyShowErrorPublisher, output: "error-reloading-global-position")
    }
}

private final class MockSessionDataManager: SessionDataManager {
    var event: AnyPublisher<SessionManagerProcessEvent, Error> = Empty().eraseToAnyPublisher()
    var result: Result<Void, Error>
    func loadPublisher() -> AnyPublisher<Void, Error> {
        subject = PassthroughSubject<Void, Error>()
        load()
        return subject.eraseToAnyPublisher()
    }
    var subject = PassthroughSubject<Void, Error>()
    
    init(result: Result<Void, Error>) {
        self.result = result
    }
    
    func load() {
        Async.after(seconds: 0.5) {
            switch self.result {
            case .success:
                self.subject.send()
                self.subject.send(completion: .finished)
            case .failure(let error):
                self.subject.send(completion: .failure(error))
            }
        }
    }
    
    func cancel() {
        
    }
    
    func setDataManagerDelegate(_ delegate: SessionDataManagerDelegate?) {
        
    }
    
    func setDataManagerProcessDelegate(_ delegate: SessionDataManagerProcessDelegate?) {
        
    }
}

private struct Dependencies: ReactiveOperativeExternalDependencies {
    
    let sessionDataManager: SessionDataManager
    
    func resolve() -> SessionDataManager {
        return sessionDataManager
    }
    
    func resolve() -> DependenciesResolver {
        return DependenciesDefault(father: nil)
    }
}

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
