import UIKit

protocol DraggableBasicViewModelProtocol {
    func showImage()
    func hideImage()
    func active()
    func deactive()
}

class DraggableBasicViewModel: TableModelViewItem<DraggableBasicTableViewCell> {
    private(set) var itemIdentifier: String
    var title: String?
    var subtitle: String?
    var switchState: Bool
    var imageURL: String?
    var isDraggable: Bool
    var switchCoachmarkId: CoachmarkIdentifier?
    var isActive: Bool
    private let change: ((Bool) -> Void)?
    
    init(itemIdentifier: String, title: String?, subtitle: String?, switchState: Bool, imageURL: String? = nil, isDraggable: Bool = true, isActive: Bool = false, change: ((Bool) -> Void)?,
         dependencies: PresentationComponent) {
        self.itemIdentifier = itemIdentifier
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
        self.switchState = switchState
        self.isDraggable = isDraggable
        self.isActive = isActive
        self.change = change
        super.init(dependencies: dependencies)
    }

    override func bind(viewCell: DraggableBasicTableViewCell) {
        (imageURL == nil) ? viewCell.hideImage() : viewCell.showImage()
        isActive ? viewCell.active() : viewCell.deactive()

        viewCell.title = title
        viewCell.subtitle = subtitle
        viewCell.subtitleLabel.isHidden = subtitle == nil
        viewCell.reorderImageView.isHidden = isDraggable == false
        viewCell.isSwitchOn = switchState
        viewCell.switchValueDidChange = { [weak self] switchValue in
            self?.switchState = switchValue
            self?.change?(switchValue)
        }
        viewCell.isDraggable = isDraggable
        if let imageURL = imageURL {
            dependencies.imageLoader.load(relativeUrl: imageURL, imageView: viewCell.iconImageView, placeholder: "defaultCard")
        }
        viewCell.switchCoachmarkId = switchCoachmarkId
    }

}
