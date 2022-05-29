//
//  EcommercePurchaseStatusErrorView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 18/3/21.
//

import UIKit
import UI

public final class EcommercePurchaseStatusErrorView: XibView {
    
    @IBOutlet private weak var errorImageView: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension EcommercePurchaseStatusErrorView {
    func setupView() {
        self.backgroundColor = .clear
        self.errorImageView.image = Assets.image(named: "ecommerceImgIllustration")
    }
}
