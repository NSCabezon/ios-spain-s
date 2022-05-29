//
//  MockSignatureDataProvider.swift
//  CoreTestData
//
//  Created by Juan Jose Acosta González on 10/9/21.
//

import SANLegacyLibrary
import CoreDomain

public class MockSignatureDataProvider {
    public var getCMCSignature: SignStatusInfo!
    public var validateSignatureActivation: SignatureWithTokenDTO!
    public var validateOTPOperability: OTPValidationDTO!
    public var consultPensionSignaturePositions: SignatureWithTokenDTO!
    public var consultSendMoneySignaturePositions: SignatureWithTokenDTO!
    public var consultCardsPayOffSignaturePositions: SignatureWithTokenDTO!
    public var consultCashWithdrawalSignaturePositions: SignatureWithTokenDTO!
    public var consultChangeSignSignaturePositions: SignatureWithTokenDTO!
    public var consultScheduledSignaturePositions: SignatureWithTokenDTO!
    public var consultCardLimitManagementPositions: SignatureWithTokenDTO!
    public var requestOTPPushRegisterDevicePositions: SignatureWithTokenDTO!
    public var consultBillAndTaxesSignaturePositions: SignatureWithTokenDTO!
    public var requestApplePaySignaturePositions: SignatureWithTokenDTO!
}
