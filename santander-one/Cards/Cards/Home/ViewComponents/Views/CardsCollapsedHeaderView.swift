//
//  CardsCollapsedHeaderView.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/25/19.
//

import UIKit
import UI
import CoreFoundationLib

protocol CardsCollapsedHeaderViewDelegate: AnyObject {
    func didTapInFilterButton()
}

class CardsCollapsedHeaderView: UIView {
    @IBOutlet weak private var aliasLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var cardIcon: UIImageView!
    @IBOutlet weak private var filterButton: UIButton!
    @IBOutlet weak private var filterLabel: UILabel!
    
    private var view: UIView!
    private var viewModel: CardViewModel?
    weak var delegate: CardsCollapsedHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func updateCardViewModel(_ viewModel: CardViewModel) {
        self.viewModel = viewModel
        self.aliasLabel.text = viewModel.alias
        self.amountLabel.text = viewModel.collapsedBalanceAmount
        self.setCardImage()
        self.hideFilter()
    }
    
    func hideFilter() {
        self.filterButton.isHidden = true
        self.filterLabel.isHidden = true
    }

    func showFilter() {
        self.filterButton.isHidden = false
        self.filterLabel.isHidden = false
        self.configFilterBtn()
        self.configFilterLb()
    }
    
    @IBAction func didTapInFilter(_ sender: Any) {
        delegate?.didTapInFilterButton()
    }
}

private extension CardsCollapsedHeaderView {
    func setupView() {
        self.xibSetup()
        self.setLabels()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        self.view.backgroundColor = UIColor.skyGray
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func setCardImage() {
        guard let imageUrl = self.viewModel?.miniatureImageUrl else {
            self.cardIcon.image = Assets.image(named: "defaultCard")
            return
        }
        _ = self.cardIcon.loadImage(urlString: imageUrl, placeholder: Assets.image(named: "defaultCard"))
    }
    
    func configFilterBtn() {
        self.filterButton.setImage(Assets.image(named: "icnFilter"), for: .normal)
        self.filterButton.setTitle(nil, for: .normal)
        self.filterButton.accessibilityIdentifier = "icn_filter"
    }
    
    func configFilterLb() {
        self.filterLabel.configureText(withKey: "generic_button_filters")
    }
    
    func setLabels() {
        self.aliasLabel.font = UIFont.santander(family: .text, type: .bold, size: 16.0)
        self.aliasLabel.textColor = .lisboaGray
        self.amountLabel.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        self.amountLabel.textColor = .lisboaGray
        self.filterLabel.font = UIFont.santander(family: .text, type: .regular, size: 10.0)
        self.filterLabel.textColor = UIColor.darkTorquoise
    }
}
