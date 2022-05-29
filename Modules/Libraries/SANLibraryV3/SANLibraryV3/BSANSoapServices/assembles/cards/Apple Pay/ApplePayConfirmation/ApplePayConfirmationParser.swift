import Foundation
import Fuzi

class ApplePayConfirmationParser: BSANParser<ApplePayConfirmationResponse, ApplePayConfirmationHandler> {
        
    override func setResponseData() {
        self.response.confirmation = self.handler.response
    }
}

class ApplePayConfirmationHandler: BSANHandler {
    
    fileprivate var response: ApplePayConfirmationDTO?
    
    override func parseResult(result: XMLElement) throws {
        guard
            let enrollmentData = result.firstChild(tag: "datosEnrolSalida"),
            let encryptedPassData = enrollmentData.firstChild(tag: "encryptedPassData").flatMap({ self.decodeFromHex($0.stringValue) }),
            let activationData = enrollmentData.firstChild(tag: "activationData").flatMap({ self.toData($0.stringValue) }),
            let ephemeralPublicKey = enrollmentData.firstChild(tag: "ephemeralPublicKey").flatMap({ self.decodeFromHex($0.stringValue) })
        else {
            return
        }
        self.response = ApplePayConfirmationDTO(
            encryptedPassData: encryptedPassData,
            activationData: activationData,
            ephemeralPublicKey: ephemeralPublicKey,
            wrappedKey: enrollmentData.firstChild(tag: "wrapperKey")?.stringValue.data(using: .utf8)
        )
    }
    
    private func toData(_ string: String) -> Data? {
        guard let data = Data(base64Encoded: string, options: []) else {
            return string.data(using: .utf8)
        }
        return data
    }
    
    private func decodeFromHex(_ string: String) -> Data? {
        guard let base64String = string.hexadecimal?.base64EncodedString() else { return nil }
        return Data(base64Encoded: base64String, options: [])
    }
}


extension String {

    var hexadecimal: Data? {
        var data = Data(capacity: self.count / 2)
        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) else { return nil }
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            guard let range = match?.range else { return }
            let byteString = (self as NSString).substring(with: range)
            guard let num = UInt8(byteString, radix: 16) else { return }
            data.append(num)
        }
        guard data.count > 0 else { return nil }
        return data
    }
}


