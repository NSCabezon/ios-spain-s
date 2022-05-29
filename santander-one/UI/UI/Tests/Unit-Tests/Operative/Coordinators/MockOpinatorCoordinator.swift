//
//  MockOpinatorCoordinator.swift
//  UI_ExampleTests
//
//  Created by José Carlos Estela Anguita on 11/1/22.
//

import Foundation
import UI
import CoreFoundationLib
import OpenCombine

final class MockOpinatorCoordinator: BindableCoordinator {
    
    var spyStartPublisher = CurrentValueSubject<Bool, Never>(false)
    var onFinish: (() -> Void)?
    var dataBinding: DataBinding = DataBindingObject()
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    
    func start() {
        spyStartPublisher.send(true)
    }
}
