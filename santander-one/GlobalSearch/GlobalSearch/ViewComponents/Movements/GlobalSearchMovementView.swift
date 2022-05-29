//
//  GlobalSearchMovementView.swift
//  GlobalSearch
//
//  Created by alvola on 23/07/2020.
//

import UI

final class GlobalSearchMovementView: XibView {
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var conceptLabel: UILabel!
    @IBOutlet weak var productAliasLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    
    var onTapAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func setInfo(with viewModel: GlobalSearchMovementViewModel) {
        dateLabel.text = viewModel.dateFormatted.text 
        conceptLabel.attributedText = viewModel.camelCasedConcept
        productAliasLabel.text =  viewModel.camelcasedProductAlias
        amountLabel.attributedText = viewModel.amountAttributedString
        
        if let url =  viewModel.imageUrl {
            productImageView?.loadImage(urlString: url, placeholder: Assets.image(named: "defaultCard"))
        } else {
            productImageView.image = Assets.image(named: "icnSanSmall")
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        dateLabel.font = UIFont.santander(type: .bold, size: 14)
        conceptLabel.font = UIFont.santander(type: .bold, size: 15)
        conceptLabel.textAlignment = .left
        amountLabel.textAlignment  = .right
        productAliasLabel.font = UIFont.santander(type: .light, size: 14)
        amountLabel.font = UIFont.santander(type: .bold, size: 22)
        setColors()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        isUserInteractionEnabled = true
    }
    
    @objc private func tap() {
        onTapAction?()
    }
    
    private func setColors() {
        dateLabel.textColor = UIColor.bostonRed
        separatorView.backgroundColor = UIColor.mediumSkyGray
        conceptLabel.textColor = UIColor.lisboaGray
        productAliasLabel.textColor = UIColor.lisboaGray
        amountLabel.textColor = UIColor.lisboaGray
    }
}
