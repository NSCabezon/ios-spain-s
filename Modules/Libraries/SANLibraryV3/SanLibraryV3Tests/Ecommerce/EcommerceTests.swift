import CoreFoundationLib
import XCTest

@testable import SanLibraryV3

class EcommerceTests: BaseLibraryTests {

    override func setUpWithError() throws {
        environmentDTO = BSANEnvironments.enviromentPreWas9
        setLoginUser(newLoginUser: LOGIN_USER.BIZUM_HISTORIC)
        resetDataRepository()
        super.setUp()
    }

    override func tearDownWithError() throws {
        super.tearDown()
    }

    func testGetOperationDataShouldBeSuccess() {
        do {
            let tokenPush = "ab1b388dc3e6c74c33e86fe55d533e3fa3d482cde65331c4865f18977afcb9fb"
            let responseLastOperationUrlResponse = try bsanEcommerceManager?.getLastOperationShortUrl(documentType: "N",
                                                                                                      documentNumber: "05735578E",
                                                                                                      tokenPush: tokenPush)
            guard
                let dataResponse = try? responseLastOperationUrlResponse?.getResponseData(),
                let getOperationDataManager = try? bsanEcommerceManager?.getOperationData(shortUrl: dataResponse.shortUrl)
            else {
                return XCTFail("Fail to get operation data")
            }
            XCTAssertNotNil(try? getOperationDataManager.getResponseData())
        } catch {
            XCTFail("Fail to get short url")
        }
    }

    func testLastOperationUrlShouldBeSuccess() {
        do {
            let tokenPush = "ab1b388dc3e6c74c33e86fe55d533e3fa3d482cde65331c4865f18977afcb9fb"
            let manager = try bsanEcommerceManager?.getLastOperationShortUrl(documentType: "N",
                                                                             documentNumber: "05735578E",
                                                                             tokenPush: tokenPush)
            XCTAssertNotNil(try manager?.getResponseData())
        } catch {
            XCTFail("Fail load get last operation url")
        }
    }

    func testConfirmWithAccessKeyShouldBeSuccess() {
        do {
            let tokenPush = "ab1b388dc3e6c74c33e86fe55d533e3fa3d482cde65331c4865f18977afcb9fb"
            let keyBase64 = "MTQ3MjU4MzY="
            let responseLastOperationManager = try bsanEcommerceManager?.getLastOperationShortUrl(documentType: "N",
                                                                                                  documentNumber: "05735578E",
                                                                                                  tokenPush: tokenPush)
            guard
                let shortUrl = try? responseLastOperationManager?.getResponseData()?.shortUrl,
                let confirmWithAccessKeyResponse = try? bsanEcommerceManager?.confirmWithAccessKey(shortUrl: shortUrl, key: keyBase64)
            else {
                return XCTFail("Fail to get short url")
            }
            XCTAssertNotNil(try? confirmWithAccessKeyResponse.getResponseData())
        } catch {
            XCTFail("Fail to get short url")
        }
    }

    func testConfirmWithFingerPrintShouldBeSuccess() {
        do {
            let tokenPush = "ab1b388dc3e6c74c33e86fe55d533e3fa3d482cde65331c4865f18977afcb9fb"
            let managerLastOperationShortUrl = try bsanEcommerceManager?.getLastOperationShortUrl(documentType: "N",
                                                                                                  documentNumber: "05735578E",
                                                                                                  tokenPush: tokenPush)
            guard let shortUrl = try managerLastOperationShortUrl?.getResponseData()?.shortUrl else {
                return XCTFail("Fail load get short url")
            }
            let inputParams = EcommerceConfirmWithFingerPrintInputParams(shortUrl: shortUrl,
                                                                         token: "MTYxNzQ0NzI0MzQ0NiNlYzBlNGVmMC0xZDBlLTNkNDYtOTQ2Ni1hODAyZWNiNzgxMWUjY2FuYWxlc1NBTlBSRSNTSEExd2l0aFJTQSNrQVFaSnR0Q3Q0WVhQZHFtV3pwM2NTdnRIU3BBR0hmaFo2d1cvbjYxcjd0TCtYV3Qrck16Z21HV2hWaitucXdxZU5ucTFmNVJmWFdMV3dEY3pPbllIZjkvUndkMkd0T0lhYVRVWHdpUmZLQTFPVmExYzNjZ1NGeis4NnJMRERvUkwwYXpUcmhCZXB1c1VIZjlldUgrcTQ5U0cvcUpiTEZkdWVTZTdnQ0Mydjg9", footprint: "MTU0NDI1ZDQxYWVhMDRiMGE2MDg0NjEyYWE5NGRmNjU5M2QyMmFkZjA5NzAxYmI0OTIzNWY3YTM5OWQ0OWFmMw==",
                                                                         ip: "192.168.1.10")


            guard let managerConfirmWithFingerPrint = try? bsanEcommerceManager?.confirmWithFingerPrint(input: inputParams) else {
                return XCTFail("Fail confirmation with finger print")
            }
            XCTAssertNotNil(try managerConfirmWithFingerPrint.getResponseData())
        } catch {
            XCTFail("Fail load get last operation url")
        }
    }
}
