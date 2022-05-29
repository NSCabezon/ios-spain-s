import CoreDomain

public struct ServicesForYouDTO: Codable {
    public let categories: [CategoryDTO]
}

extension ServicesForYouDTO: ServicesForYouRepresentable {
    public var categoriesRepresentable: [CategoryRepresentable] {
        return categories
    }
}
