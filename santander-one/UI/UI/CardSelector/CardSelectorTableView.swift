//
//  CardSelectorTableView.swift
//  UI
//
//  Created by Ignacio González Miró on 20/10/2020.
//

import UIKit
import CoreFoundationLib

public protocol DidTapInCardPickerTableDelegate: AnyObject {
    func didTapInCardPickerTable(_ index: Int)
}

final public class CardSelectorTableView: UITableView {
    private var ownerCards: [OwnerCards] = []
    weak public var cardDelegate: DidTapInCardPickerTableDelegate?
    private let cellHeight: CGFloat = 60
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setupData(_ ownerCards: [OwnerCards]) {
        self.ownerCards = ownerCards
        reloadData()
    }
}

private extension CardSelectorTableView {
    func setupView() {
        dataSource = self
        delegate = self
        isScrollEnabled = false
        tableFooterView = UIView(frame: .zero)
        separatorStyle = .none
        accessibilityIdentifier = AccessibilityPickerWithImageAndTitle.tableView.rawValue
        layer.cornerRadius = 4.0
        clipsToBounds = false
        drawShadow(offset: (x: 0, y: 2), opacity: 0.5, color: .lightSanGray, radius: 4.0)
    }
}

extension CardSelectorTableView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ownerCards.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: CardSelectorCell.identifier, for: indexPath) as? CardSelectorCell else {
            return CardSelectorCell()
        }
        let item = self.ownerCards[indexPath.row]
        cell.setup(item.urlString, title: item.text, number: item.number)
        return cell
    }
}

extension CardSelectorTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deselectRow(at: indexPath, animated: true)
        cardDelegate?.didTapInCardPickerTable(indexPath.row)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last, indexPath.row == lastVisibleIndexPath.row {
            let numberOfRows: CGFloat = CGFloat(ownerCards.count)
            let cellHeight = cell.frame.size.height
            let tableHeight = cellHeight * numberOfRows
            self.frame.size.height = tableHeight
            self.setNeedsDisplay()
        }
    }
}
