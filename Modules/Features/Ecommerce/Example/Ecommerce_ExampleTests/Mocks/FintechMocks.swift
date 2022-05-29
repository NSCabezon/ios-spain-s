import Foundation
import QuickSetup
import CoreFoundationLib
import SANLibraryV3
import ESCommons
import LocalAuthentication
import SANLegacyLibrary
@testable import Ecommerce

struct FintechUserAuthenticationMock: FintechUserAuthenticationRepresentable {
    var magicPhrase: String?
    var clientId: String?
    var responseType: String?
    var state: String?
    var scope: String?
    var redirectUri: String?
    var token: String?

    init() {
        self.clientId = "PSDES-FINA-1111111"
        self.responseType = "code"
        self.state = "init"
        self.scope = "AISPISSVAFCS"
        self.redirectUri = "https://lanzaderapsd2-san-estruc-api-pre.appls.boaw.paas.gsnetcloud.corp/callbackRedsys.html"
        self.token = "eyJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJHT0lUIiwib3BlcmF0aW9uIjp7ImpvdXJuZXlUeXBlIjoiQ09OU0VOVCIsImFsbG93ZWRSZWFsbXMiOiIwIiwiY2xpZW50X2lkIjoiUFNERVMtRklOQS0xMTExMTExIiwib3JnSWQiOiI1MDAiLCJ0cmFuc2FjdGlvblN0YXR1cyI6IklOSVRJQVRFRCIsInJlcXVlc3RJRCI6ImFkMTJiOTk1YjI0NGZkZjMiLCJhdXRvbWF0ZWRMb2dpbiI6ZmFsc2V9fQ.fcg9ufUI-d9USE7raZy6KBQyLs08wVVPY7m_d0bJOOXxKpbmAsQFHIyxUYLEFCxOrYxxJsqGNem_tp8LQ3v9Rw"
    }
}

struct FintechUserInfoFootprintMock: FintechUserInfoFootprintRepresentable {
    var deviceMagicPhrase: String?
    var authenticationType: String
    var documentType: String?
    var documentNumber: String?
    var deviceToken: String?
    var footprint: String?
    var ipAddress: String?

    init() {
        self.authenticationType = "C"
        self.documentType = "N"
        self.documentNumber = "47736534B"
        self.deviceToken = "MTYxNzYyMDM5ODQ1MSNlYzBlNGVmMC0xZDBlLTNkNDYtOTQ2Ni1hODAyZWNiNzgxMWUjY2FuYWxlc1NBTlBSRSNTSEExd2l0aFJTQSNQc2p4TGVsdWkwUjZBN2x1ajN2dWd2My9DeGlUMW1CTnZzMTZ0ZFcyVzlvekE0N1pMbWdlMHI1Njhsd09WN1RQTU9IYjR0N0E4elNERVY1Q0EzMW5IMS9YMjBycW9KOHQyS3AvbkRaUVB1cCtTWkh1TnhCcUxmRC9TUUxLQ0kwdDdFOVpLN0Faa2tvUUs4dHlYU090ejEyazRTOGhQV21JZ3dtYVdUdDFhbGc9"
        self.footprint = "MTU0NDI1ZDQxYWVhMDRiMGE2MDg0NjEyYWE5NGRmNjU5M2QyMmFkZjA5NzAxYmI0OTIzNWY3YTM5OWQ0OWFmMw"
        self.ipAddress = "11.111.11.1"
    }
}

struct FintechUserInfoAccessKeyMock: FintechUserInfoAccessKeyRepresentable {
    var magic: String?
    var authenticationType: String
    var documentType: String?
    var documentNumber: String?
    var password: String?
    var ipAddress: String?

    init() {
        self.authenticationType = "C"
        self.documentType = "N"
        self.documentNumber = "47736534B"
        self.password = "14725836"
        self.ipAddress = "11.111.11.1"
    }
}

final class LocalAuthenticationPermissionsManagerMock: LocalAuthenticationPermissionsManagerProtocol {
    var isTouchIdEnabled: Bool = true
    
    var deviceToken: String?
    
    var footprint: String?
    
    private var biometryEvaluationResult: BiometryEvaluationResultEntity = .success
    
    func enableBiometric() {
        
    }
    
    func enableBiometric(byKey key: String) -> BiometryEvaluationResultEntity {
        return .success
    }
    
    func evaluateBiometry(reason: String, completion: @escaping (BiometryEvaluationResultEntity) -> Void) {
        completion(biometryEvaluationResult)
    }
    
    func setSuccessResponse() {
        biometryEvaluationResult = .success
    }
    
    func setFailureResponse() {
        biometryEvaluationResult = .evaluationError(error: .appCancel)
    }
    
}

final class FintechTPPConfirmationViewMock: FintechTPPConfirmationViewProtocol {
    var presenter: FintechTPPConfirmationPresenterProtocol
    var state: FintechTPPConfirmationState?
    func setViewState(_ state: FintechTPPConfirmationState) {
        self.state = state
    }
    
    init(presenter: FintechTPPConfirmationPresenterProtocol) {
        self.presenter = presenter
    }
}

final class GetRememberedUserNameUseCaseMock: GetRememberedUserNameUseCase {
    
    private var output = GetRememberedUserNameUseCaseOkOutput(userName: nil, loginType: nil, login: nil)
        
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetRememberedUserNameUseCaseOkOutput, StringErrorOutput> {
        return .ok(output)
    }
    
    func updateAlias(_ alias: String) {
        output = GetRememberedUserNameUseCaseOkOutput(userName: alias, loginType: nil, login: nil)
    }
}

final class GetRecoverPasswordUrlUseCaseMock: GetRecoverPasswordUrlUseCase {
    private var output = GetRecoverPasswordUrlUseCaseOkOutput(recoverPasswordUrl: "")
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetRecoverPasswordUrlUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(output)
    }
}

final class FintechUserAuthenticationRepresentableMock: FintechUserAuthenticationRepresentable {
    var magicPhrase: String?
    var clientId: String?
    var responseType: String?
    var state: String?
    var scope: String?
    var redirectUri: String?
    var token: String?
}

final class FintechConfirmAccessKeyUseCaseMock: FintechConfirmAccessKeyUseCase {
    private var output = FintechConfirmAccessKeyUseCaseOkOutput(urlLocation: "")
    override func executeUseCase(requestValues: FintechConfirmAccessKeyUseCaseInput) throws -> UseCaseResponse<FintechConfirmAccessKeyUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(output)
    }
}

final class FintechConfirmFootprintUseCaseMock: FintechConfirmFootprintUseCase {
    private var output = FintechConfirmaFootprintUseCaseOkOutput(urlLocation: "")
    override func executeUseCase(requestValues: FintechConfirmaFootprintUseCaseInput) throws -> UseCaseResponse<FintechConfirmaFootprintUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(output)
    }
}

final class GetTouchIdLoginDataUseCaseMock: GetTouchIdLoginDataUseCase {

    private var touchIdData = TouchIdData(deviceMagicPhrase: "",
                                          touchIDLoginEnabled: true,
                                          footprint: "")

    var output: GetTouchIdLoginDataOkOutput?
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetTouchIdLoginDataOkOutput, StringErrorOutput> {
        if let output = output {
            return UseCaseResponse.ok(output)
        }
        return UseCaseResponse.error(StringErrorOutput("Error in Mocked UseCase"))
    }
    
    func setOkResponse() {
        output = GetTouchIdLoginDataOkOutput(touchIdData: touchIdData)
    }
}

final class GetLanguagesSelectionUseCaseMock: GetLanguagesSelectionUseCase {
    private var output = GetLanguagesSelectionUseCaseOkOutput(current: Language.createFromType(languageType: .spanish,
                                                                                               isPb: false))
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(output)
    }
}

final class FintechTPPConfirmationCoordinatorMock: FintechTPPConfirmationCoordinatorProtocol {
    
    var url: String?
    var askedToDismiss = false
    func dismiss() {
        askedToDismiss = true
    }
    
    func openUrl(_ url: String) {
        self.url = url
    }
}

final class UseCaseHandlerMock: UseCaseHandler {
    
}

final class CompilationAccountMock: CompilationAccountProtocol {
    var touchId: String {""}
    var biometryEvaluationSecurity: String {""}
    var widget: String {""}
    var tokenPush: String {""}
    var old: String?
}

final class CompilationKeychainMock: CompilationKeychainProtocol {
    var account: CompilationAccountProtocol = CompilationAccountMock()
    var service: String {""}
    var sharedTokenAccessGroup: String {""}
}

final class CompilationKeyProtocolMock: CompilationKeyProtocol {
    var oldDeviceId: String?
    var firstOpen: String {""}
}

final class CompilationUserDefaultsMock: CompilationUserDefaultsProtocol {
    var key: CompilationKeyProtocol = CompilationKeyProtocolMock()
}

final class PublicFilesHostProviderMock: PublicFilesHostProviderProtocol {
    var publicFilesEnvironments: [PublicFilesEnvironmentDTO] = []
    
}

final class BSANHostProviderMock: BSANHostProviderProtocol {
    func getEnvironments() -> [BSANEnvironmentDTO] {
        []
    }
    
    var environmentDefault: BSANEnvironmentDTO = BSANEnvironments.enviromentPreWas9
}

final class CompilationProtocolMock: CompilationProtocol {
    var quickbalance: String {""}
    var service: String {""}
    var sharedTokenAccessGroup: String {""}
    var isEnvironmentsAvailable: Bool {false}
    var debugLoginSetup: LoginDebugSetup?
    var keychain: CompilationKeychainProtocol
    var userDefaults: CompilationUserDefaultsProtocol
    var defaultDemoUser: String?
    var defaultMagic: String?
    var tealiumTarget: String {""}
    var twinPushSubdomain: String {""}
    var twinPushAppId: String {""}
    var twinPushApiKey: String {""}
    var salesForceAppId: String {""}
    var salesForceAccessToken: String {""}
    var salesForceMid: String {""}
    var emmaApiKey: String {""}
    var isLogEnabled: Bool {false}
    var appCenterIdentifier: String {""}
    var isLoadPfmEnabled: Bool {false}
    var isTrustInvalidCertificateEnabled: Bool {false}
    var managerWallProductionEnvironment: Bool {false}
    var appGroupsIdentifier: String {""}
    var bsanHostProvider: BSANHostProviderProtocol
    var publicFilesHostProvider: PublicFilesHostProviderProtocol
    
    init() {
        self.keychain = CompilationKeychainMock()
        self.userDefaults = CompilationUserDefaultsMock()
        self.bsanHostProvider = BSANHostProviderMock()
        self.publicFilesHostProvider = PublicFilesHostProviderMock()
        
    }
}
