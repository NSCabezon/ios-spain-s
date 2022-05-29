//
//  OperativeFinished.swift
//  Operative
//
//  Created by Jose Carlos Estela Anguita on 18/12/2019.
//

import Foundation

public protocol OperativeFinishingCoordinator {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative)
}

public protocol OperativeFinishingCoordinatorCapable {
    var finishingCoordinator: OperativeFinishingCoordinator { get set }
}

/// To perform any action when operative did finish
public protocol OperativeFinishingCapable {
    func operativeDidFinish()
}
