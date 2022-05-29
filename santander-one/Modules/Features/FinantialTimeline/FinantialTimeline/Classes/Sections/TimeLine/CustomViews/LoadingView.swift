//
//  LoadingView.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 24/09/2019.
//

import UIKit

class LoadingView: UIView {
    @IBOutlet var container: UIView!
    
    @IBOutlet weak var loadingContainerView: UIView!
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var loadingTitle: UILabel!
    @IBOutlet weak var loadingDescription: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
       
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
       
    private func commonInit() {
        Bundle.module?.loadNibNamed(String(describing: LoadingView.self), owner: self, options: [:])
        addSubviewWithAutoLayout(container)
        prepareUI()
    }
       
    private func prepareUI() {
        loadingTitle.font = .santanderText(with: 16)
        loadingTitle.textAlignment = .center
        loadingTitle.textColor = .brownishGrey
        loadingDescription.font = .santanderText(with: 14)
        loadingDescription.textAlignment = .center
        loadingDescription.textColor = .brownishGrey
        loadingView.setAnimationImagesWith(prefixName: "BS_", range: 1...154, format: "%03d")
        loadingTitle.text = GeneralString().loading
        loadingDescription.text = GeneralString().loadingLabel
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        loadingView.startAnimating()
    }
    
    func stopAnimatig() {
        loadingView.stopAnimating()
        self.isHidden = true
    }
}
