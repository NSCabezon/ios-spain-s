//
//  TransferDetailType.swift
//  Transfer
//
//  Created by alvola on 29/07/2021.
//

import CoreFoundationLib

public protocol TransferDetailTypeDelegate: AnyObject {
    func showPDF()
    func reuseTransfer()
    func shareAction()
    func editTransfer()
    func deleteTransfer()
}

public protocol TransferDetailTypeActionsModifierProtocol {
    func customActionsFor(type: TransferDetailType, delegate: TransferDetailTypeDelegate) -> [TransferDetailActionViewModel]?
}

public enum TransferDetailType {
    case emitted(transferDetail: EmittedTransferDetailForPDFProtocol?, transfer: TransferEmittedEntity, account: AccountEntity)
    case received(transfer: TransferReceivedEntity?, fromAccount: AccountEntity?, account: AccountEntity)
    case scheduled(account: AccountEntity, transfer: ScheduledTransferRepresentable?, transferDetail: ScheduledTransferDetailEntity?, originAccount: AccountEntity?)
    
    func actionsWith(delegate: TransferDetailTypeDelegate) -> [TransferDetailActionViewModel] {
        switch self {
        case .emitted:
            return [showPDFAction(block: delegate.showPDF),
                    reuseAction(block: delegate.reuseTransfer)]
        case .received:
            return [showPDFAction(block: delegate.showPDF),
                    shareAction(block: delegate.shareAction)]
        case .scheduled:
            return [
                deleteAction(block: delegate.deleteTransfer),
                editAction(block: delegate.editTransfer)
            ]
        }
    }
    
    var titleForNavBar: String {
        switch self {
        case .emitted:
            return "toolbar_title_deliveryDetails"
        case .received:
            return "genericToolbar_title_detail"
        case .scheduled:
            return "toolbar_title_deliveryDetails"
        }
    }
    
    public func showPDFAction(block: @escaping () -> Void) -> TransferDetailActionViewModel {
        return TransferDetailActionViewModel(
            title: TransferDetailActionButtonType.pdf.titleFor(transferType: self),
            imageNamed: TransferDetailActionButtonType.pdf.iconFor(transferType: self),
            action: block,
            accessibilityIdentifier: "deliveryDetails_button_downloadPDF"
        )
    }
    
    public func reuseAction(block: @escaping () -> Void) -> TransferDetailActionViewModel {
        return TransferDetailActionViewModel(
            title: TransferDetailActionButtonType.resend.titleFor(transferType: self),
            imageNamed: TransferDetailActionButtonType.resend.iconFor(transferType: self),
            action: block,
            accessibilityIdentifier: "deliveryDetails_button_sendAgain"
        )
    }
    
    public func shareAction(block: @escaping () -> Void) -> TransferDetailActionViewModel {
        return TransferDetailActionViewModel(
            title: TransferDetailActionButtonType.share.titleFor(transferType: self),
            imageNamed: TransferDetailActionButtonType.share.iconFor(transferType: self),
            action: block,
            accessibilityIdentifier: "generic_button_share"
        )
    }
    
    public func deleteAction(block: @escaping () -> Void) -> TransferDetailActionViewModel {
        return TransferDetailActionViewModel(
            title: TransferDetailActionButtonType.delete.titleFor(transferType: self),
            imageNamed: TransferDetailActionButtonType.delete.iconFor(transferType: self),
            action: block,
            accessibilityIdentifier: "generic_buttom_delete"
        )
    }
    
    public func editAction(block: @escaping () -> Void) -> TransferDetailActionViewModel {
        return TransferDetailActionViewModel(
            title: TransferDetailActionButtonType.edit.titleFor(transferType: self),
            imageNamed: TransferDetailActionButtonType.edit.iconFor(transferType: self),
            action: block,
            accessibilityIdentifier: "generic_buttom_edit"
        )
    }
}
