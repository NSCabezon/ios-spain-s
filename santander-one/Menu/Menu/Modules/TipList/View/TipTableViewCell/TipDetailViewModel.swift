import Foundation
import CoreFoundationLib

public protocol TipDetailViewModelProtocol: AnyObject {
    func setTitle(_ value: LocalizedStylableText)
    func setDescription(_ value: LocalizedStylableText)
    func loadImage(_ value: String)
    func showTag(_ value: LocalizedStylableText)
    func hideTag()
}

public struct TipDetailViewModel {
    let title: LocalizedStylableText
    let description: LocalizedStylableText
    let offerId: String
    let image: String?
    let baseUrl: String?
    var tag: LocalizedStylableText?

    private var imageUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil }
        guard let image = self.image else { return nil }
        return String(format: "%@%@", baseUrl, image)
    }

    func updateView(_ view: TipDetailViewModelProtocol) {
        view.setTitle(title)
        view.setDescription(description)

        if let tag = self.tag, tag.text != "" {
            view.showTag(tag)
        } else {
            view.hideTag()
        }

        if let imageUrl = self.imageUrl {
            view.loadImage(imageUrl)
        }
    }
}
