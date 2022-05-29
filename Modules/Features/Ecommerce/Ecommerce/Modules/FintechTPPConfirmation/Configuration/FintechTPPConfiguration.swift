import Foundation

public protocol FintechUserAuthenticationRepresentable {
    var clientId: String? { get }
    var responseType: String? { get }
    var state: String? { get }
    var scope: String? { get }
    var redirectUri: String? { get }
    var magicPhrase: String? { get }
}

final class FintechTPPConfiguration {
    let userAuthentication: FintechUserAuthenticationRepresentable
    public init(_ userAuthentication: FintechUserAuthenticationRepresentable) {
        self.userAuthentication = userAuthentication
    }
}
