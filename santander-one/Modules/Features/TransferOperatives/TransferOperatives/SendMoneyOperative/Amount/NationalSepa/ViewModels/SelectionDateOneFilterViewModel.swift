import CoreFoundationLib

public struct SelectionDateOneFilterViewModel {
    let oneLabelViewModel: OneLabelViewModel
    let options: [String]
    var selectedIndex: Int
    
    public init(oneLabelViewModel: OneLabelViewModel, options: [String], selectedIndex: Int = 0) {
        self.oneLabelViewModel = oneLabelViewModel
        self.options = options
        self.selectedIndex = selectedIndex
    }
    
    public mutating func setSelectedIndex(_ index: Int) {
        self.selectedIndex = index
    }
}
