//
//  MockOperativeCoordinatorGiveUpDialog.swift
//  UI_ExampleTests
//
//  Created by José Carlos Estela Anguita on 11/1/22.
//

import Foundation
import Operative
import CoreFoundationLib
import UI
import OpenCombine

final class MockOperativeCoordinatorGiveUpDialog: MockEmptyOperativeCoordinator {
    
    var spyGiveUpDialogPublisher = CurrentValueSubject<Bool, Error>(false)
    
    override func showOldDialog(title: LocalizedStylableText?, description: LocalizedStylableText, acceptAction: DialogButtonComponents, cancelAction: DialogButtonComponents?, isCloseOptionAvailable: Bool) {
        spyGiveUpDialogPublisher.send(true)
    }
}
