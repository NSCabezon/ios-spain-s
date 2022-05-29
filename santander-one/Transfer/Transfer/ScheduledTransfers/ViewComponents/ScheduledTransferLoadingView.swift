//
//  ScheduledTransferLoadingView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 05/02/2020.
//

import Foundation
import CoreFoundationLib
import UI

final class ScheduledTransferLoadingView: UIView {
    
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingTitleLabel: UILabel!
    @IBOutlet weak var loadingSubtitleLabel: UILabel!
    var view: UIView?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Config View
    private func setupView() {
        self.xibSetup()
        self.configureView()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.addSubview(view ?? UIView())
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    private func configureView() {
        self.loadingTitleLabel.text = localized("generic_popup_loadingContent")
        self.loadingTitleLabel.font = .santander(size: 20)
        self.loadingTitleLabel.textColor = .lisboaGray
        
        self.loadingSubtitleLabel.text = localized("loading_label_moment")
        self.loadingSubtitleLabel.font = .santander(size: 14)
        self.loadingSubtitleLabel.textColor = .grafite
        
        self.loadingImageView.setPointsLoader()
    }
    
    // MARK: - Public
    public func stopAnimating() {
        self.loadingImageView.removeLoader()
    }
}
