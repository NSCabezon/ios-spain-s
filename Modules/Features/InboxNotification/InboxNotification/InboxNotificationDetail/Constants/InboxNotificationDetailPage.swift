//
//  InboxNotificationDetailPage.swift
//  InboxNotification
//
//  Created by José María Jiménez Pérez on 19/5/21.
//

import Foundation
import CoreFoundationLib

struct InboxNotificationDetailPage: PageWithActionTrackable {
    typealias ActionType = Action
    let page = "notificaciones_detalle_notificacion"
    
    enum Action: String {
        case delete = "borrar"
        case shareSms = "sms"
        case shareMail = "email"
        case shareOther = "compartir"
    }
}
