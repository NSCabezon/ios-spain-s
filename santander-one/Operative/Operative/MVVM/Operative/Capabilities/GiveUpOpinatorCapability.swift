//
//  GiveUpOpinatorCapability.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 19/1/22.
//

import CoreFoundationLib
import Localization
import OpenCombine
import UI

/// A capability that adds the navigation to the giveUpOpinator before the operative finish.
public final class DefaultGiveUpOpinatorCapability<Operative: ReactiveOperative>: WillFinishCapability, ProgressBarEnablerCapability {
    public let operative: Operative
    private let opinatorCoordinator: BindableCoordinator
    private let giveUpOpinator: OpinatorInfoRepresentable
    
    public init(operative: Operative, opinatorCoordinator: BindableCoordinator, giveUpOpinator: OpinatorInfoRepresentable) {
        self.operative = operative
        self.opinatorCoordinator = opinatorCoordinator
        self.giveUpOpinator = giveUpOpinator
    }
    
    public var willFinishPublisher: AnyPublisher<ConditionState, Never> {
        return Future { [unowned self] promise in
            guard !self.operative.stepsCoordinator.progress.isFinished else { return promise(.success(.success)) }
            self.goToOpinator { [weak self] in
                self?.showProgressBar()
                promise(.success(.success))
            }
        }
        .eraseToAnyPublisher()
    }
}

private extension DefaultGiveUpOpinatorCapability {
    func goToOpinator(completion: @escaping () -> Void) {
        opinatorCoordinator
            .set(giveUpOpinator)
        opinatorCoordinator.start()
        dismissProgressBar()
        operative.coordinator.childCoordinators.append(opinatorCoordinator)
        opinatorCoordinator.onFinish = { [unowned self] in
            self.operative.coordinator.childCoordinators.remove(self.opinatorCoordinator)
            completion()
        }
    }
}
