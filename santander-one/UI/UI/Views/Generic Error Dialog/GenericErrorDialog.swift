//
//  GenericErrorDialog.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 13/04/2020.
//

import Foundation
import CoreFoundationLib

public protocol GenericErrorDialogPresentationCapable: AnyObject {
    var associatedGenericErrorDialogView: UIViewController { get }
}

extension GenericErrorDialogPresentationCapable {
    
    public func showGenericErrorDialog(withDependenciesResolver dependenciesResolver: DependenciesResolver, action: (() -> Void)? = nil, closeAction: (() -> Void)? = nil) {
        let coordinator = GenericErrorDialogCoordinator(dependenciesResolver: dependenciesResolver,
                                                        viewController: self.associatedGenericErrorDialogView,
                                                        action: action,
                                                        closeAction: closeAction)
        coordinator.start()
    }
}

extension GenericErrorDialogPresentationCapable where Self: UIViewController {
    
    public var associatedGenericErrorDialogView: UIViewController {
        return self
    }
}
