import Foundation

public struct BizumContactEntity {
    public let identifier: String
    public let name: String?
    public let phone: String
    public var alias: String?
    public var validateSendAction: String?
    public var thumbnailData: Data?
    
    public init(identifier: String,
                name: String?,
                phone: String,
                alias: String? = nil,
                validateSendAction: String? = nil,
                thumbnailData: Data? = nil) {
        self.identifier = identifier
        self.name = name
        self.phone = phone
        self.alias = alias
        self.validateSendAction = validateSendAction
        self.thumbnailData = thumbnailData
    }

    public mutating func addAliasIsBizum(alias: String?, validateSendAction: String?) {
        self.alias = alias
        self.validateSendAction = validateSendAction
    }

    public var sendActionValue: String {
        guard let validateSendAction = self.validateSendAction?.uppercased() else { return "" }
        if validateSendAction == "INVITAR" {
            return "summary_label_invited"
        }
        if validateSendAction == "ENVIAR" {
            return "summary_label_sent"
        }
        if validateSendAction == "SOLICITAR" {
            return "summary_label_pendingBizum"
        }
        return validateSendAction
    }
    
    public var nameToShow: String {
        if alias == name {
            return self.alias ?? ""
        } else {
            return [self.alias, self.name]
                .map { String($0 ?? "") }
                .filter { !$0.isEmpty }
                .joined(separator: " | ")
        }
    }
    
    public var nameOrPhoneToShow: String {
        let nameToShow = self.nameToShow
        if nameToShow.isEmpty {
            return phone.tlfFormatted()
        } else {
            return nameToShow
        }
    }
}
