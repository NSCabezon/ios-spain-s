//
//  TimeLineView.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 23/03/2020.
//

import UI
import CoreFoundationLib

protocol TimeLineViewProtocol: AnyObject {
    func didUpdateData(_ viewModel: TimeLineViewModel)
    func showLoading()
    func dismissLoading()
    func showGenericError()
    func clearDataSource()
}

protocol TimeLineViewDelegate: AnyObject {
    func didSelectCellType(_ expenseType: ExpenseType)
}

class TimeLineView: UIDesignableView {
    
    private var timeLineDataSource = TimeLineDataSource()
    weak var viewDelegate: TimeLineViewProtocol?
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var loadingView: UIImageView!
    @IBOutlet weak private var noResultsView: TimeLineErrorView!
    
    public weak var delegate: TimeLineViewDelegate?
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override func commonInit() {
        super.commonInit()
        self.loadingView.isHidden = true
        self.viewDelegate = self
        self.tableView.separatorStyle = .none
        timeLineDataSource.registerCellsFor(self.tableView)
        self.tableView.dataSource = timeLineDataSource
        self.tableView.delegate = self
        self.loadingView.setPointsLoader()
        self.noResultsView.setTitle(localized("product_title_emptyError"))
        self.noResultsView.setSubTitle(localized("product_label_emptyError"))
    }
}

extension TimeLineView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TimeLineMovementCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCellType(timeLineDataSource.getItemSourceAtIndexPath(indexPath))
    }
}

extension TimeLineView: TimeLineViewProtocol {
    func clearDataSource() {
        self.timeLineDataSource.clearData()
        self.tableView.reloadData()
    }
    
    func showGenericError() {
        self.dismissLoading()
    }
    
    func showLoading() {
        self.noResultsView.isHidden = true
        self.loadingView.isHidden = false
        self.loadingView.startAnimating()
    }
    
    func dismissLoading() {
        self.loadingView.isHidden = true
        self.loadingView.stopAnimating()
    }
    
    func didUpdateData(_ viewModel: TimeLineViewModel) {
        self.noResultsView.isHidden = true
        self.timeLineDataSource.didUpdateDataSourceWith(viewModel)
        self.timeLineDataSource.setActiveMonth(viewModel.currentMonth)
        self.tableView.reloadData()
    }
}
