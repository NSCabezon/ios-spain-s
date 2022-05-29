import CoreFoundationLib

public protocol OneComponentStatusProtocol: AnyObject {
    var status: OneStatus? { get }
    func showError(_ error: String?)
    func hideError()
}
