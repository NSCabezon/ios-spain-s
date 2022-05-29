//
//  SearchTableViewFooter.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/25/20.
//

import Foundation
import UIKit
import UI

final class SearchTableViewFooter: XibView {
    @IBOutlet weak var loadingImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func startLoading() {
        self.loadingImageView.setPointsLoader()
        self.loadingImageView.startAnimating()
    }
    
    func stopLoading() {
        self.loadingImageView.stopAnimating()
    }
}

private extension SearchTableViewFooter {
    func setAppearance() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.loadingImageView.image = Assets.image(named: "BS_s-loader-1")
    }
}
