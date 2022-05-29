public protocol MyServicesForYouOptionRepresentable: PrivateMenuOptionRepresentable {
    var iconURL: String? { get }
    var titleKey: String { get }
    var icon: String? { get }
    var category: CategoryRepresentable? { get }
}
