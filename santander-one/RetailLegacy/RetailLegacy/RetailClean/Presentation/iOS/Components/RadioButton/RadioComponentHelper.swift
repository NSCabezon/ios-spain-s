import Foundation

protocol RadioComponentDelegate: class {
    func reloadRadioButtons(indexes: [Int])
}

protocol RadioComponentProtocol {
    var isMark: Bool { get }
    func setMarked(isMarked: Bool)
}

class RadioComponentHelper {
    private weak var delegate: RadioComponentDelegate?
    private var selected: Int?
    
    init(delegate: RadioComponentDelegate) {
        self.delegate = delegate
    }
    
    func configureRadioComponentForIndex(component: RadioComponentProtocol, index: Int) {
        let isMark = selected == index
        if component.isMark != isMark {
            component.setMarked(isMarked: isMark)
        }
    }
    
    func indexSelected() -> Int? {
        return selected
    }
    
    func setSelectedIndex(index: Int) {
        selected = index
    }
    
    //! Used when indirect selecting. Reload and change cell values
    func didSelectButtonForIndexIndirect(index: Int) {
        guard selected != nil else {
            return
        }
        var indexes = [index]
        if let selected = selected {
            indexes.append(selected)
        }
        selected = index
        self.delegate?.reloadRadioButtons(indexes: indexes)
    }
    
    //! Used when direct selecting. Just change the state reloading cells
    func didSelectButtonForIndex(index: Int) {
        guard selected == nil || selected != index else {
            return
        }
        var indexes = [index]
        if let selected = selected {
            indexes.append(selected)
        }
        selected = index
        self.delegate?.reloadRadioButtons(indexes: indexes)
    }
}
