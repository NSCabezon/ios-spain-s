import OpenCombine
import CoreFoundationLib
import CoreDomain

public protocol DisplayManagerPrivateMenuUseCase {
    func fetchManagerCoachmarkInfo() -> AnyPublisher<ManagerCoachmarkInfoRepresentable, Never>
    func updateManagerShown(_ isPrivateMenuCoachManagerShown: Bool) -> AnyPublisher<Void, Never>
}

struct DefaultDisplayManagerPrivateMenuUseCase {
}

extension DefaultDisplayManagerPrivateMenuUseCase: DisplayManagerPrivateMenuUseCase {
    func fetchManagerCoachmarkInfo() -> AnyPublisher<ManagerCoachmarkInfoRepresentable, Never> {
        return Just(ManagerCoachmarkInfo()).eraseToAnyPublisher()
    }
    
    func updateManagerShown(_ isPrivateMenuCoachManagerShown: Bool) -> AnyPublisher<Void, Never> {
        return Empty<Void, Never>().eraseToAnyPublisher()
    }
}

private extension DefaultDisplayManagerPrivateMenuUseCase {
    struct ManagerCoachmarkInfo: ManagerCoachmarkInfoRepresentable {
        let showsManagerCoach: Bool = false
        let title: LocalizedStylableText? = nil
        let subtitle: LocalizedStylableText? = nil
        let offerRepresentable: OfferRepresentable? = nil
        let thumbnailData: Data? = nil
    }
}
