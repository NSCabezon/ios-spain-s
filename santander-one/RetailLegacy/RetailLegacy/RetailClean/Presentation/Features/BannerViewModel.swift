import CoreFoundationLib

protocol BannerViewModelDelegate: AnyObject {
    func finishDownloadImage()
}

class BannerViewModel: TableModelViewItem<BannerTableViewCell>, BannerShadowProtocol {
    let url: String
    var bannerOffer: Offer?
    weak var actionDelegate: BannerViewModelDelegate?
    var taskCancelable: CancelableTask?
    final var once = false
    final var newHeight: CGFloat?
    override var height: CGFloat? {
        return newHeight
    }
    var hasShadows: Bool
    
    // MARK: - Events
    var didSelect: (() -> Void)?
    
    init(url: String, bannerOffer: Offer? = nil, actionDelegate: BannerViewModelDelegate?, dependencies: PresentationComponent) {
        self.url = url
        self.actionDelegate = actionDelegate
        self.bannerOffer = bannerOffer
        self.hasShadows = true
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: BannerTableViewCell) {
        taskCancelable = dependencies.imageLoader.loadWithAspectRatio(absoluteUrl: url, imageView: viewCell.imageURLView, placeholderIfDoesntExist: nil, completion: { [weak self] newHeight in
            if self?.once == false {
                self?.newHeight = CGFloat(newHeight+20)
                viewCell.finishDownload()
                viewCell.modelView = self
                self?.actionDelegate?.finishDownloadImage()
                self?.taskCancelable = nil
                self?.once = true
            }
        })
    }
    
    func willReuseView(viewCell: BannerTableViewCell) {
        taskCancelable?.cancel()
    }
}

extension BannerViewModel: Executable {
    func execute() {
        didSelect?()
    }
}
