import Foundation

public protocol CarbonFootprintTokenRepresentable: Codable {
    var idToken: String? { get }
}
