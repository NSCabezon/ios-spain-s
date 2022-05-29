import Foundation
import CryptoSwift

public extension String {
    func decrypt(keyString: String) -> String? {
        var clairMessage: String?
        if let cryptedData = Data(base64Encoded: self) {
            do {
                let key: [UInt8] = Array(keyString.utf8) as [UInt8]
                let iv = [UInt8](repeating: 0x00, count: 16)
                let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
                let cipher = try aes.decrypt([UInt8](cryptedData))
                clairMessage = String(data: Data(cipher), encoding: .utf8) ?? ""
            } catch {
                let error = error as NSError
                print(error)
            }
        }
        return clairMessage
    }
}
