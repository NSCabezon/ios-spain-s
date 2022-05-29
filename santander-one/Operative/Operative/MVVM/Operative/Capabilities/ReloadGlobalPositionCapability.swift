//
//  DefaultReloadGlobalPositionCapability.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 21/1/22.
//

import Foundation
import OpenCombine
import CoreFoundationLib
import CoreDomain

/// A cability for reloading global position before the operative ending.
public struct DefaultReloadGlobalPositionCapability<Operative: ReactiveOperative>: WillFinishCapability {
    
    public let operative: Operative
    private let sessionDataManager: SessionDataManager
    
    public init(operative: Operative, dependencies: ReactiveOperativeExternalDependencies) {
        self.operative = operative
        self.sessionDataManager = dependencies.resolve()
    }
    
    public var willFinishPublisher: AnyPublisher<ConditionState, Never> {
        return self.operative.coordinator.showLoadingPublisher()
            .setFailureType(to: Error.self)
            .flatMap { _ in
                return self.sessionDataManager.loadPublisher()
            }
            .flatMap { _ in
                return self.operative.coordinator.dismissLoadingPublisher()
            }
            .handleEvents(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    showError(error)
                case .finished:
                    break
                }
            })
            .map { _ in
                return .success
            }
            .replaceError(with: .failure)
            .eraseToAnyPublisher()
    }
}

private extension DefaultReloadGlobalPositionCapability {
    
    func showError(_ error: Error) {
        operative.coordinator.showOldDialog(
            title: nil,
            description: localized(error.localizedDescription),
            acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil),
            cancelAction: nil,
            isCloseOptionAvailable: false
        )
    }
}
