//
//  PersonalInfoWrapper.swift
//  PersonalArea
//
//  Created by alvola on 13/08/2020.
//

public struct PersonalInfoWrapper {
    var maskInfo: Bool = true
    public var address: String?
    public var addressNodes: [String]?
    public var correspondenceAddressNodes: [String]?
    public var kindOfDocument: String?
    public var document: String?
    public var birthday: String?
    public var phone: String?
    public var smsPhone: String?
    public var email: String?
    public var maskedEmail: String {
        guard maskInfo else { return email ?? "" }
        guard let email = email else { return "" }
        let splittedEmail = email.split(separator: "@")
        guard splittedEmail.count == 2 else { return email }
        let userName = splittedEmail[0]
        switch userName.count {
        case 3...:
            guard let first = userName.first, let last = userName.last else { return "" }
            let asterisks = String(repeating: "*", count: userName.count - 2)
            return String(first) + asterisks + String(last) + "@" + splittedEmail[1]
        default:
            let asterisks = String(repeating: "*", count: userName.count)
            return asterisks + "@" + splittedEmail[1]
        }
    }
    
    public var maskedPhone: String {
        guard maskInfo else { return phone ?? "" }
        return maskToFourCharacters(phone)
    }
    
    var maskPhoneSMS: String {
        guard maskInfo else { return phone ?? "" }
        return maskToFourCharacters(phone)
    }
    
    var maskedDocument: String {
        guard maskInfo else { return document ?? "" }
        return maskToFiveCharacters(document)
    }
    
    public var maskedAddress: String {
        guard maskInfo else { return address ?? "" }
        guard
            let processedAddress = processedAddress,
            !processedAddress.0.isEmpty,
            !processedAddress.1.isEmpty
        else { return "" }
        let asterisks = String(repeating: "*", count: processedAddress.1.count)
        return processedAddress.0.trim() + asterisks
    }
    
    var correspondenceAddress: String {
        maskedAddress
    }
    
    public var fullAddress: String? {
        guard let processedAddress = processedAddress else { return nil }
        return processedAddress.0 + processedAddress.1
    }
    
    var processedAddress: (String, String)? {
        guard let addressNodes = addressNodes, !addressNodes.isEmpty else { return nil }
        
        let processAddress: (String) -> (String) = { element in
            var result = ""
            if element != "," { result += " " }
            result += element
            return result
        }
        
        let middle = addressNodes.count / 2
        var firstPart = ""
        var secondPart = ""
        addressNodes.enumerated()
            .filter { index, _ in
                index < middle
            }.forEach { _, element in
                firstPart += processAddress(element)
            }
        addressNodes.enumerated()
            .filter { index, _ in
                index >= middle
            }.forEach { _, element in
                secondPart += processAddress(element)
            }
        return (firstPart, secondPart)
    }
    
    private func maskToFourCharacters(_ string: String?) -> String {
        guard let string = string else { return "" }
        guard string.count > 4 else { return string }
        let asterisks = String(repeating: "*", count: string.count - 4)
        return asterisks + String(string.suffix(4))
    }
    
    private func maskToFiveCharacters(_ string: String?) -> String {
        guard let string = string else { return "" }
        guard string.count > 5 else { return string }
        let asterisks = String(repeating: "*", count: string.count - 5)
        return asterisks + String(string.suffix(5))
    }
}
