//
//  LastBillTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/19/20.
//

import UIKit

protocol LastBillDelegate: AnyObject {
    func didSwipeBegin(on cell: LastBillTableViewCell)
    func didSelectReturnReceipt(_ viewModel: LastBillViewModel)
    func didSelectSeePDF(_ viewModel: LastBillViewModel)
}

class LastBillTableViewCell: UITableViewCell {
    static let identifier: String = "LastBillTableViewCell"
    @IBOutlet weak var viewContainer: UIView!
    let lastBillView = LastBillView()
    private let lastBillActionView = LastBillActionView()
    private let swipeableView = SwipeableView()
    private weak var delegate: LastBillDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
        self.addSwipeableView()
        self.swipeableView.setDelegate(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.swipeableView.setDefaultPosition()
    }
    
    func setDelegate(_ delegate: LastBillDelegate) {
        self.delegate = delegate
        self.lastBillActionView.setDelegate(delegate)
    }
    
    func setViewModel(_ viewModel: LastBillViewModel) {
        self.lastBillView.setViewModel(viewModel)
        self.lastBillActionView.setViewModel(viewModel)
    }
    
    func swipeToOriginWithAnimation() {
        self.swipeableView.swipeToOriginWithAnimation()
    }
}

private extension LastBillTableViewCell {
    private func setAppearance() {
        self.swipeableView.clipsToBounds = true
        self.lastBillActionView.drawBorder(cornerRadius: 6, color: .lightSkyBlue, width: 1)
        self.viewContainer.drawRoundedAndShadowedNew(radius: 6, borderColor: .lightSkyBlue)
    }
    
    private func addSwipeableView() {
        self.viewContainer.addSubview(swipeableView)
        self.swipeableView.addSubview(lastBillActionView)
        self.swipeableView.addSubview(lastBillView)
        self.swipeableView.fullFit()
        self.lastBillActionView.fullFit()
        self.lastBillView.fullFit()
        self.swipeableView.allowSwipe()
    }
}

extension LastBillTableViewCell: SwipeableViewDelegate {
    func didSwipeBegin() {
        self.delegate?.didSwipeBegin(on: self)
    }
}
