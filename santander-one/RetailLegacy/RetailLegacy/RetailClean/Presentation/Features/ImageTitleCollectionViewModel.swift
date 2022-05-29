import Foundation

struct ImageTitleCollectionViewModel {
    let title: String?
    let redirectionURL: String?
    let imageRelativeURL: String?
    let imageLoader: ImageLoader
    let imagePlaceholder: String?
    let offers: [Offer]?
}
