import Foundation

class DraggableImageAndDescriptionViewModel: DraggableBasicViewModel {
    
    private let titleLocalized: LocalizedStylableText
    private let imageKey: String?
    
    init(itemIdentifier: String, title: LocalizedStylableText, switchState: Bool, imageKey: String?, isDraggable: Bool = true, isActive: Bool, dependencies: PresentationComponent, onChange: ((Bool) -> Void)?) {
        self.titleLocalized = title
        self.imageKey = imageKey
        super.init(itemIdentifier: itemIdentifier, title: nil, subtitle: nil, switchState: switchState, isDraggable: isDraggable, isActive: isActive, change: onChange, dependencies: dependencies)
    }
    
    override func bind(viewCell: DraggableBasicTableViewCell) {
        super.bind(viewCell: viewCell)
        viewCell.setTitle(titleLocalized)
        viewCell.setImageKey(imageKey)
    }
    
}
