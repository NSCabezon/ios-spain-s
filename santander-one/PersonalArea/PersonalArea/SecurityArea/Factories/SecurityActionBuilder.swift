//
//  SecurityActionBuilder.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 20/01/2020.
//

import Foundation
import CoreFoundationLib
import LocalAuthentication
import UIKit.UIDevice

public enum SecurityActionType {
    case phone
    case email
    case biometrySystem
    case geolocation
    case secureDevice
    case operativeUser
    case changePassword
    case changeSignature
    case video
    case accountMovement
    case noAction
}

public final class SecurityActionBuilder {
    public var actions: [SecurityActionViewModelProtocol] = []
    private let securityActionComponents: SecurityActionComponentsProtocol
    public let userPreference: UserPrefWrapper
    
    public init(_ userPreference: UserPrefWrapper) {
        self.userPreference = userPreference
        self.securityActionComponents = SecurityActionComponents(userPreference)
    }
    
    public func addPhone() -> Self {
        guard let viewModel = self.securityActionComponents.addPhone(.phone) else { return self }
        self.actions.append(viewModel)
        return self
    }
    
    public func addMail() -> Self {
        guard let viewModel = self.securityActionComponents.addMail(.email) else { return self }
        self.actions.append(viewModel)
        return self
    }

    public func addBiometrySystem(customAction: CustomAction? = nil) -> Self {
        guard let viewModel = self.securityActionComponents.addBiometrySystem(customAction: customAction) else { return self }
        self.actions.append(viewModel)
        return self
    }
    
    public func addGeolocation() -> Self {
        let viewModel = self.securityActionComponents.addGeolocation()
        self.actions.append(viewModel)
        return self
    }
    
    public func addSecureDevice(_ state: ValidatedDeviceStateEntity,
                                _ offer: OfferEntity?,
                                _ isEnabledSantanderKey: Bool) -> Self {
        guard let viewModel = self.securityActionComponents.addSecureDevice(state, offer),
              !isEnabledSantanderKey else {
                  return self
              }
        self.actions.append(viewModel)
        return self
    }
    
    public func addUser() -> Self {
        let userOperability: String = self.userPreference.isOperativeUser ?? false ? localized("personalArea_label_operative") : localized("personalArea_label_advisory")
        let viewModel = self.securityActionComponents.addUser(
            action: .operativeUser,
            name: "personalArea_label_user",
            value: userOperability,
            toolTip: localized("tooltip_text_personalAreaUser"),
            externalAction: nil)
        self.actions.append(viewModel)
        return self
    }
    
    public func addPasswordSignatureKey() -> Self {
        let viewModel = self.securityActionComponents.addPasswordSignatureKey()
        self.actions.append(viewModel)
        return self
    }
    
    public func addSignatureKey() -> Self {
        let multiAction = SecurityActionViewModel(
            action: .changeSignature,
            nameKey: "personalArea_label_signatureKey",
            accessibilityIdentifiers: [
                .container: AccessibilitySecurityAreaAction.signatureContainer,
                .action: AccessibilitySecurityAreaAction.signatureAction
            ]
        )
        self.actions.append(multiAction)
        return self
    }
    
    public func addVideo(_ offer: OfferEntity?) -> Self {
        guard let offer = offer else { return self }
        let videoAction = SecurityVideoViewModel(
            action: .video,
            offer: offer,
            accessibilityIdentifiers: [
                .container: AccessibilitySecurityAreaAction.videoContainer,
                .action: AccessibilitySecurityAreaAction.videoAction
            ]
        )
        self.actions.append(videoAction)
        return self
    }
    
    public func build() -> [SecurityActionViewModelProtocol] {
        return self.actions
    }
}
