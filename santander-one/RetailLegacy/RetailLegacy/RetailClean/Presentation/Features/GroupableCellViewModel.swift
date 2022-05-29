import Foundation

protocol GroupableCell: class {
    var isFirst: Bool { get set }
    var isLast: Bool { get set }
    var isSeparatorVisible: Bool { get set }
}

class GroupableCellViewModel<T: GroupableTableViewCell>: TableModelViewItem<T>, GroupableCell {
    var isFirst = false
    var isLast = false
    var isSeparatorVisible = false
    var didSelect: (() -> Void)? = { }

    override func bind(viewCell: T) {
        viewCell.setPlace(isFirst: isFirst, isLast: isLast)
        viewCell.isSeparatorVisible = isSeparatorVisible
    }
}

extension GroupableCellViewModel: Executable {
    func execute() {
        didSelect?()
    }
}
