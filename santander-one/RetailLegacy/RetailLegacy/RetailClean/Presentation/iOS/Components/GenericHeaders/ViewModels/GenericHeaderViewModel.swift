import UIKit

class GenericHeaderViewModel<T: BaseHeader>: TableModelViewItem<GenericHeaderViewCell> {
    let viewModel: HeaderViewModel<T>
    let viewType: ViewCreatable.Type
    let isDraggable: Bool
    
    init(viewModel: HeaderViewModel<T>, viewType: ViewCreatable.Type, isDraggable: Bool = false, dependencies: PresentationComponent) {
        self.viewModel = viewModel
        self.viewType = viewType
        self.isDraggable = isDraggable
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: GenericHeaderViewCell) {
        if let genericView = viewType.instantiateFromNib() as? T {
            genericView.embedInto(container: viewCell.cellView)
            viewModel.configureView(genericView)
        }
        viewCell.isDraggable = isDraggable
    }
}
