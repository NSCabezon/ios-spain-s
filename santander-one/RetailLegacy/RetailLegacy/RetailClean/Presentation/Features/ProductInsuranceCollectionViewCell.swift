//
//  ProductInsuranceCollectionViewCell.swift
//  RetailClean
//
//  Created by Francisco del Real Escudero on 05/06/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//

import UI

class ProductInsuranceCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var insuranceFamilyLabel: UILabel!
    @IBOutlet weak var insuranceNameLabel: UILabel!
    @IBOutlet weak var policyLabel: UILabel!
    
    @IBOutlet weak var shareButton: CoachmarkUIButton!
    @IBOutlet weak var bigAmountLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var attributeNameLabel: UILabel!
    @IBOutlet weak var attributeValueLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    
    weak var shareDelegate: ShareInfoHandler?
    
    var insuranceFamily: String? {
        get {
            return insuranceFamilyLabel.text
        }
        set {
            insuranceFamilyLabel.text = newValue
            insuranceFamilyLabel.isHidden = newValue == nil
        }
    }
    
    var insuranceName: String? {
        get {
            return insuranceNameLabel.text
        }
        set {
            insuranceNameLabel.text = newValue
            insuranceNameLabel.isHidden = newValue == nil
        }
    }
    
    var policy: String? {
        get {
            return policyLabel.text
        }
        set {
            policyLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configureView()
    }
    
    private func configureView() {
        insuranceFamilyLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14), textAlignment: .left))
        insuranceNameLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14), textAlignment: .left))
        policyLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14), textAlignment: .left))
        bigAmountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 37), textAlignment: .left))
        totalAmountLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoSemibold(size: 14), textAlignment: .left))
        attributeNameLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 14), textAlignment: .left))
        attributeValueLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14), textAlignment: .left))
        shareButton.setImage(Assets.image(named: "icShareIban"), for: .normal)
    }
    
    @IBAction func didTouchShareButton(_ sender: UIButton) {
        shareDelegate?.shareInfoWithCode(sender.tag)
    }
    
}

extension ProductInsuranceCollectionViewCell: ConfigurableCell {
    
    func configure(data: ProductInsuranceHeader) {
        insuranceFamily = data.extraInfo?.insuranceFamily
        insuranceName = data.extraInfo?.insuranceName
        policy = data.policy
        shareDelegate = data.shareDelegate
        shareButton.tag = data.copyTag ?? 0
        configureInfo(data.extraInfo?.info)
        data.updateHeaderView = { [weak self] in
            self?.configureExtraInfo(data)
        }
        
        separator.backgroundColor = data.isBigSeparator ? .sanGreyLight : .lisboaGray
        if separatorHeightConstraint != nil {
            separatorHeightConstraint.constant = data.isBigSeparator ? 6.0 : 1.0
        }
    }
    
    private func configureInfo(_ info: InsuranceBottomInfo?) {
        switch info {
        case .savings(let amount)?:
            bigAmountLabel.text = amount.getFormattedAmountUI()
            bigAmountLabel.isHidden = false
            totalAmountLabel.isHidden = false
        case .protection(let attributeTitle, let attributeValue)?:
            attributeNameLabel.text = attributeTitle
            attributeValueLabel.text = attributeValue
            attributeNameLabel.isHidden = false
            attributeValueLabel.isHidden = false
        case .none?:
            bigAmountLabel.isHidden = true
            totalAmountLabel.isHidden = true
            attributeNameLabel.isHidden = true
            attributeValueLabel.isHidden = true
        case .none:
            bigAmountLabel.isHidden = true
            totalAmountLabel.isHidden = true
            attributeNameLabel.isHidden = true
            attributeValueLabel.isHidden = true
        }
    }
    
    func configureExtraInfo(_ data: ProductInsuranceHeader) {
        insuranceFamily = data.extraInfo?.insuranceFamily
        insuranceName = data.extraInfo?.insuranceName
        configureInfo(data.extraInfo?.info)
    }
}
