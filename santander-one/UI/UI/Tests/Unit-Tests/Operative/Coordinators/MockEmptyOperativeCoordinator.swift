//
//  MockEmptyOperativeCoordinator.swift
//  UI_ExampleTests
//
//  Created by José Carlos Estela Anguita on 20/1/22.
//

import Foundation
import Operative
import CoreFoundationLib
import UI
import OpenCombine

class MockEmptyOperativeCoordinator: OperativeCoordinator {
    
    lazy var stepsCoordinator: StepsCoordinator<MockStep> = {
        return StepsCoordinator(navigationController: navigationController, provider: stepProvider, steps: steps)
    }()
    var onFinish: (() -> Void)?
    var dataBinding: DataBinding
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var spyDismissPublisher = PassthroughSubject<Bool, Never>()
    var spyShowErrorPublisher = PassthroughSubject<String, Never>()
    var opinatorCoordinator: BindableCoordinator {
        return MockOpinatorCoordinator()
    }

    init(dataBinding: DataBinding = DataBindingObject(), childCoordinators: [Coordinator] = [], navigationController: UINavigationController? = nil) {
        self.dataBinding = dataBinding
        self.childCoordinators = childCoordinators
        self.navigationController = navigationController
    }
    
    func showLoadingPublisher() -> AnyPublisher<Void, Never> {
        return Just(()).eraseToAnyPublisher()
    }
    
    func dismissLoadingPublisher() -> AnyPublisher<Void, Never> {
        return Just(()).eraseToAnyPublisher()
    }
    
    func start() {
    }
    
    func next() {
    }
    
    func back() {
    }
    
    func goToGlobalPosition() {
    }

    func dismiss() {
        spyDismissPublisher.send(true)
    }
    
    func stepProvider(for step: MockStep) -> StepIdentifiable {
        return MockViewController()
    }
    
    var steps: [StepsCoordinator<MockStep>.Step] {
        return [.step(.step1), .step(.step2), .step(.step3), .step(.step4)]
    }
    
    func showLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    func dismissLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    func showOldDialog(title: LocalizedStylableText?, description: LocalizedStylableText, acceptAction: DialogButtonComponents, cancelAction: DialogButtonComponents?, isCloseOptionAvailable: Bool) {
        spyShowErrorPublisher.send(title?.plainText ?? description.text)
        acceptAction.action?()
    }
}

private class MockViewController: UIViewController, StepIdentifiable {}
