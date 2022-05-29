//
//  PersonalAreaServiceInjector.swift
//  PersonalArea
//
//  Created by Juan Jose Acosta González on 9/9/21.
//

import QuickSetup
import CoreTestData

public final class PersonalAreaServiceInjector: CustomServiceInjector {
    public init() {}
    public func inject(injector: MockDataInjector) {
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
        injector.register(
            for: \.pullOffersConfig.getPullOffersConfig,
            filename: "pull_offers_configV4_without_cushion"
        )
        injector.register(
            for: \.appConfigLocalData.getAppConfigLocalData,
            filename: "app_config_v2"
        )
        injector.register(
            for: \.signatureData.getCMCSignature,
            filename: "getCMCSignature"
        )
        injector.register(
            for: \.signatureData.validateSignatureActivation,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.signatureData.validateOTPOperability,
            filename: "validateOTPOperability"
        )
        injector.register(
            for: \.signatureData.consultPensionSignaturePositions,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.signatureData.consultSendMoneySignaturePositions,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.signatureData.consultCardsPayOffSignaturePositions,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.signatureData.consultCashWithdrawalSignaturePositions,
            filename: "mockSignatureWithTokenDTO"
        )
        
        injector.register(
            for: \.signatureData.consultChangeSignSignaturePositions,
            filename: "mockSignatureWithTokenDTO"
        )
        
        injector.register(
            for: \.signatureData.consultScheduledSignaturePositions,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.signatureData.consultCardLimitManagementPositions,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.signatureData.requestOTPPushRegisterDevicePositions,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.signatureData.consultBillAndTaxesSignaturePositions,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.signatureData.requestApplePaySignaturePositions,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.otpPushData.requestDevice,
            filename: "requestDevice"
        )
        injector.register(
            for: \.otpPushData.validateRegisterDevice,
            filename: "validateRegisterDevice"
        )
        injector.register(
            for: \.otpPushData.registerDevice,
            filename: "registerDevice"
        )
        injector.register(
            for: \.otpPushData.validateDevice,
            filename: "validateDevice"
        )
        injector.register(
            for: \.otpPushData.getValidatedDeviceState,
            filename: "getValidatedDeviceState"
        )
        injector.register(
            for: \.pullOffers.getCampaigns,
            filename: "getCampaigns"
        )
    }
}
