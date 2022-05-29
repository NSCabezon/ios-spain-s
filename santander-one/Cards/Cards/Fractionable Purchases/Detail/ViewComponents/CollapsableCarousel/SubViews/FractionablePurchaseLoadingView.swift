//
//  FractionablePurchaseLoadingView.swift
//  Cards
//
//  Created by Andres Aguirre Juarez on 4/6/21.
//

import UIKit
import UI

public final class FractionablePurchaseLoadingView: XibView {
    @IBOutlet private weak var loadingImage: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

private extension FractionablePurchaseLoadingView {
    func setupView() {
        backgroundColor = .clear
        setLoadingView()
    }
    
    func setLoadingView() {
        loadingImage.setPointsLoader()
        loadingImage.startAnimating()
    }
}
