import Foundation

public protocol CarbonFootprintIdInputRepresentable: Codable {
    var realmId: String? { get }
}

public protocol CarbonFootprintDataInputRepresentable: Codable {
    var firstName: String? { get }
    var lastName: String? { get }
    var contract: String? { get }
}
