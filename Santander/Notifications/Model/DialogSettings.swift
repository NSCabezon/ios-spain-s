//
//  DialogSettings.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 19/04/2021.
//
import CorePushNotificationsService
import CoreFoundationLib

struct DialogSettings: PushDialogSettings {
    var title: String
    var message: String
    var postDeepLinkNavigation: DeepLinkEnumerationCapable?
}
