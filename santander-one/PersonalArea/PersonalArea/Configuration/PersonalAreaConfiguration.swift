//
//  PersonalAreaConfiguration.swift
//  PersonalArea
//
//  Created by alvola on 08/11/2019.
//

import CoreFoundationLib

public final class PersonalAreaConfiguration {    
    weak var pushNotificationPermissionsManager: PushNotificationPermissionsManagerProtocol?
    weak var locationPermissionsManager: LocationPermissionsManagerProtocol?
    weak var localAuthPermissionsManager: LocalAuthenticationPermissionsManagerProtocol?
    weak var contactsPermissionsManager: ContactPermissionsManagerProtocol?
    
    public init(pushNotificationPermissionsManager: PushNotificationPermissionsManagerProtocol?,
                locationPermissionsManager: LocationPermissionsManagerProtocol?,
                localAuthPermissionsManager: LocalAuthenticationPermissionsManagerProtocol?,
                contactsPermissionsManager: ContactPermissionsManagerProtocol?) {
        self.pushNotificationPermissionsManager = pushNotificationPermissionsManager
        self.locationPermissionsManager = locationPermissionsManager
        self.localAuthPermissionsManager = localAuthPermissionsManager
        self.contactsPermissionsManager = contactsPermissionsManager
    }
}
