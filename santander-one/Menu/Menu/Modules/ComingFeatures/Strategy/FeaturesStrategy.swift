//
//  FeaturesStrategy.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 27/02/2020.
//

import Foundation

public enum FeatureDataSourceType: Int {
    case coming = 0
    case implemented = 1
}

protocol FeaturesStrategyDataSource: AnyObject {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
}

class ComingFeaturesStrategy: FeaturesStrategyDataSource {
    
    let items: [ComingFeatureViewModel]
    weak var delegate: ComingFeatureCellDelegate?
    
    init(items: [ComingFeatureViewModel], delegate: ComingFeatureCellDelegate) {
        self.items = items
        self.delegate = delegate
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ComingFeatureTableViewCell.identifier, for: indexPath)
            as? ComingFeatureTableViewCell else { return UITableViewCell() }
        cell.setViewModel(self.items[indexPath.row])
        cell.delegate = self.delegate
        cell.selectionStyle = .none
        return cell
    }
}

class ImplementedFeaturesStrategy: FeaturesStrategyDataSource {
    
    let items: [ImplementedFeatureViewModel]
    weak var  delegate: ImplementedFeatureCellDelegate?
    
    init(items: [ImplementedFeatureViewModel], delegate: ImplementedFeatureCellDelegate) {
        self.items = items
        self.delegate = delegate
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImplementedFeatureTableViewCell.identifier, for: indexPath)
            as? ImplementedFeatureTableViewCell else { return UITableViewCell() }
        cell.setViewModel(self.items[indexPath.row])
        cell.delegate = self.delegate
        cell.selectionStyle = .none
        return cell
    }
}
