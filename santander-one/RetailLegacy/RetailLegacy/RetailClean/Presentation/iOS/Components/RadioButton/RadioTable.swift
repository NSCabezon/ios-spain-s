import UIKit

enum RadioTableAuxiliaryAction {
    case toolTip(title: LocalizedStylableText, description: String?, localizedDesription: LocalizedStylableText?, identifier: String? = nil, delegate: ToolTipDisplayer?)
    case none
}

protocol RadioTableDelegate: RadioTableActionDelegate {
    var tableComponent: UITableView { get }
}

protocol RadioTableActionDelegate: class {
    func auxiliaryButtonAction(tag: Int, completion: (_ action: RadioTableAuxiliaryAction) -> Void)
}

protocol ContentResetable: class {
    func resetContent()
}

struct RadioTableInfo {
    let title: LocalizedStylableText
    let view: (UIView & ContentResetable)?
    let insets: UIEdgeInsets?
    let height: CGFloat?
    let auxiliaryImage: UIImage?
    let auxiliaryTag: Int
    let isInitialIndex: Bool
}

enum RadioTableError: Error {
    case notRegisterIndexPath
}

typealias RadioTableCells = (indexPath: IndexPath, identifier: String)

class RadioTable {
    
    private let cellId = "RadioTableViewCell"
    private weak var delegate: RadioTableDelegate?
    private lazy var radioComponentHelper: RadioComponentHelper = RadioComponentHelper(delegate: self)
    private var indexComponents: [IndexPath]
    private var indexComponentsToReset: [IndexPath]
    
    init(delegate: RadioTableDelegate) {
        self.indexComponents = []
        self.indexComponentsToReset = []
        self.delegate = delegate
        delegate.tableComponent.register(UINib(nibName: "RadioTableViewCell", bundle: .module), forCellReuseIdentifier: cellId)
    }
   
    func configure(cell: RadioTableViewCell, indexPath: IndexPath, info: RadioTableInfo) {
        if radioComponentHelper.indexSelected() == nil && info.isInitialIndex {
            let index = indexForIndexPath(indexPath: indexPath)
            radioComponentHelper.setSelectedIndex(index: index)
        }
        cell.actionDelegate = delegate
        let index = indexForIndexPath(indexPath: indexPath)
        cell.configureInsideView(necesaryHeight: info.height ?? 0, insets: info.insets ?? .zero)
        cell.setTitle(text: info.title)
        radioComponentHelper.configureRadioComponentForIndex(component: cell, index: index)
        if let indexToReset = indexComponentsToReset.firstIndex(of: indexPath) {
            indexComponentsToReset.remove(at: indexToReset)
            info.view?.resetContent()
        }
        if radioComponentHelper.indexSelected() == index {
            info.view?.isHidden = false
        } else {
            info.view?.isHidden = true
        }
        cell.addInsideView(view: info.view)
        cell.addActionButton(image: info.auxiliaryImage, tag: info.auxiliaryTag)
    }
    
    func didSelectCellComponent(indexPath: IndexPath) {
        if let index = indexComponents.firstIndex(of: indexPath) {
            radioComponentHelper.didSelectButtonForIndex(index: index)
        }
    }
    
    func indexSelected() -> IndexPath? {
        if let index = radioComponentHelper.indexSelected(), index < indexComponents.count {
            return indexComponents[index]
        } else {
            return nil
        }
    }
    
    private func indexForIndexPath(indexPath: IndexPath) -> Int {
        if let index = indexComponents.firstIndex(of: indexPath) {
            return index
        } else {
            indexComponents.append(indexPath)
            return indexComponents.count - 1
        }
    }
}

// MARK: - RadioComponentDelegate

extension RadioTable: RadioComponentDelegate {
    func reloadRadioButtons(indexes: [Int]) {
        var indexPathsToReaload: [IndexPath] = []
        for index in indexes where index < indexComponents.count {
            let indexPath = indexComponents[index]
            indexPathsToReaload.append(indexPath)
        }
        indexComponentsToReset.append(contentsOf: indexPathsToReaload)
        delegate?.tableComponent.beginUpdates()
        delegate?.tableComponent.reloadRows(at: indexPathsToReaload, with: .automatic)
        delegate?.tableComponent.endUpdates()
        if let index = indexSelected(), indexPathsToReaload.contains(index), let cell = delegate?.tableComponent.cellForRow(at: index) as? RadioTableViewCell {
            cell.showResponder()
        }
    }
}
