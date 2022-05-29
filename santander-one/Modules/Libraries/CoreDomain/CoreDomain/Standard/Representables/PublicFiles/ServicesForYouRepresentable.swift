public protocol ServicesForYouRepresentable {
    var categoriesRepresentable: [CategoryRepresentable] { get }
}

public protocol CategoryRepresentable {
    var name: String? { get }
    var imageRelativeURL: String? { get }
    var iconRelativeURL: String? { get }
    var itemsRepresentable: [ItemRepresentable]? { get }
}

public protocol ItemRepresentable {
    var name: String? { get }
    var link: String? { get }
}
