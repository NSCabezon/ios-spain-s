import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class OTPPushTests: BaseLibraryTests {
    
    override func setUp() {
        environmentDTO = BSANEnvironments.environmentCiber
        setLoginUser(newLoginUser: LOGIN_USER.iñaki)
        resetDataRepository()
        super.setUp()
    }
    
    func testRequestDevice() {
        do {
            let response = try bsanOTPPushManager!.requestDevice()
            let responseData = try response.getResponseData()
            guard responseData != nil else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: responseData, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testRequestDeviceUnregistered() {
        do {
            setLoginUser(newLoginUser: LOGIN_USER.MOBILE_RECHARGE_LOGIN)
            let response = try bsanOTPPushManager!.requestDevice()
            guard try response.getErrorMessage() != "SUPOTE_000002" else {
                logTestSuccess(result: "SUPOTE_000002", function: #function)
                return
            }
            logTestError(errorMessage: "The device is already registered", function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testRequestSignature() {
        do {
            let response = try bsanSignatureManager!.requestOTPPushRegisterDevicePositions()
            guard let signature = try response.getResponseData() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: signature, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateRegisterDevice() {
        do {
            let response = try bsanSignatureManager!.requestOTPPushRegisterDevicePositions()
            guard var signature = try response.getResponseData() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            TestUtils.fillSignature(input: &signature.signatureDTO)
            let responseValidate = try bsanOTPPushManager!.validateRegisterDevice(signature: signature)
            guard try responseValidate.getResponseData() != nil else {
                logTestError(errorMessage: "RETURNED NO RESPONSE VALIDATE DATA", function: #function)
                return
            }
            logTestSuccess(result: true, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    /// To use this test, firts of all execute the `testValidateRegisterDevice` and copy:
    /// OTP token
    /// OTP ticket
    /// OTP code
    func testConfirmRegisterDevice() {
        do {
            let otpToken = "MTU1ODM1Mjc4ODY3NiMxNzIuMjEuMjI2LjcjMDBBQUFFODYjMSNVMVZRVDFSRlVFRlRUekk9I05PVCBVU0VEI05PVCBVU0VEIzAjY2FuYWxlc1NBTlBSRV9TSEExd2l0aFJTQSNlUkhTVGs0QlBteXlhRVRiUGt0dUpzVjl5eFUvTDRwMCtJVFZJdS9mVENOQUd6UXJkMEo5VXJ5RFd0eFBEOXNQZ2w2akxFbThmUVFSWC9QeGx6dVhkbHo1Z0xhb3JCYWMyM0hMSi9abjhrNklTcEpheTBkUXRhWUFTWUxmWDJwQlBpNnNaMFRUekQyN2FqY2NoVGFsYmxmckQvU1lrcUxtS0Z6bzQzQjJRZHM9"
            let optCode = "X504X468"
            let ticket = "270648AAAE86"
            let response = try bsanOTPPushManager!.registerDevice(
                otpValidation: OTPValidationDTO(token: otpToken, ticket: ticket, otpExcepted: false),
                otpCode: optCode,
                data: OTPPushConfirmRegisterDeviceInputDTO(
                    deviceUDID: "C380CA5E-5DED-479B-A889-E967DF440C76",
                    deviceToken: "8ac22930a750feccc64212eaa7dc6696c97fcfe85dc62de11c5936b9b4448f2c",
                    deviceAlias: "Alias",
                    deviceLanguage: "es_es",
                    deviceCode: "iPhone8,1",
                    deviceModel: "iPhone",
                    appVersion: "4.3.6",
                    sdkVersion: "3.7.3",
                    soVersion: "12.1"
                )
            )
            guard response.isSuccess() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: true, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testUpdateTokenPush() {
        do {
            let currentToken = "a9865ff5 953b74aa f8726590 b3630698 6ab6ddc7 876b9b90 efd21c79 b54b66e6"
            let newToken = "f0cc5e73 578a98c2 72fe38a6 2aea8c2e 12dd11b0 a42c274f 586a6ee1 5cbf33fc"            
            let response = try bsanOTPPushManager!.updateTokenPush(currentToken: currentToken, newToken: newToken)
            guard response.isSuccess() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: true, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateDeviceOTPPush() {
        do {
            let deviceToken = "8ac22930a750feccc64212eaa7dc6696c97fcfe85dc62de11c5936b9b4448f2c"
            let response = try bsanOTPPushManager!.validateDevice(deviceToken: deviceToken)
            guard try response.getResponseData() != nil else {
                logTestError(errorMessage: "RETURNED NO RESPONSE VALIDATE DATA", function: #function)
                return
            }
            logTestSuccess(result: true, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
}
