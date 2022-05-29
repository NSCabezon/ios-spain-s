import CoreFoundationLib
import CoreDomain

protocol TutorialImageTableViewModelDelegate: AnyObject {
    func finishDownloadImage()
}

class TutorialImageTableViewModel: TableModelViewItem<TutorialImageTableViewCell> {
    let url: String
    var bannerAction: OfferActionRepresentable?
    private weak var actionDelegate: TutorialImageTableViewModelDelegate?
    var taskCancelable: CancelableTask?
    private var once = false
    private var newHeight: CGFloat?
    override var height: CGFloat? {
        return newHeight
    }
    
    init(url: String, bannerAction: OfferActionRepresentable? = nil, actionDelegate: TutorialImageTableViewModelDelegate?, dependencies: PresentationComponent) {
        self.url = url
        self.actionDelegate = actionDelegate
        self.bannerAction = bannerAction
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: TutorialImageTableViewCell) {
        taskCancelable = dependencies.imageLoader.loadWithAspectRatio(absoluteUrl: url, imageView: viewCell.imageURLView, placeholderIfDoesntExist: nil, completion: { [weak self] newHeight in
            if self?.once == false {
                self?.newHeight = CGFloat(newHeight)
                viewCell.finishDownload()
                self?.actionDelegate?.finishDownloadImage()
                self?.taskCancelable = nil
                self?.once = true
            }
        })
    }
    
    func willReuseView(viewCell: TutorialImageTableViewCell) {
        taskCancelable?.cancel()
    }
}
