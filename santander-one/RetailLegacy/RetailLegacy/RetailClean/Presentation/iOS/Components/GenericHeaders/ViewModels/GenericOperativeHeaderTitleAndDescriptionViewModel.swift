import Foundation

final class GenericOperativeHeaderTitleAndDescriptionViewModel: HeaderViewModel<GenericOperativeHeaderTitleAndDescriptionView> {
    let title: LocalizedStylableText?
    let description: LocalizedStylableText?
    let accesibilityIds: GenericOperativeHeaderTitleAndDescriptionAccesibilityIds?
    
    init(title: LocalizedStylableText?, description: LocalizedStylableText?, accesibilityIds: GenericOperativeHeaderTitleAndDescriptionAccesibilityIds? = nil) {
        self.title = title
        self.description = description
        self.accesibilityIds = accesibilityIds
    }
    
    override func configureView(_ view: GenericOperativeHeaderTitleAndDescriptionView) {
        view.setTitle(title?.uppercased() ?? LocalizedStylableText.empty)
        view.setDescription(description ?? LocalizedStylableText.empty)
        view.setAccesibilityIds(accesibilityIds)
    }
}

struct GenericOperativeHeaderTitleAndDescriptionAccesibilityIds {
    public let title: String?
    public let description: String?
}
