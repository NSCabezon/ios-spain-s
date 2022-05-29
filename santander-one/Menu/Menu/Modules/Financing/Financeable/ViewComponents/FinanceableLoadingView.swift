//
//  FinanceableLoadingView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 03/07/2020.
//

import Foundation
import UI

final class FinanceableLoadingView: XibView {
    @IBOutlet weak var loadingImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
}

private extension FinanceableLoadingView {
    func setAppearance() {
        self.loadingImageView.setPointsLoader()
    }
}
