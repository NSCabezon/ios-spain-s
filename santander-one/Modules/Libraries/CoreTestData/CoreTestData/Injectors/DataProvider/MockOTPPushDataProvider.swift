//
//  MockOTPPushDataProvider.swift
//  CoreTestData
//
//  Created by Juan Jose Acosta González on 10/9/21.
//

import SANLegacyLibrary

public class MockOTPPushDataProvider {
    public var requestDevice: OTPPushDeviceDTO!
    public var validateRegisterDevice: OTPValidationDTO!
    public var registerDevice: ConfirmOTPPushDTO!
    public var validateDevice: OTPPushValidateDeviceDTO!
    public var getValidatedDeviceState: ReturnCodeOTPPush!
}
