//

import Foundation

class TransferSearchableConfigurationFavsItemViewModel<Item: FilterableSortableAndTitleDescriptionRepresentable>: TableModelViewItem<TransferSearchableConfigurationFavsTableViewCell> {
    
    // MARK: - Private attributes
    
    private let firstItem: Item
    private let secondItem: Item
    private let thirdItem: Item
    private let fourthItem: Item
    private let fifthItem: Item
    private weak var delegate: TransferSearchableConfigurationFavsTableViewCellDelegate?
    private let selectedIndex: Int?
    
    // MARK: - Public attributes
    
    override var identifier: String {
        return "TransferSearchableConfigurationFavsTableViewCell"
    }
    
    // MARK: - Public methods
    
    init(dependencies: PresentationComponent, firstItem: Item, secondItem: Item, thirdItem: Item, fourthItem: Item, fifthItem: Item, delegate: TransferSearchableConfigurationFavsTableViewCellDelegate, selectedIndex: Int? = nil) {
        self.firstItem = firstItem
        self.secondItem = secondItem
        self.thirdItem = thirdItem
        self.fourthItem = fourthItem
        self.fifthItem = fifthItem
        self.delegate = delegate
        self.selectedIndex = selectedIndex
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: TransferSearchableConfigurationFavsTableViewCell) {
        viewCell.firstItem = firstItem
        viewCell.secondItem = secondItem
        viewCell.thirdItem = thirdItem
        viewCell.fourthItem = fourthItem
        viewCell.fifthItem = fifthItem
        viewCell.selectedIndex = selectedIndex
        viewCell.delegate = delegate
    }
}
