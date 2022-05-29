//! Use this protocol in Model if necessary. Old retail use this on Card and Transaction
public protocol PFMMovementProtocol {
    func movement<T>() -> T
}
