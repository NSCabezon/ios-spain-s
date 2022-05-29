//
//  TripView.swift
//  PersonalArea
//
//  Created by Juan Carlos López Robles on 3/20/20.
//

import UIKit
import UI
import CoreFoundationLib

protocol TripViewDelegate: AnyObject {
    func didSelectTrip(_ viewModel: TripViewModel)
    func didSelectRemoveTrip(_ viewModel: TripViewModel)
}

final class TripView: XibView {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var bottomToolBarView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var tripTypeLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var trashImageview: UIImageView!
    @IBOutlet weak var vertifalDividerView: UIView!
    @IBOutlet weak var horizontalDividerView: UIView!
    @IBOutlet weak var tripTypeView: UIView!
    private weak var delegate: TripViewDelegate?
    private var viewModel: TripViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bottomToolBarView.layoutSubviews()
        guard let currency = viewModel?.currency else { return }
        self.currencyLabel.refreshFont(force: true, margin: 0.0)
        self.currencyLabel.configureText(withLocalizedString: currency)
    }
    
    func setDelegate(_ delegate: TripViewDelegate) {
        self.delegate = delegate
    }
    
    private func setAppearance() {
        self.setViewBackgrounds()
        self.setViewsBorders()
        self.addGesture()
        self.arrowImageView.image = Assets.image(named: "icnArrowRight")
        self.trashImageview.image = Assets.image(named: "icnRemove")
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectTrip))
        self.viewContainer.addGestureRecognizer(tapGesture)
    }
    
    private func setViewBackgrounds() {
        self.view?.backgroundColor = .clear
        self.viewContainer?.backgroundColor = .white
        self.bottomToolBarView.backgroundColor = .whitesmokes
        self.vertifalDividerView.backgroundColor = .mediumSkyGray
        self.horizontalDividerView.backgroundColor = .mediumSkyGray
    }
    
    private func setViewsBorders() {
        self.viewContainer.drawBorder(cornerRadius: 6, color: .mediumSkyGray, width: 1)
        self.drawShadow(offset: (3, 4), opacity: 30, color: .lightSanGray, radius: 3)
        self.viewContainer.clipsToBounds = true
        self.tripTypeView.drawBorder(cornerRadius: 2, color: .darkTorquoise, width: 1)
    }
    
    func setViewModel(_ viewModel: TripViewModel) {
        self.viewModel = viewModel
        self.dateLabel.text = viewModel.tripDateString
        self.countryLabel.text = viewModel.country
        self.tripTypeLabel.text = viewModel.tripReason
        self.currencyLabel.configureText(withLocalizedString: viewModel.currency)
        self.deleteLabel.text = localized("generic_buttom_delete")
    }
    
    @objc func didSelectTrip() {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectTrip(viewModel)
    }
    
    @IBAction func didSelectRemoveTrip(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectRemoveTrip(viewModel)
    }
}
