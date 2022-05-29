import Foundation

class GenericLoadingViewModel: TableModelViewItem<GenericLoadingViewCell> {
    
    let title: LocalizedStylableText?
    let subtitle: LocalizedStylableText?
    let skeletonImageKey: String?
    
    init(title: LocalizedStylableText?, subtitle: LocalizedStylableText?, skeletonImageKey: String?, dependencies: PresentationComponent) {
        self.title = title
        self.subtitle = subtitle
        self.skeletonImageKey = skeletonImageKey
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: GenericLoadingViewCell) {
        viewCell.setTitle(title)
        viewCell.setSubtitle(subtitle)
        viewCell.startAnimation()
        viewCell.setSkeletonImageKey(skeletonImageKey)
    }
    
}
