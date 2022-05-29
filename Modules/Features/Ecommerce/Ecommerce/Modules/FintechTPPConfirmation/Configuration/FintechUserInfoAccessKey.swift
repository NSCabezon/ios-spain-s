import Foundation

public protocol FintechUserInfoAccessKeyRepresentable {
    var authenticationType: String { get }
    var documentType: String? { get }
    var documentNumber: String? { get }
    var magic: String? { get }
    var ipAddress: String? { get }
}

struct FintechUserInfoAccessKey: FintechUserInfoAccessKeyRepresentable {
    var authenticationType = "C"
    var documentType: String?
    var documentNumber: String?
    var magic: String?
    var ipAddress: String?
}
