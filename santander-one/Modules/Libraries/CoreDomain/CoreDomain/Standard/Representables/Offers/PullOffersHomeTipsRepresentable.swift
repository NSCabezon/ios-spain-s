public protocol PullOffersHomeTipsRepresentable {
    var title: String { get }
    var contentRepresentable: [PullOffersHomeTipsContentRepresentable]? { get }
}

public protocol PullOffersHomeTipsContentRepresentable {
    var title: String? { get }
    var desc: String? { get }
    var icon: String? { get }
    var tag: String? { get }
    var offerId: String? { get }
    var keyWords: [String]? { get }
}
