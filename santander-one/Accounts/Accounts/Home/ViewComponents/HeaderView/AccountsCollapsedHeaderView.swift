//
//  AccountsCollapsedHeaderView.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import UIKit
import UI
import CoreFoundationLib

protocol AccountsCollapsedHeaderViewDelegate: AnyObject {
    func didTapInFilterButton()

}

class AccountsCollapsedHeaderView: UIView {
    
    private var view: UIView?
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterLabel: UILabel!

    weak var delegate: AccountsCollapsedHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.xibSetup()
        self.configureLabels()
        self.setAccessbilityIdentifiers()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.skyGray
        addSubview(view ?? UIView())
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }

    private func configureLabels() {
        self.amountLabel.numberOfLines = 0
        self.amountLabel.adjustsFontSizeToFitWidth = true
        self.amountLabel.minimumScaleFactor = 0.8
    }

    func updateAccountViewModel(_ viewModel: AccountViewModel) {
        self.aliasLabel.text = viewModel.alias
        self.amountLabel.text = viewModel.availableSmallAmountAttributedString
        self.hideFilter()
    }

    func hideFilter() {
        self.filterButton.isHidden = true
        self.filterLabel.isHidden = true
    }

    func showFilter() {
        self.filterButton.isHidden = false
        self.filterLabel.isHidden = false
        self.filterButton.setImage(Assets.image(named: "icnFilter"), for: .normal)
        self.filterButton.setTitle(nil, for: .normal)
        self.filterLabel.configureText(withKey: "generic_button_filters")
        self.filterLabel.textColor = UIColor.darkTorquoise
    }
    
    private func setAccessbilityIdentifiers() {
        self.accessibilityIdentifier = "accountHome_movementheader_view"
        self.filterButton.accessibilityIdentifier = "icn_filter"
        self.aliasLabel.accessibilityIdentifier = "accountHome_movementHeader_aliasLabel"
        self.amountLabel.accessibilityIdentifier = "accountHome_movementHeader_amountLabel"
        self.filterLabel.accessibilityIdentifier = "accountHome_movementHeader_filterLabel"
    }

    @IBAction func didTapInFilterButton(_ sender: Any) {
        self.delegate?.didTapInFilterButton()
    }
}
