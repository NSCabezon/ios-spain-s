//
//  GiveUpDialogCapability.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 19/1/22.
//

import Foundation
import UI
import OpenCombine
import CoreFoundationLib
import Localization

/// A capability that shows a GiveUp dialog before the operative finish.
public struct DefaultGiveUpDialogCapability<Operative: ReactiveOperative>: WillFinishCapability {
    
    public let operative: Operative
    
    public init(operative: Operative) {
        self.operative = operative
    }
    
    public var willFinishPublisher: AnyPublisher<ConditionState, Never> {
        return Future { promise in
            guard !operative.stepsCoordinator.progress.isFinished else { return promise(.success(.success)) }
            self.showGiveUpDialog {
                promise(.success(.success))
            }
        }
        .eraseToAnyPublisher()
    }
}

private extension DefaultGiveUpDialogCapability {
    
    func showGiveUpDialog(acceptAction: @escaping () -> Void) {
        operative.coordinator.showOldDialog(
            title: localized("modal_title_stopOperation"),
            description: localized("modal_text_stopOperation"),
            acceptAction: DialogButtonComponents(titled: localized("modal_buton_goOut"), does: {
                acceptAction()
            }),
            cancelAction: DialogButtonComponents(titled: localized("generic_button_cancel"), does: nil),
            isCloseOptionAvailable: true
        )
    }
}
