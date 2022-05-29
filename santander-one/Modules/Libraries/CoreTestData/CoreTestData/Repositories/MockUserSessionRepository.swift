import CoreDomain

public final class MockUserSessionRepository: UserSessionRepository {
    public init() {}
    
    public func cleanSession() {}
    public func saveToken(_ token: String) {}
    public func saveUserData(_ userData: UserDataRepresentable?) {}
    public func saveIsPB(_ isPB: Bool) {}
    public func isPb() -> Bool? {
        return nil
    }
}
