//
//  PageLoadingView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/17/20.
//

import Foundation
import UIKit

public final class PageLoadingView: XibView {
    @IBOutlet weak var loadingImageView: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    public func startLoading() {
        self.loadingImageView.setPointsLoader()
        self.loadingImageView.startAnimating()
    }
    
    public func stopLoading() {
        self.loadingImageView.stopAnimating()
    }
}

private extension PageLoadingView {
    func setAppearance() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.loadingImageView.image = Assets.image(named: "BS_s-loader-1")
    }
}
