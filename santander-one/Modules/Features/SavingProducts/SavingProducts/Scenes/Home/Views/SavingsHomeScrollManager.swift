//
//  SavingsHomeScrollManager.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 24/03/2020.
//

import UI
import UIKit

protocol SavingsHomeHeaderViewProtocol: UIView {
    associatedtype ActionsHeaderView: UIView
    var actionsHeaderView: ActionsHeaderView? { get }
    var headerSize: CGFloat { get }
}

protocol SavingsHomeHeaderWithTagsViewProtocol: SavingsHomeHeaderViewProtocol {
    var tagsContainerView: TagsContainerView? { get set }
}

extension SavingsHomeHeaderViewProtocol {
    
    var headerSize: CGFloat {
        let actionsHeaderViewSize = self.actionsHeaderView?.frame.size.height ?? 0
        return self.frame.size.height - actionsHeaderViewSize
    }
}

extension SavingsHomeHeaderWithTagsViewProtocol {
    
    var headerSize: CGFloat {
        let actionsHeaderViewSize = self.actionsHeaderView?.frame.size.height ?? 0
        let tagsContainerSize = self.tagsContainerView?.frame.size.height ?? 0
        return self.frame.size.height - actionsHeaderViewSize - tagsContainerSize
    }
}

class SavingsHomeScrollManager<Header: SavingsHomeHeaderViewProtocol, CollapsedHeader: UIView> {
    /// Configures collapsing behaviour
    struct Configuration {
        /// Height for the collasped header view.
        let collapsedHeaderHeight: CGFloat
        /// Percentage when collapsed header appears/disappears.
        let collapseThresholdPercentage: CGFloat
        /// When showing collapsed header, action header will show underneath it.
        let isActionHeaderViewUnderneathCollapsedView: Bool
        
        init(collapsedHeaderHeight: CGFloat,
             collapseThresholdPercentage: CGFloat = 0.45,
             isActionHeaderViewUnderneathCollapsedView: Bool = false) {

            self.collapsedHeaderHeight = collapsedHeaderHeight
            self.collapseThresholdPercentage = collapseThresholdPercentage
            self.isActionHeaderViewUnderneathCollapsedView = isActionHeaderViewUnderneathCollapsedView
        }
    }
    
    // MARK: - Private attributes
    
    private let header: Header
    private let collapsedHeader: CollapsedHeader
    private let configuration: Configuration
    private weak var ownerView: UIView?
    private weak var tableView: UITableView?
    private var collapsedHeaderTopConstraint: NSLayoutConstraint?
    
    // MARK: - Public methods
    
    init(on view: UIView, tableView: UITableView, header: Header, collapsedHeader: CollapsedHeader, configuration: Configuration) {
        self.ownerView = view
        self.header = header
        self.tableView = tableView
        self.collapsedHeader = collapsedHeader
        self.configuration = configuration
        self.setup()
    }
    
    func viewDidLayoutSubviews() {
        guard let tableView = self.tableView else { return }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.contentScrollSize - tableView.contentSize.height, right: 0)
    }
    
    func scrollViewWillScrollToTop(_ scrollView: UIScrollView) {
        let tableViewTopConstraint = self.ownerView?.constraint(to: self.tableView, attribute: .top)
        tableViewTopConstraint?.constant = 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateHeaderState(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateScrollOffset()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        self.updateScrollOffset()
    }
}

private extension SavingsHomeScrollManager {
    
    var contentScrollSize: CGFloat {
        guard let tableView = self.tableView else { return 0 }
        let minimumScrollSize = tableView.frame.size.height + self.header.frame.size.height
        guard tableView.contentSize.height < minimumScrollSize else { return tableView.contentSize.height }
        return minimumScrollSize
    }
    
    func setup() {
        self.setupTableViewHeader()
        self.setupCollapsedHeader()
    }
    
    func setupTableViewHeader() {
        self.tableView?.setTableHeaderView(headerView: self.header)
        self.tableView?.updateHeaderViewFrame()
    }
    
    func setupCollapsedHeader() {
        guard let view = self.ownerView else { return }
        self.collapsedHeader.translatesAutoresizingMaskIntoConstraints = false
        self.ownerView?.addSubview(self.collapsedHeader)
        self.collapsedHeader.alpha = 0.0
        self.collapsedHeader.heightAnchor.constraint(equalToConstant: self.configuration.collapsedHeaderHeight).isActive = true
        self.collapsedHeader.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.collapsedHeader.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        if #available(iOS 11.0, *) {
            self.collapsedHeaderTopConstraint = self.collapsedHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        } else {
            self.collapsedHeaderTopConstraint = self.collapsedHeader.topAnchor.constraint(equalTo: view.topAnchor)
        }
        self.collapsedHeaderTopConstraint?.isActive = true
    }
    
    func hideCollapsedHeader() {
        guard self.collapsedHeaderTopConstraint?.constant != -self.configuration.collapsedHeaderHeight else { return }
        self.collapsedHeaderTopConstraint?.constant = -self.configuration.collapsedHeaderHeight
        UIView.animate(withDuration: 0.5) {
            if self.collapsedHeader.alpha > 0, self.tableView!.panGestureRecognizer.translation(in: self.tableView!.superview).y > 0 {
                let point = CGPoint(x:0, y: (self.tableView?.contentOffset.y ?? 0) - self.configuration.collapsedHeaderHeight * 1.5)
                self.tableView?.setContentOffset(point, animated: false)
            }
            self.collapsedHeader.alpha = 0.0
            self.ownerView?.layoutIfNeeded()
        }
    }
    
    func showCollapsedHeader() {
        guard self.collapsedHeaderTopConstraint?.constant != 0.0 else { return }
        self.collapsedHeaderTopConstraint?.constant = 0.0
        UIView.animate(withDuration: 0.5) {
            self.ownerView?.layoutIfNeeded()
            self.collapsedHeader.alpha = 1.0
            let y = self.configuration.isActionHeaderViewUnderneathCollapsedView ? self.header.frame.size.height: self.header.headerSize
            let tableViewTopConstraint = self.ownerView?.constraint(to: self.tableView, attribute: .top)
            tableViewTopConstraint?.constant = self.configuration.collapsedHeaderHeight
            self.tableView?.setContentOffset(CGPoint(x: 0, y: y), animated: false)
            self.ownerView?.layoutIfNeeded()
        }
    }
    
    func updateScrollOffset() {
        guard let tableView = self.tableView else { return }
        let percentage = tableView.contentOffset.y / self.header.frame.size.height
        switch percentage {
        case 0.0..<0.5:
            UIView.animate(withDuration: 0.5) {
                tableView.setContentOffset(.zero, animated: false)
            }
        case 0.5..<configuration.collapseThresholdPercentage:
            UIView.animate(withDuration: 0.5) {
                let y = self.configuration.isActionHeaderViewUnderneathCollapsedView ? self.header.frame.size.height: self.header.headerSize
                tableView.setContentOffset(CGPoint(x: 0, y: y), animated: false)
            }
        default:
            break
        }
    }
    
    func updateHeaderState(_ scrollView: UIScrollView) {
        guard let tableView = self.tableView else { return }
        let offset = tableView.contentOffset.y / self.header.headerSize
        switch offset {
        case 0.0..<configuration.collapseThresholdPercentage:
            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y >= 0 {
                let tableViewTopConstraint = self.ownerView?.constraint(to: self.tableView, attribute: .top)
                tableViewTopConstraint?.constant = self.configuration.collapsedHeaderHeight * (offset / 5)
                self.ownerView?.layoutIfNeeded()
            }
            self.hideCollapsedHeader()
        default:
            self.showCollapsedHeader()
        }
    }
}

private extension UIView {
    
    func constraint(to view: UIView?, attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        return self.constraints.first {
            view == $0.firstItem as? UIView && $0.firstAttribute == attribute
        }
    }
}
