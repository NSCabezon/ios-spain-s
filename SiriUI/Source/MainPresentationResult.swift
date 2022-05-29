import IntentsUI

@available(iOS 12.0, *)
struct MainPresentationResult {
    let handled: Bool
    let parameters: Set<INParameter>
    let size: CGSize
}

@available(iOS 12.0, *)
extension MainPresentationResult {
    static var failed: MainPresentationResult {
        return MainPresentationResult(handled: false, parameters: Set(), size: .zero)
    }
}
