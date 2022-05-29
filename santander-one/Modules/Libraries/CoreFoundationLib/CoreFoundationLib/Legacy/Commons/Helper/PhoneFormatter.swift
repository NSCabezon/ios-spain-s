import Foundation

public enum PhoneTextFiledResult {
    case empty
    case incorrect
    case ok
}

public class PhoneFormatter {
    private let numberCharacterSet = CharacterSet(charactersIn: "1234567890")
    
    public init() {}
    
    public func checkNationalPhone(phone: String) -> PhoneTextFiledResult {
        guard !phone.isEmpty else {
            return .empty
        }
        if isNationalPhone(text: phone) {
            return .ok
        } else {
            return .incorrect
        }
    }
    
    public func getNationalPhoneClean(phone: String) -> String? {
        return self.checkNationalPhone(phone: phone) == .ok ? phone.filterValidCharacters(characterSet: numberCharacterSet).tlfWithoutPrefix() : nil
    }
    
    public func getNationalPhoneCodeTrimmed(phone: String) -> String? {
        guard let number = getNationalPhoneClean(phone: phone) else { return nil }
        return "+34\(number)"
    }
    
    private func isNationalPhone(text: String) -> Bool {
        var phone = text.filterValidCharacters(characterSet: numberCharacterSet)
        while phone.first == "0" {
            phone = String(phone.dropFirst())
        }
        if phone.count == 11 {
            let range = NSRange(location: 0, length: 3)
            let prefix = phone.substring(with: range)
            return prefix == "346" || prefix == "347"
        } else if phone.count == 9 {
            let character = phone.first
            return character == "6" || character == "7"
        }
        return false
    }
}
