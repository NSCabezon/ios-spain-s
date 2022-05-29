import UIKit

protocol CreativityCarouselCollectionViewModelDelegate: class {
    func finishDownloadImage(newHeight: Float?)
}

class CreativityCarouselCollectionViewModel: CollectionViewModel {
    typealias CollectionCell = CreativityCarouselCollectionViewCell
    
    let url: String
    var insertedHeight: CGFloat?
    var insets: UIEdgeInsets?
    var width: Float?
    let dependencies: PresentationComponent
    
    init(url: String, leftInset: CGFloat? = nil, rightInset: CGFloat? = nil, topInset: CGFloat? = nil, bottomInset: CGFloat? = nil, width: Float? = nil, dependencies: PresentationComponent) {
        self.url = url
        self.width = width
        self.insets = UIEdgeInsets(top: topInset ?? 0, left: leftInset ?? 0, bottom: bottomInset ?? 0, right: rightInset ?? 0)
        self.dependencies = dependencies
    }
    
    func bind(viewCell: CreativityCarouselCollectionViewCell) {
        viewCell.backgroundColor = .clear
        viewCell.imageView.backgroundColor = .clear
        viewCell.modelView = self
        dependencies.imageLoader.loadTask(absoluteUrl: url, imageView: viewCell.imageView, placeholderIfDoesntExist: nil, completion: { [weak viewCell] in
            viewCell?.onImageLoadFinished()
        })
    }
    
    func onDrawFinished(newHeight: CGFloat) {
        if newHeight != insertedHeight {
            insertedHeight = newHeight
        }
    }
}
