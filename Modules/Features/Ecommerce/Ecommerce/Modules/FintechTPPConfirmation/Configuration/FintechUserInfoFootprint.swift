import Foundation

public protocol FintechUserInfoFootprintRepresentable {
    var authenticationType: String { get }
    var documentType: String? { get }
    var documentNumber: String? { get }
    var deviceMagicPhrase: String? { get }
    var footprint: String? { get }
    var ipAddress: String? { get }
}

struct FintechUserInfoFootprint: FintechUserInfoFootprintRepresentable {
    var authenticationType = "B"
    var documentType: String?
    var documentNumber: String?
    var deviceMagicPhrase: String?
    var footprint: String?
    var ipAddress: String?
}
