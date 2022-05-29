import UIKit
// -> Se procederá en un futuro a sustituir RadioTable... por RadioSubtitle...

struct RadioSubtitleTableInfo {
    let title: LocalizedStylableText
    var subtitle: LocalizedStylableText?
    let view: (UIView & ContentResetable)?
    let insets: UIEdgeInsets?
    let height: CGFloat?
    let auxiliaryImage: UIImage?
    let auxiliaryTag: Int
    let isInitialIndex: Bool
    let isVisibleSubtitleSection: Bool
}

class RadioSubtitleTable {
    private let cellId = "RadioSubtitleTableViewCell"
    private weak var delegate: RadioTableDelegate?
    private lazy var radioComponentHelper: RadioComponentHelper = RadioComponentHelper(delegate: self)
    private var indexComponents: [IndexPath]
    private var indexComponentsToReset: [IndexPath]
    
    init(delegate: RadioTableDelegate) {
        self.indexComponents = []
        self.indexComponentsToReset = []
        self.delegate = delegate
        delegate.tableComponent.register(UINib(nibName: "RadioSubtitleTableViewCell", bundle: .module), forCellReuseIdentifier: cellId)
    }
    
    func configure(cell: RadioSubtitleTableViewCell, indexPath: IndexPath, info: RadioSubtitleTableInfo) {
        if radioComponentHelper.indexSelected() == nil && info.isInitialIndex {
            let index = indexForIndexPath(indexPath: indexPath)
            radioComponentHelper.setSelectedIndex(index: index)
        }
        cell.actionDelegate = delegate
        let index = indexForIndexPath(indexPath: indexPath)
        cell.configureInsideView(necesaryHeight: info.height ?? 0, insets: info.insets ?? .zero)
        cell.setTitle(text: info.title)
        cell.setSubtitle(text: info.subtitle ?? LocalizedStylableText.empty)
        radioComponentHelper.configureRadioComponentForIndex(component: cell, index: index)
        if let indexToReset = indexComponentsToReset.firstIndex(of: indexPath) {
            indexComponentsToReset.remove(at: indexToReset)
            info.view?.resetContent()
        }
        
        cell.subtitle(isVisible: radioComponentHelper.indexSelected() == index && info.isVisibleSubtitleSection)
        
        cell.addInsideView(view: info.view)
        cell.addActionButton(image: info.auxiliaryImage, tag: info.auxiliaryTag)
        
        cell.topConstraint.constant = cell.isFirst ? 10.0 : 0.0
        cell.bottomConstraint.constant = cell.isLast ? 10.0 : 0.0
    }
    
    func didSelectCellComponent(indexPath: IndexPath) {
        if let index = indexComponents.firstIndex(of: indexPath) {
            radioComponentHelper.didSelectButtonForIndexIndirect(index: index)
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

// MARK: - RadioComponentDelegate for RadioSubtitleTable
extension RadioSubtitleTable: RadioComponentDelegate {
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
        if let index = indexSelected(), indexPathsToReaload.contains(index), let cell = delegate?.tableComponent.cellForRow(at: index) as? RadioSubtitleTableViewCell {
            cell.showResponder()
        }
    }
}
