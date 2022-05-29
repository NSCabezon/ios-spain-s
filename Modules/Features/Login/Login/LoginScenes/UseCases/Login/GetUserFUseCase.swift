//
//  GetUserFUseCase.swift
//  Login
//
//  Created by Andres Aguirre Juarez on 10/1/22.
//

import Foundation
import CoreFoundationLib
import LoginCommon
import SANLibraryV3

final class GetUserFUseCase: UseCase<Void, GetUserFUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let bsanManagersProvider: BSANManagersProvider
    private var userF: String?
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.bsanManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetUserFUseCaseOkOutput, StringErrorOutput> {
        try getUserF()
        return UseCaseResponse.ok(GetUserFUseCaseOkOutput(userF: userF))
    }
}

private extension GetUserFUseCase {
    func getUserF() throws {
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
        guard let parser = UserCodeParser(xmlToken) else {
            return
        }
        let appPUID = parser.result
        userF = appPUID
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

struct GetUserFUseCaseOkOutput {
    var userF: String?
}

private final class UserCodeParser: NSObject {
    private let parser: XMLParser
    private let userCodeNode: String = "codigoPersona"
    private let personTypeNode: String = "tipoPersona"
    private var isUserCodeNode: Bool = false
    private var isPersonTypeNode: Bool = false
    private var personType: String = ""
    private var content: String = ""
    var result: String {
        return self.personType + self.content
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

extension UserCodeParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.isUserCodeNode {
            self.content += string
        }
        if self.isPersonTypeNode {
            self.personType = string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.isUserCodeNode = false
        self.isPersonTypeNode = false
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        self.isUserCodeNode = self.userCodeNode == elementName
        self.isPersonTypeNode = self.personTypeNode == elementName
    }
}
