//
//  SummaryFooterItem.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 1/13/20.
//

import Operative
import UIKit
import UI

class SummaryFooterItem: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    private var view: UIView?
    private var action: (() -> Void)?
    
    convenience init(_ viewModel: OperativeSummaryStandardFooterItemViewModel) {
        self.init(frame: .zero)
        self.titleLabel.text = viewModel.title
        self.action = viewModel.action
        self.iconImageView.image = viewModel.image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view ?? UIView())
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewSelected))
        self.view?.addGestureRecognizer(tap)
    }
    
    @objc private func viewSelected() {
        self.action?()
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
}
