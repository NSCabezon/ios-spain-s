//
//  UITableView+Publishers.swift
//  PrivateMenu
//
//  Created by Boris Chirino Fernandez on 24/1/22.
//
import OpenCombine

public extension UITableView {
    /// Get ready about data already loaded
    /// - Returns: true if data is loaded.
    func visibleCellsLoadedSubject() -> PassthroughSubject<Bool, Never>? {
        guard let combineds = self.dataSource as? TableViewCombineProtocol else {
            return nil
        }
        return combineds.visibleCellsLoadedSubject
    }
    
    /// Create a subscription to this item to listen when e tableview cell is selected. Cast to your custom model type when unrap the value.
    /// - Returns: the model item that datasource knows.
    func selectedCellSubject() -> PassthroughSubject<AnyHashable, Never>? {
        guard let combineds = self.dataSource as? TableViewCombineProtocol else {
            return nil
        }
        return combineds.selectedCellSubject
    }
    
    /// Handle the possible values when scrolling a tableview. usefull for pagination or drag changes.
    /// - Returns: Custom state type that handle three possible values. See  TableViewCombineScrollState for more detail
    func scrollStateSubject() -> PassthroughSubject<TableViewCombineScrollState, Never>? {
        guard let combineds = self.dataSource as? TableViewCombineProtocol else {
            return nil
        }
        return combineds.scrollState
    }
}
