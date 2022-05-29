//
//  DialogViewCapable.swift
//  UI
//
//  Created by Jose Carlos Estela Anguita on 16/01/2020.
//

import Foundation
import CoreFoundationLib

public protocol DialogViewPresentationCapable: GenericErrorDialogPresentationCapable {
    var associatedDialogView: UIViewController { get }
}

extension DialogViewPresentationCapable {
    
    public func showDialog(
        title: String? = nil,
        items: [Dialog.Item],
        image: String? = nil,
        action: Dialog.Action? = nil,
        isCloseOptionAvailable: Bool = true
    ) {
        let dialog = Dialog(
            title: title,
            items: items,
            image: image,
            actionButton: action,
            isCloseButtonAvailable: isCloseOptionAvailable
        )
        dialog.show(in: self.associatedDialogView)
    }
    
    public func showDialog(
        title: String? = nil,
        items: [Dialog.Item],
        image: String? = nil,
        action: Dialog.Action? = nil,
        closeButton: Dialog.CloseButton,
        hasTitleAndNotAlignment: Bool = true
    ) {
        let dialog = Dialog(
            title: title,
            items: items,
            image: image,
            actionButton: action,
            closeButton: closeButton,
            hasTitleAndNotAlignment: hasTitleAndNotAlignment
        )
        dialog.show(in: self.associatedDialogView)
    }

    public func showDialog(
        withDependenciesResolver dependenciesResolver: DependenciesResolver,
        title: String? = nil,
        description: String? = nil,
        image: String? = nil,
        action: Dialog.Action? = nil,
        isCloseOptionAvailable: Bool = true
    ) {
        guard let items = description.map(items) else { return self.showGenericErrorDialog(withDependenciesResolver: dependenciesResolver) }
        let dialog = Dialog(
            title: title,
            items: items,
            image: image,
            actionButton: action,
            isCloseButtonAvailable: isCloseOptionAvailable
        )
        dialog.show(in: self.associatedDialogView)
    }
    
    private func items(for string: String?) -> [Dialog.Item] {
        guard let string = string else { return [] }
        return [.text(string)]
    }
    
    public var associatedGenericErrorDialogView: UIViewController {
        return self.associatedDialogView
    }
}
