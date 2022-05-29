import UIKit
import CoreFoundationLib

typealias LocationBannerDelegate = BannerDelegate & CloseBannerDelegate
typealias LocationBannerViewModelDelegate = BannerDelegate & CloseBannerViewModelDelegate

protocol BannerDelegate: AnyObject {
    func finishDownloadImage(newHeight: Float?)
    func selectedBanner()
}

extension CloseBannerDelegate {
    func closeBanner(bannerOffer: Offer?) {}
}

extension BannerDelegate {
    func selectedBanner() {}
}

protocol CloseBannerDelegate: AnyObject {
    func closeBanner(bannerOffer: Offer?)
}

protocol CloseBannerViewModelDelegate: AnyObject {
    func closeBanner<T>(bannerOffer: Offer?, item: TableModelViewItem<T>)
}

class LocationBannerViewModel: TableModelViewItem<LocationBannerTableViewCell> {
    let url: String
    var insertedHeight: CGFloat?
    var bannerOffer: Offer?
    var insets: UIEdgeInsets?
    var taskCancelable: CancelableTask?
    var isClosable: Bool
    private weak var actionDelegate: LocationBannerViewModelDelegate?

    init(url: String, bannerOffer: Offer? = nil, leftInset: CGFloat? = nil, rightInset: CGFloat? = nil, topInset: CGFloat? = nil, bottomInset: CGFloat? = nil, isClosable: Bool, actionDelegate: LocationBannerViewModelDelegate?, dependencies: PresentationComponent) {
        self.url = url
        self.actionDelegate = actionDelegate
        self.bannerOffer = bannerOffer
        self.insets = UIEdgeInsets(top: topInset ?? 0, left: leftInset ?? 0, bottom: bottomInset ?? 0, right: rightInset ?? 0)
        self.isClosable = isClosable
        super.init(dependencies: dependencies)
    }
    
    override var height: CGFloat? {
        return self.insertedHeight
    }
    
    override func bind(viewCell: LocationBannerTableViewCell) {
        viewCell.insets = insets
        viewCell.modelView = self
        viewCell.isClosable = isClosable
        taskCancelable = dependencies.imageLoader.loadTask(absoluteUrl: url, imageView: viewCell.imageURLView, placeholderIfDoesntExist: nil, completion: { [weak self] in
            viewCell.onImageLoadFinished()
            self?.taskCancelable = nil
        })
    }
    
    public func onDrawFinished(newHeight: CGFloat) {
        insertedHeight = newHeight
        actionDelegate?.finishDownloadImage(newHeight: Float(newHeight))
    }
    
    func didCloseButton() {
        actionDelegate?.closeBanner(bannerOffer: self.bannerOffer, item: self)
    }
    
    func willReuseView(viewCell: LocationBannerTableViewCell) {
        taskCancelable?.cancel()
    }
}
