import UI

class TipModelView: TableModelViewItem<TipTableViewCell> {
    private let tip: PullOffersConfigTip
    
    init(tip: PullOffersConfigTip, dependencies: PresentationComponent) {
        self.tip = tip
        super.init(dependencies: dependencies)
    }
    override func bind(viewCell: TipTableViewCell) {
        if let image = tip.icon {
            dependencies.imageLoader.loadWithAspectRatio(relativeUrl: image, imageView: viewCell.iconImage, placeholderIfDoesntExist: "icnSanRedMenu", completion: nil)
        } else {
            viewCell.set(image: Assets.image(named: "icnSanRedMenu") ?? UIImage())
        }
        viewCell.set(title: tip.title)
        viewCell.set(description: tip.desc)
    }
}
