//
//  File.swift
//  BillTableViewHeader
//
//  Created by Juan Carlos López Robles on 2/19/20.
//

import Foundation
import UI
import CoreFoundationLib

protocol BillTableViewHeaderDelegate: AnyObject {
    func didSelectTimeLine()
    func didSelectFutureBill(_ futureBillViewModel: FutureBillViewModel)
    func didSelectPayment()
    func didSelectDomicile()
    func didSegmentIndexChanged(_ index: Int)
    func didSelectFilter()
    func scrollViewDidEndDecelerating()
    func didSelectOfferBanner(_ offerViewModel: OfferBannerViewModel?)
}

class BillTableViewHeader: UIView {
    private let billActionBaseView = BillActionBaseView()
    private let futureBillView = FutureBillView()
    private let billFilterView = BillFilterView()
    private let groupSegmentedControl = GroupSegmentedControl()
    private weak var delegate: BillTableViewHeaderDelegate?
    var tagsContainerView: TagsContainerView?
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ offerBannerViewModel: OfferBannerViewModel?) {
        addBillActionBaseView(offerBannerViewModel)
        self.stackView.addArrangedSubview(futureBillView)
        self.stackView.addArrangedSubview(billFilterView)
        self.stackView.addArrangedSubview(groupSegmentedControl)
    }
    
    func setFutureBillState(_ state: ViewState<[FutureBillViewModel]>) {
        self.futureBillView.setFutureBillState(state)
    }
    
    func setDelegate(delegate: BillTableViewHeaderDelegate?) {
        self.delegate = delegate
    }
    
    func setBillMonths(_ months: Int) {
        self.billFilterView.setMonths(months: months)
    }
    
    func setMonthsHidden() {
        self.billFilterView.setMonthsHidden()
    }
    
    func showMonths() {
        self.billFilterView.showMonths()
    }
    
    func showFiltersButton() {
        self.billFilterView.showFilterButton()
    }
    
    func hideFiltersButton() {
        self.billFilterView.hideFilterButton()
    }
    
    func disableTimeLine() {
        self.futureBillView.disableTimeLine()
    }
    
    func setFutureBillHidden() {
        self.futureBillView.isHidden = true
        self.stackView.layoutIfNeeded()
    }
    
    func addTagContainer(withTags tags: [TagMetaData], delegate: TagsContainerViewDelegate) {
        let tagsContainerView = TagsContainerView()
        tagsContainerView.delegate = delegate
        tagsContainerView.addTags(from: tags)
        tagsContainerView.backgroundColor = .white
        self.stackView.insertArrangedSubview(tagsContainerView, at: self.stackView.arrangedSubviews.firstIndex(of: self.groupSegmentedControl) ?? 0)
        tagsContainerView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
        self.tagsContainerView = tagsContainerView
    }
}

private extension BillTableViewHeader {
    func setupView() {
        self.addSubview(stackView)
        self.stackView.fullFit()
        self.setDelegates()
    }
    
    func setDelegates() {
        self.futureBillView.setDelegate(self)
        self.billFilterView.setDelegate(self)
        self.groupSegmentedControl.setDelegate(delegate: self)
    }
    
    func addBillActionBaseView(_ offerBannerViewModel: OfferBannerViewModel?) {
        billActionBaseView.delegate = self
        billActionBaseView.configView(offerBannerViewModel)
        self.stackView.addArrangedSubview(billActionBaseView)
    }
}

extension BillTableViewHeader: BillActionViewDelegate {
    func didSelectPayment() {
        self.delegate?.didSelectPayment()
    }
    
    func didSelectDomicile() {
        self.delegate?.didSelectDomicile()
    }
}

extension BillTableViewHeader: FutureBillCollectionDatasourceDelegate {
    func didSelectTimeLine() {
        self.delegate?.didSelectTimeLine()
    }
    
    func scrollViewDidEndDecelerating() {
        self.delegate?.scrollViewDidEndDecelerating()
    }

    func didSelectFutureBill(_ futureBillViewModel: FutureBillViewModel) {
        self.delegate?.didSelectFutureBill(futureBillViewModel)
    }
}

extension BillTableViewHeader: GroupSegmentedControlDelegate {
    func didSegmentIndexChanged(_ index: Int) {
        self.delegate?.didSegmentIndexChanged(index)
    }
}

extension BillTableViewHeader: BillFilterViewDelegate {
    func didSelectFilter() {
        self.delegate?.didSelectFilter()
    }
}

extension BillTableViewHeader: DidSelectBannerDelegate {
    func didSelectBanner(_ viewModel: OfferBannerViewModel?) {
        self.delegate?.didSelectOfferBanner(viewModel)
    }
}
