import CoreDomain
import OpenCombine

struct MockUserPreferencesRepository: UserPreferencesRepository {
    public static let current = MockUserPreferencesRepository()
    private let subject = CurrentValueSubject<UserPreferencesRepresentable, Error>(MockUserPreferencesRepresentable(isPrivateMenuCoachManagerShown: false))
    
    public init() {}
    func getUserPreferences(userId: String) -> AnyPublisher<UserPreferencesRepresentable, Error> {
        return subject.eraseToAnyPublisher()
    }
    
    func updateUserPreferences(update: UpdateUserPreferencesRepresentable) { }
}
