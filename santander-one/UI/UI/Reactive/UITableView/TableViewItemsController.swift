//
//  TableViewItemsController.swift
//  PrivateMenu
//
//  Created by Boris Chirino Fernandez on 20/1/22.
//
import OpenCombine
import UIKit

public protocol SectionTypeConfigurableProtocol: UITableViewHeaderFooterView {
    func configureLabel(with titleKey: String)
}

public enum TableViewCombineScrollState {
    case didScroll
    case willDisplay
    case endDragging(decelerate: Bool)
    case endDecelerating
}

public protocol TableViewCombineProtocol {
    var visibleCellsLoadedSubject: PassthroughSubject<Bool, Never> { get }
    var selectedCellSubject: PassthroughSubject<AnyHashable, Never> { get }
    var scrollState: PassthroughSubject<TableViewCombineScrollState, Never> { get }
}

public class TableViewItemsController<CollectionType>: NSObject, UITableViewDataSource, UITableViewDelegate, TableViewCombineProtocol
where CollectionType: RandomAccessCollection, CollectionType.Index == Int,
      CollectionType.Element: Hashable, CollectionType.Element: RandomAccessCollection,
      CollectionType.Element.Index == Int, CollectionType.Element.Element: Hashable {
    
    public typealias Element = CollectionType.Element.Element
    public typealias CellFactory<Element: Equatable> = (TableViewItemsController<CollectionType>,
                                                        UITableView,
                                                        IndexPath,
                                                        Element) -> UITableViewCell
    public typealias CellConfig<Element, Cell> = (Cell, IndexPath, Element) -> Void
    private let cellFactory: CellFactory<Element>
    private var collection: CollectionType!
    public let visibleCellsLoadedSubject = PassthroughSubject<Bool, Never>()
    public let selectedCellSubject = PassthroughSubject<AnyHashable, Never>()
    public let scrollState = PassthroughSubject<TableViewCombineScrollState, Never>()
    private var sectionIdentifier: String?
    
    /// Should the table updates be animated or static.
    public var animated = false
    
    /// The table view for the data source
    var tableView: UITableView!
    
    /// A fallback data source to implement custom logic like indexes, dragging, etc.
    public var dataSource: UITableViewDataSource?
    
    // MARK: - Init
    
    /// An initializer that takes a cell type and identifier and configures the controller to dequeue cells
    /// with that data and configures each cell by calling the developer provided `cellConfig()`.
    /// - Parameter cellIdentifier: A cell identifier to use to dequeue cells from the source table view
    /// - Parameter sectionIdentifier: A section identifier used to dequeue sectopms from the source table view.
    /// Sections header views must conform the SectionTypeConfigurableProtocol.
    /// - Parameter cellType: A type to cast dequeued cells as
    /// - Parameter cellConfig: A closure to call before displaying each cell
    
    public init<CellType>(cellIdentifier: String, cellType: CellType.Type, sectionIdentifier: String? = nil, cellConfig: @escaping CellConfig<Element, CellType>) where CellType: UITableViewCell {
        cellFactory = { dataSource, tableView, indexPath, value in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CellType
            guard let dequeuedCell = cell else {
                return UITableViewCell()
            }
            cellConfig(dequeuedCell, indexPath, value)
            return dequeuedCell
        }
        self.sectionIdentifier = sectionIdentifier
    }
    
    /// An initializer that takes a closure expected to return a dequeued cell ready to be displayed in the table view.
    /// - Parameter cellFactory: A `(TableViewItemsController<CollectionType>, UITableView, IndexPath, Element) -> UITableViewCell` closure. Use the table input parameter to dequeue a cell and configure it with the `Element`'s data
    public init(cellFactory: @escaping CellFactory<Element>) {
        self.cellFactory = cellFactory
    }
    
    deinit {
        collection = nil
        dataSource = nil
    }
    
    // MARK: - Update collection
    private let fromRow = {(section: Int) in return {(row: Int) in return IndexPath(row: row, section: section)}}
    
    func updateCollection(_ items: CollectionType) {
        // If the changes are not animatable, reload the table
        guard animated, collection != nil, items.count == collection.count else {
            collection = items
            tableView.reloadData()
            return
        }
    }
    
    // MARK: - UITableViewDataSource protocol
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard collection != nil else { return 0 }
        return collection.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellFactory(self, tableView, indexPath, collection[indexPath.section][indexPath.row])
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionModel = collection[section] as? CollectionSection<CollectionType.Element.Element>,
              self.sectionIdentifier == nil else {
            return dataSource?.tableView?(tableView, titleForHeaderInSection: section)
        }
        return sectionModel.header
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sectionModel = collection[section] as? CollectionSection<CollectionType.Element.Element> else {
            return dataSource?.tableView?(tableView, titleForFooterInSection: section)
        }
        return sectionModel.footer
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionModel = collection[section] as? CollectionSection<CollectionType.Element.Element>,
              let headerKey = sectionModel.header,
              let sectionIdentifier = self.sectionIdentifier,
              let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionIdentifier) as? SectionTypeConfigurableProtocol
        else { return nil }
        view.configureLabel(with: headerKey)
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionModel = collection[section] as? CollectionSection<CollectionType.Element.Element>,
              sectionModel.header != nil else {
                  return .zero
        }
        return UITableView.automaticDimension
    }

    // MARK: - UITableViewDelegate protocol
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.collection[indexPath.section][indexPath.row]
        selectedCellSubject.send(item)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        scrollState.send(.willDisplay)
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            visibleCellsLoadedSubject.send(true)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollState.send(.didScroll)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollState.send(.endDragging(decelerate: decelerate))
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollState.send(.endDecelerating)
    }
}
