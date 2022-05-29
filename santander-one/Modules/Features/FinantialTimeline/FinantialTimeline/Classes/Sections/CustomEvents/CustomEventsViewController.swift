//
//  PersonalEventsViewControllerTableViewController.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 10/10/2019.
//

import UIKit

class CustomEventsViewController: UIViewController {

    // MARK: - Properties
    let customEventsTableView = UITableView(frame: .zero, style: .plain)
    let customEventcellName = "CustomEventCell"
    let topSeparatorView = UIView()
    let viewLoader = UIImageView()
    let itemsLoader = UIImageView()
    let noCustomEventsView = NoCustomEventsView()
    let errorView = ErrorView()
    var events: [PeriodicEvent] = []
    var moreEventsAvailable = false
    
    // MARK: - Dependencies
    var presenter: CustomEventsPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        presenter?.viewDidLoad()
        showViewLoader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        customEventsTableView.deselectAllItems(animated: true)
    }

    func configView() {
        title = CustomEventsString().title
        configureBack()
        configTopSeparatorView()
        configViewLoader()
        configErrorView()
        configTableView()
        configNoEventsView()        
    }

    private func configureBack() {
        let barButton = UIBarButtonItem(image: UIImage(fromModuleWithName: "backButton"), style: .plain, target: self, action: #selector(onBackPressed))
        navigationItem.leftBarButtonItem = barButton
    }
    
    @objc private func onBackPressed() {
        presenter?.didSelectBack()
    }
    
    func configTopSeparatorView() {
        view.addSubview(topSeparatorView)
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        topSeparatorView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        topSeparatorView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        if #available(iOS 11.0, *) {
            topSeparatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            let navBar = navigationController?.navigationBar.frame.height
            let statusBar = UIApplication.shared.statusBarFrame.height
            let height = (navBar ?? 0) + statusBar
            topSeparatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: height).isActive = true
        }
        topSeparatorView.backgroundColor = .sky30
    }
    
    func configViewLoader() {
        viewLoader.setAnimationImagesWith(prefixName: "BS_", range: 1...154, format: "%03d")
        
        view.addSubview(viewLoader)
        viewLoader.isHidden = true
        viewLoader.translatesAutoresizingMaskIntoConstraints = false
        viewLoader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        viewLoader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func configItemsLoader() {
        itemsLoader.setAnimationImagesWith(prefixName: "BS_s-loader-", range: 1...48, format: "%03d")
        
        view.addSubview(itemsLoader)
        itemsLoader.isHidden = true
        itemsLoader.translatesAutoresizingMaskIntoConstraints = false
        itemsLoader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        if #available(iOS 11.0, *) {
            itemsLoader.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            itemsLoader.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }

    func configTableView() {
        customEventsTableView.register(CustomEventCell.self, forCellReuseIdentifier: customEventcellName)
        customEventsTableView.delegate = self
        customEventsTableView.dataSource = self
        customEventsTableView.separatorStyle = .singleLine
        customEventsTableView.separatorInset = .zero
        customEventsTableView.separatorColor = .paleSkyBlue
        customEventsTableView.tableFooterView = UIView()
        
        view.addSubview(customEventsTableView)
        customEventsTableView.isHidden = true
        customEventsTableView.translatesAutoresizingMaskIntoConstraints = false
        customEventsTableView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor).isActive = true
        customEventsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customEventsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        customEventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func configNoEventsView() {
        noCustomEventsView.delegate = self
        
        view.addSubview(noCustomEventsView)
        noCustomEventsView.isHidden = true
        noCustomEventsView.translatesAutoresizingMaskIntoConstraints = false
        noCustomEventsView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 60).isActive = true
        noCustomEventsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noCustomEventsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func configErrorView() {
        errorView.setError(with: CustomEventsString().errorTitle,
                           and: CustomEventsString().errorSubTitle,
                           type: .error)
        
        view.addSubview(errorView)
        errorView.isHidden = true
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 50).isActive = true
        errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 11).isActive = true
        errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -11).isActive = true
    }
    
    func pagination(row: Int) {
        if moreEventsAvailable, events.count - 1 == row {
            presenter?.loadMoreEvents()
            showItemsLoader()
        }
    }
}

extension CustomEventsViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        defer {
            pagination(row: indexPath.row)
        }
        
        let cell = CustomEventCell(style: .default, reuseIdentifier: customEventcellName)
        cell.configCell(withEvent: events[indexPath.row])
        
        return cell
    }
}


extension CustomEventsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        presenter?.didSelectEvent(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
}


extension CustomEventsViewController: CustomEventsViewProtocol {
    
    func loadEvents(events: [PeriodicEvent]) {
        self.events += events
        customEventsTableView.reloadData()
    }
    
    func setMoreEventsAvailable(available: Bool) {
        moreEventsAvailable = available
    }

    func showViewLoader() {
        viewLoader.isHidden = false
        viewLoader.startAnimating()
    }
    
    func hideViewLoader() {
        viewLoader.stopAnimating()
        viewLoader.isHidden = true
    }
    
    func showItemsLoader() {
        itemsLoader.isHidden = false
        itemsLoader.startAnimating()
    }
    
    func hideItemsLoader() {
        itemsLoader.stopAnimating()
        itemsLoader.isHidden = true
    }
    
    func showEvents() {
        hideViewLoader()
        customEventsTableView.isHidden = false
    }
    
    func showNoEventsAvailable() {
        hideViewLoader()
        noCustomEventsView.isHidden = false
    }
    
    func showError() {
        hideViewLoader()
        errorView.isHidden = false
    }
        

}

extension CustomEventsViewController: NoCustomEventsViewDelegate {

    func newEventTapped() {
        presenter?.newEventTapped()
    }
}
