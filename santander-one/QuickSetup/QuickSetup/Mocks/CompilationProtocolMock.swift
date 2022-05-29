//
//  CompilationProtocolMock.swift
//  PersonalArea
//
//  Created by Juan Jose Acosta González on 10/9/21.
//

import CoreFoundationLib
import SANLegacyLibrary

final class CompilationProtocolMock: CompilationProtocol {
    var isTrustInvalidCertificateEnabled: Bool = false
    var isEnvironmentsAvailable: Bool = false
    var debugLoginSetup: LoginDebugSetup? = nil
    var keychain: CompilationKeychainProtocol {
        fatalError()
    }
    var userDefaults: CompilationUserDefaultsProtocol {
        fatalError()
    }
    var defaultDemoUser: String? = ""
    var defaultMagic: String? = ""
    var tealiumTarget: String = ""
    var twinPushSubdomain: String = ""
    var twinPushAppId: String = ""
    var twinPushApiKey: String = ""
    var isLogEnabled: Bool = false
    var appCenterIdentifier: String = ""
    var isLoadPfmEnabled: Bool = false
    var isWebViewTrustInvalidCertificate: Bool = false
    var managerWallProductionEnvironment: Bool = false
    var appGroupsIdentifier: String = ""
    var bsanHostProvider: BSANHostProviderProtocol {
        fatalError()
    }
    var publicFilesHostProvider: PublicFilesHostProviderProtocol {
        fatalError()
    }
    var service: String = ""
    var sharedTokenAccessGroup: String = ""
}
