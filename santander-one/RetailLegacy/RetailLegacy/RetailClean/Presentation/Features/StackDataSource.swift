import UIKit
import Foundation

protocol StackDataSourceDelegate: class {
    func scrollToVisible(view: UIView)
}

class StackSection {
    private(set) var items: [StackItemProtocol]
    
    init() {
       items = []
    }
    
    func add(item: StackItemProtocol) {
        items.append(item)
    }
    
    func add(items: [StackItemProtocol]) {
        self.items.append(contentsOf: items)
    }
}

class StackDataSource {
    private weak var stackView: UIStackView?
    private weak var delegate: StackDataSourceDelegate?
    private var sections: [StackSection]
    
    init(stackView: UIStackView, delegate: StackDataSourceDelegate) {
        self.delegate = delegate
        self.stackView = stackView
        self.sections = []
    }
    
    func setSections(sections: [StackSection], distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0) {
        self.sections = []
        guard let stackView = stackView else { return }
        for stackViewSection in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(stackViewSection)
            stackViewSection.removeFromSuperview()
        }
        for section in sections {
            insertSection(section: section, distribution: distribution, spacing: spacing)
        }
    }
    
    func reloadSections(sections: [StackSection], distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0) {
        guard let stackView = stackView else { return }
        for stackViewSection in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(stackViewSection)
            stackViewSection.removeFromSuperview()
        }
        for section in sections {
            insertSection(section: section, distribution: distribution, spacing: spacing)
        }
    }
    
    func removeSection(index: Int, animated: Bool = false) {
        guard let stackView = stackView else { return }
        guard let stackViewSection = getSection(identifier: index) else { return }
        for i in (index + 1)..<sections.count {
            if let stackViewSection = getSection(identifier: i) {
                stackViewSection.tag = i - 1
            }
        }
        sections.remove(at: index)
        if animated {
            UIView.animate(withDuration: 0.5) {
                stackView.removeArrangedSubview(stackViewSection)
                stackViewSection.removeFromSuperview()
            }
        } else {
            stackView.removeArrangedSubview(stackViewSection)
            stackViewSection.removeFromSuperview()
        }
    }
    
    func insertSection(section: StackSection, index: Int? = nil, animated: Bool = false, distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0) {
        guard let stackView = stackView else { return }
        let stackViewSection = UIStackView()
        stackViewSection.axis = .vertical
        stackViewSection.alignment = .fill
        stackViewSection.distribution = distribution
        stackViewSection.spacing = spacing
        stackViewSection.backgroundColor = stackView.backgroundColor
        for item in section.items {
            if let rowView = getViewForItem(item: item) {
                stackViewSection.addArrangedSubview(rowView)
                rowView.accessibilityIdentifier = item.accessibilityIdentifier ?? "" + "_\(index)" 
            }
        }
        if let index = index {
            for i in (index..<stackView.arrangedSubviews.count).reversed() {
                if let stackViewSection = getSection(identifier: i) {
                    stackViewSection.tag = i+1
                }
            }
            stackViewSection.tag = index
            stackView.insertArrangedSubview(stackViewSection, at: index)
            sections.insert(section, at: index)
        } else {
            stackViewSection.tag = stackView.arrangedSubviews.count
            stackView.addArrangedSubview(stackViewSection)
            sections.append(section)
        }
        if animated {
            DispatchQueue.main.async {
                self.delegate?.scrollToVisible(view: stackViewSection)
            }
        }
    }
    
    func findData(identifier: String) -> String? {
        for section in sections {
            let inputs = section.items.compactMap { $0 as? InputIdentificable }
            if let input = inputs.first(where: { $0.inputIdentifier == identifier }) {
                return input.dataEntered
            }
        }
        return nil
    }
    
    func updateData(identifier: String, value: String) {
        for section in sections {
            let inputs = section.items.compactMap { $0 as? InputEditableIdentificable }
            if let input = inputs.first(where: { $0.inputIdentifier == identifier }) {
                input.setCurrentValue(value)
            }
        }
    }
    
    private func getSection(identifier: Int) -> UIStackView? {
        guard let stackView = stackView else { return nil }
        return stackView.arrangedSubviews.first(where: {$0.tag == identifier}) as? UIStackView
    }
    
    private func getViewForItem(item: StackItemProtocol) -> UIView? {
        let listViews = UINib(nibName: item.reuseIdentifier, bundle: .module).instantiate(withOwner: nil, options: nil)
        guard let view = listViews.first as? StackItemView else {
            return nil
        }
        item.bind(view: view)
        return view
    }
}
