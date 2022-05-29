//
//  SharedHandler.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/11/19.
//

import Foundation
import CoreFoundationLib

public enum ShareType {
    case text
    case imageWhatsapp(UIShareView, UIView)
    case image(UIShareView, UIView)
    case mail
    case sms
}

public class SharedHandler {
    
    public init() {}
    
    public func doShare(for item: Shareable, in controller: UIViewController, type: ShareType? = .text) {
        guard let type = type else { return }
        switch type {
        case .text: self.shareByText(item: item, in: controller)
        case .image(let shareView, let viewToShare): self.shareByImage(shareView, in: controller, viewToShare: viewToShare, onlyWhatsApp: false)
        case .imageWhatsapp(let shareView, let viewToShare): self.shareByImage(shareView, in: controller, viewToShare: viewToShare, onlyWhatsApp: true)
        case .mail: self.shareByMail(item: item, in: controller)
        case .sms: self.shareBySms(item: item, in: controller)
        }
    }
    
    public func shareByImage(_ item: UIShareView?, in controller: UIViewController, viewToShare: UIView?, onlyWhatsApp: Bool) {
        guard let item = item, let viewToShare = viewToShare else { return }
        let share: ShareHandleUseCase = .shareImage(preview: item, shareView: viewToShare, onlyWhatsApp: onlyWhatsApp)
        share.show(from: controller)
    }

    func shareByMail(item: Shareable, in controller: UIViewController) {
        let richStringToShare = item.getRichShareableInfo()
        let stringToShare = item.getShareableInfo()
        let share: ShareHandleUseCase = .mail(delegate: controller, content: stringToShare, subject: nil, toRecipients: [], isHTML: richStringToShare != nil)
        guard share.canShare() else { return }
        share.show(from: controller)
    }

    func shareBySms(item: Shareable, in controller: UIViewController) {
        let share: ShareHandleUseCase = .sms(delegate: controller, content: item.getShareableInfo())
        guard share.canShare() else {  return }
        share.show(from: controller)
    }

    func shareByText(item: Shareable, in controller: UIViewController) {
        let share: ShareHandleUseCase = .share(content: item.getShareableInfo())
        share.show(from: controller)
    }
}
