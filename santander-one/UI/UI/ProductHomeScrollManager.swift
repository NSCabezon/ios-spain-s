//
//  ProductHomeHandler.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 24/03/2020.
//

import UIKit

public protocol ProductHomeHeaderViewProtocol: UIView {
    associatedtype ActionsHeaderView: UIView
    var actionsHeaderView: ActionsHeaderView? { get }
    func updateHeaderAlpha(_ alpha: CGFloat)
    var headerSize: CGFloat { get }
}

public protocol ProductHomeHeaderWithTagsViewProtocol: ProductHomeHeaderViewProtocol {
    var tagsContainerView: TagsContainerView? { get set }
}

extension ProductHomeHeaderViewProtocol {
    
    public var headerSize: CGFloat {
        let actionsHeaderViewSize = self.actionsHeaderView?.frame.size.height ?? 0
        return self.frame.size.height - actionsHeaderViewSize
    }
}

extension ProductHomeHeaderWithTagsViewProtocol {
    
    public var headerSize: CGFloat {
        let actionsHeaderViewSize = self.actionsHeaderView?.frame.size.height ?? 0
        let tagsContainerSize = self.tagsContainerView?.frame.size.height ?? 0
        return self.frame.size.height - actionsHeaderViewSize - tagsContainerSize
    }
}

open class ProductHomeScrollManager<Header: ProductHomeHeaderViewProtocol, CollapsedHeader: UIView> {

    /// Configures collapsing behaviour
    public struct Configuration {
        /// Height for the collasped header view.
        let collapsedHeaderHeight: CGFloat
        /// Percentage when collapsed header appears/disappears.
        let collapseThresholdPercentage: CGFloat
        
        public init(collapsedHeaderHeight: CGFloat, collapseThresholdPercentage: CGFloat = 0.45) {
            self.collapsedHeaderHeight = collapsedHeaderHeight
            self.collapseThresholdPercentage = collapseThresholdPercentage
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
    
    public init(on view: UIView, tableView: UITableView, header: Header, collapsedHeader: CollapsedHeader, configuration: Configuration) {
        self.ownerView = view
        self.header = header
        self.tableView = tableView
        self.collapsedHeader = collapsedHeader
        self.configuration = configuration
        self.setup()
    }
    
    public func viewDidLayoutSubviews() {
        guard let tableView = self.tableView else { return }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.contentScrollSize - tableView.contentSize.height, right: 0)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateHeaderState()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateScrollOffset()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        self.updateScrollOffset()
    }
}

private extension ProductHomeScrollManager {
    
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
        UIView.animate(withDuration: 0.2, animations: {
            self.ownerView?.layoutIfNeeded()
            self.collapsedHeader.alpha = 0.0
        })
    }
    
    func showCollapsedHeader() {
        guard self.collapsedHeaderTopConstraint?.constant != 0.0 else { return }
        self.collapsedHeaderTopConstraint?.constant = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            self.ownerView?.layoutIfNeeded()
            self.collapsedHeader.alpha = 1.0
        })
    }
    
    func updateScrollOffset() {
        guard let tableView = self.tableView else { return }
        let percentage = tableView.contentOffset.y / self.header.frame.size.height
        switch percentage {
        case 0.0..<0.5:
            UIView.animate(withDuration: 0.5) {
                tableView.setContentOffset(.zero, animated: false)
            }
        case 0.5..<1.0:
            UIView.animate(withDuration: 0.5) {
                let y = self.header.headerSize
                tableView.setContentOffset(CGPoint(x: 0, y: y), animated: false)
            }
        default:
            break
        }
    }
    
    func updateHeaderState() {
        guard let tableView = self.tableView else { return }
        let offset = tableView.contentOffset.y / self.header.headerSize
        let percentage = max(0.0, min(1.0, offset))
        let tableViewTopConstraint = self.ownerView?.constraint(to: self.tableView, attribute: .top)
        tableViewTopConstraint?.constant = self.configuration.collapsedHeaderHeight * percentage
        self.header.updateHeaderAlpha(1 - percentage * 2)
        switch percentage {
        case 0.0..<configuration.collapseThresholdPercentage:
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
