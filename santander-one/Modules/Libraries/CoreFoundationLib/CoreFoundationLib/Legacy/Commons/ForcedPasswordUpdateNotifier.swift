public protocol ForcedPasswordUpdatedNoticeable: AnyObject {
    func didUpdateForcedPassword()
}

public protocol ForcedPasswordUpdatedNotifier {
    func notifyForcedPasswordUpdated()
}

public class ForcedPasswordUpdateProxy: ForcedPasswordUpdatedNotifier {
    public static let shared = ForcedPasswordUpdateProxy()
    public weak var delegate: ForcedPasswordUpdatedNoticeable?

    private init() {}

    public func notifyForcedPasswordUpdated() {
        delegate?.didUpdateForcedPassword()
    }
}
