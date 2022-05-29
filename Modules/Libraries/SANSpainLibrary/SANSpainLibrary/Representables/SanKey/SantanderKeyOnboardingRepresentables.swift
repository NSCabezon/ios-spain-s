import Foundation

public protocol SantanderKeyStatusRepresentable: Codable {
    var clientStatus: String? { get }
    var otherSKinDevice: String? { get }
    var shouldCallDetail: Bool { get }
}

public extension SantanderKeyStatusRepresentable {
    var shouldCallDetail: Bool {
        let notRegisteredOtherRegistered = clientStatus == "5" && otherSKinDevice?.lowercased() == "true"
        let notRegistered = clientStatus == "5" && otherSKinDevice == nil
        return !(clientStatus == "2" || notRegistered) && !notRegisteredOtherRegistered
    }
}

public protocol SantanderKeyAutomaticRegisterResultRepresentable: Codable {
    var sankeyId: String? { get }
}

public protocol SantanderKeyRegisterAuthMethodResultRepresentable: Codable {
    var authMethod: String? { get }
    var sanKeyId: String? { get }
    var cardsList: [SantanderKeyCardRepresentable]? { get }
    var signPositions: String? { get }
}

public protocol SantanderKeyCardRepresentable: Codable {
    var pan: String? { get }
    var cardType: String? { get }
    var description: String? { get }
    var img: SantanderKeyCardImageRepresentable? { get }
}

public protocol SantanderKeyCardImageRepresentable: Codable {
    var id: String? { get }
    var url: String? { get }
}

public protocol SantanderKeyRegisterValidationResultRepresentable: Codable {
    var otpReference: String? { get }
    var mobileNumber: String? { get }
}

public protocol SantanderKeyRegisterConfirmationResultRepresentable: Codable {
    var deviceId: String? { get }
}

public protocol SantanderKeyDetailResultRepresentable: Codable {
    var sanKeyApp: String? { get }
    var deviceAlias: String? { get }
    var deviceModel: String? { get }
    var creationDate: String? { get }
    var deviceCode: String? { get }
    var deviceManu: String? { get }
    var soVersion: String? { get }
    var devicePlatform: String? { get }
}
