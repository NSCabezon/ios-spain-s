//

import UIKit

protocol ImageTableViewModelDelegate: class {
    func finishDownloadImage()
}

class ImageTableViewModel: TableModelViewItem<ImageTableViewCell> {
    let url: String
    private weak var actionDelegate: ImageTableViewModelDelegate?
    private var once = false
    private var newHeight: CGFloat?
    override var height: CGFloat? {
        return newHeight
    }
    
    init(url: String, actionDelegate: ImageTableViewModelDelegate?, dependencies: PresentationComponent) {
        self.url = url
        self.actionDelegate = actionDelegate
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: ImageTableViewCell) {
        dependencies.imageLoader.loadWithAspectRatio(relativeUrl: self.url, imageView: viewCell.imageURLView, placeholderIfDoesntExist: nil, completion: { [weak self] newHeight in
            if self?.once == false {
                self?.newHeight = CGFloat(newHeight)
                self?.actionDelegate?.finishDownloadImage()
                self?.once = true
            }
        })
    }
}
