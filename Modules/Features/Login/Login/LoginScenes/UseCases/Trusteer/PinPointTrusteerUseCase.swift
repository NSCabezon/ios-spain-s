//
//  PinPointTrusteerUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/23/20.
//

import Foundation
import CoreFoundationLib
import SANLibraryV3
import CryptoSwift

class PinPointTrusteerUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let bsanManagersProvider: BSANManagersProvider
    private let trusteerRepository: TrusteerRepositoryProtocol

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.bsanManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.trusteerRepository = self.dependenciesResolver.resolve(for: TrusteerRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let enableTrusteer = self.appConfigRepository.getBool(LoginConstants.enabledTrusteer)
        if enableTrusteer == true {
            try self.executeTruster()
        }
        return UseCaseResponse.ok()
    }
}

private extension PinPointTrusteerUseCase {
    func executeTruster() throws {
        let token = try self.bsanManagersProvider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        guard let bundleID = Bundle.main.bundleIdentifier else {
            return
        }
        guard let firstBase64Token = self.decodeData(token) else {
            return
        }
        let firstBase64TokenSplitted = firstBase64Token.components(separatedBy: "#")
        guard firstBase64TokenSplitted.count > 3 else {
            return
        }
        let firstBase64TokenSplittedFourComponent = firstBase64TokenSplitted[3]
        guard let xmlToken = self.decodeData(firstBase64TokenSplittedFourComponent) else {
            return
        }
        guard let parser = UserIdParser(xmlToken) else {
            return
        }
        let appPUID = parser.result
        let identifier: String = token + bundleID
        guard let appSessionId: String = self.sha1(string: identifier) else {
            return
        }
        self.trusteerRepository.destroySession()
        self.trusteerRepository.notifyLoginFlow(appSessionId: appSessionId, appPUID: appPUID)
    }
    
    func sha1(string: String) -> String? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        let digest = data.sha1()
        return digest.toHexString()
    }
    
    func decodeData(_ data: String) -> String? {
        guard let decodeData = Data(base64Encoded: data) else {
            return nil
        }
        guard let decodedString = String(data: decodeData, encoding: .utf8) else {
            return nil
        }
        return decodedString
    }
}

class UserIdParser: NSObject {
    // "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><tokenDefinition><userID>00AADATS</userID><codigoPersona>13655152</codigoPersona><name>MARIOROMERO CATALINA</name><tipoPersona>F</tipoPersona></tokenDefinition>"
    private let parser: XMLParser
    private let userIDNode: String = "userID"
    private var isUserIdNode: Bool = false
    private var content: String = ""
    var result: String {
        return self.content
    }

    init?(_ string: String) {
        guard let data = string.data(using: String.Encoding.utf8) else {
            return nil
        }
        self.parser = XMLParser(data: data)
        super.init()
        self.parser.delegate = self
        self.parser.parse()
    }
}

extension UserIdParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.isUserIdNode {
            self.content += string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.isUserIdNode = false
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        self.isUserIdNode = self.userIDNode == elementName
    }
}
