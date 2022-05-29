import Foundation
import CoreDomain

public struct Click2CallDTO: Codable {
    public var contactPhone: String
}

extension Click2CallDTO: ClickToCallRepresentable {}
