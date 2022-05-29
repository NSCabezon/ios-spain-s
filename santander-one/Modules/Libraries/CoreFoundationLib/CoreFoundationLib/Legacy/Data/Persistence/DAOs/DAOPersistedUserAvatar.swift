import Foundation

public protocol DAOPersistedUserAvatar {
    func set(userId: String, image: Data) -> Bool
    func get(userId: String) -> Data?
}
