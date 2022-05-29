//
//  BillActionBaseView.swift
//  Bills
//
//  Created by Ignacio González Miró on 25/5/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol DidSelectBannerDelegate: AnyObject {
    func didSelectPayment()
    func didSelectDomicile()
    func didSelectBanner(_ viewModel: OfferBannerViewModel?)
}

public final class BillActionBaseView: XibView {
    @IBOutlet private weak var stackView: UIStackView!
    weak var delegate: DidSelectBannerDelegate?
    private var offerViewModel: OfferBannerViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ offerBannerViewModel: OfferBannerViewModel?) {
        removeArrangedSubviewsIfNeeded()
        addBillActionView()
        addOfferBannerViewIfNeeded(offerBannerViewModel)
    }
}

private extension BillActionBaseView {
    func setupView() {
        backgroundColor = .skyGray
    }
    
    func addBillActionView() {
        let view = BillActionView()
        view.delegate = self
        view.heightAnchor.constraint(equalToConstant: 160).isActive = true
        self.stackView.addArrangedSubview(view)
    }
    
    func addOfferBannerViewIfNeeded(_ offerBannerViewModel: OfferBannerViewModel?) {
        guard let viewModel = offerBannerViewModel else {
            return
        }
        self.offerViewModel = viewModel
        let view = BillActionLocationView()
        view.delegate = self
        view.heightAnchor.constraint(equalToConstant: 65).isActive = true
        self.stackView.addArrangedSubview(view)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}

extension BillActionBaseView: BillActionViewDelegate {
    func didSelectPayment() {
        delegate?.didSelectPayment()
    }
    
    func didSelectDomicile() {
        delegate?.didSelectDomicile()
    }
}

extension BillActionBaseView: DidTapInBillActionLocationViewDelegate {
    func didTapInLocation() {
        guard let viewModel = self.offerViewModel else {
            return
        }
        delegate?.didSelectBanner(viewModel)
    }
}
