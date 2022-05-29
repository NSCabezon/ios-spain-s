import CoreDomain

public struct ClientDTO: Codable, Hashable, CustomStringConvertible {
    public var personType: String?
    public var personCode: String?

    public static func == (lhs: ClientDTO, rhs: ClientDTO) -> Bool {
        if lhs.personType == nil || lhs.personCode == nil || rhs.personType == nil || rhs.personCode == nil {
            return false
        }
        if lhs.personType == rhs.personType && lhs.personCode == rhs.personCode {
            return true
        }
        return false
    }

    public func hash(into hasher: inout Hasher) {
        guard let personCode = self.personCode, let hash = Int(personCode) else { return hasher.combine(0) }
        return hasher.combine(hash)
    }

    public var description: String {
        var text: String = ""

        if let personType = personType {
            text += "person type=" + personType + ", "
        }
        if let personCode = personCode {
            text += "person code" + personCode + ", "
        }

        if "" == text {
            text = "nil!"
        } else if let subtext = text.substring(0, text.count - 2) {
            text = subtext
        }

        return text

    }

    public init () {}
}

extension ClientDTO: ClientRepresentable { }
