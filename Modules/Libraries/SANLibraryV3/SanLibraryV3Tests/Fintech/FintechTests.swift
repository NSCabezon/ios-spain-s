import XCTest
@testable import SanLibraryV3

class FintechTests: BaseLibraryTests {

    override func setUpWithError() throws {
        environmentDTO = BSANEnvironments.enviromentPreWas9
        setLoginUser(newLoginUser: LOGIN_USER.BIZUM_HISTORIC)
        resetDataRepository()
        super.setUp()
    }

    func test_confirmWithAccessKeyService_withAuthenticationAndUserInfoParams_shouldHaveResponseData() {
        let authenticationParams = FintechUserAuthenticationInputParams(
            clientId: "PSDES-FINA-1111111",
            responseType: "code",
            state: "init",
            scope: "AIS PIS SVA FCS",
            redirectUri: "https://lanzaderapsd2-san-estruc-api-pre.appls.boaw.paas.gsnetcloud.corp/callbackRedsys.html",
            token: "eyJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJHT0lUIiwib3BlcmF0aW9uIjp7ImpvdXJuZXlUeXBlIjoiQ09OU0VOVCIsImFsbG93ZWRSZWFsbXMiOiIwIiwiY2xpZW50X2lkIjoiUFNERVMtRklOQS0xMTExMTExIiwib3JnSWQiOiI1MDAiLCJ0cmFuc2FjdGlvblN0YXR1cyI6IklOSVRJQVRFRCIsInJlcXVlc3RJRCI6ImFkMTJiOTk1YjI0NGZkZjMiLCJhdXRvbWF0ZWRMb2dpbiI6ZmFsc2V9fQ.fcg9ufUI-d9USE7raZy6KBQyLs08wVVPY7m_d0bJOOXxKpbmAsQFHIyxUYLEFCxOrYxxJsqGNem_tp8LQ3v9Rw")
        let userInfo = FintechUserInfoAccessKeyParams(
            authenticationType: "C",
            documentType: "N",
            documentNumber: "47736534B",
            password: "14725836",
            ip: "11.111.11.1")
        do {
            let confirmWithAccessKeyResponse = try bsanFintechManager?.confirmWithAccessKey(
                authenticationParams: authenticationParams,
                userInfo: userInfo)
            logTestSuccess(result: try? confirmWithAccessKeyResponse?.getResponseData(), function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }

    func test_service_withFootprint_shouldHaveError() {
        let authenticationParams = FintechUserAuthenticationInputParams(
            clientId: "PSDES-FINA-1111111",
            responseType: "code",
            state: "init",
            scope: "AISPISSVAFCS",
            redirectUri: "https://lanzaderapsd2-san-estruc-api-pre.appls.boaw.paas.gsnetcloud.corp/callbackRedsys.html",
            token: "eyJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJHT0lUIiwib3BlcmF0aW9uIjp7ImpvdXJuZXlUeXBlIjoiQ09OU0VOVCIsImFsbG93ZWRSZWFsbXMiOiIwIiwiY2xpZW50X2lkIjoiUFNERVMtRklOQS0xMTExMTExIiwib3JnSWQiOiI1MDAiLCJ0cmFuc2FjdGlvblN0YXR1cyI6IklOSVRJQVRFRCIsInJlcXVlc3RJRCI6ImFkMTJiOTk1YjI0NGZkZjMiLCJhdXRvbWF0ZWRMb2dpbiI6ZmFsc2V9fQ.fcg9ufUI-d9USE7raZy6KBQyLs08wVVPY7m_d0bJOOXxKpbmAsQFHIyxUYLEFCxOrYxxJsqGNem_tp8LQ3v9Rw")
        let userInfo = FintechUserInfoFootprintParams(
            authenticationType: "B",
            documentType: "N",
            documentNumber: "05735578E",
            deviceToken: "MTYxNzYyMDM5ODQ1MSNlYzBlNGVmMC0xZDBlLTNkNDYtOTQ2Ni1hODAyZWNiNzgxMWUjY2FuYWxlc1NBTlBSRSNTSEExd2l0aFJTQSNQc2p4TGVsdWkwUjZBN2x1ajN2dWd2My9DeGlUMW1CTnZzMTZ0ZFcyVzlvekE0N1pMbWdlMHI1Njhsd09WN1RQTU9IYjR0N0E4elNERVY1Q0EzMW5IMS9YMjBycW9KOHQyS3AvbkRaUVB1cCtTWkh1TnhCcUxmRC9TUUxLQ0kwdDdFOVpLN0Faa2tvUUs4dHlYU090ejEyazRTOGhQV21JZ3dtYVdUdDFhbGc9",
            footprint: "MTU0NDI1ZDQxYWVhMDRiMGE2MDg0NjEyYWE5NGRmNjU5M2QyMmFkZjA5NzAxYmI0OTIzNWY3YTM5OWQ0OWFmMw==",
            ip: "11.111.11.1")

        guard let confirmWithAccessKeyResponse = try? bsanFintechManager?.confirmWithFootprint(
                authenticationParams: authenticationParams,
                userInfo: userInfo) else { return XCTFail("Request was success ")  }
            logTestSuccess(result: try? confirmWithAccessKeyResponse.getErrorMessage(), function: #function)
    }
}
