//
//  SummaryFooterItem.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 22/05/2020.
//

import UIKit
import UI

class SummaryFooterItem: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    private var view: UIView?
    private var action: (() -> Void)?
    
    convenience init(_ viewModel: SummaryFooterItemViewModel) {
        self.init(frame: .zero)
        self.titleLabel.text = viewModel.title
        self.action = viewModel.action
        self.iconImageView.image = Assets.image(named: viewModel.image)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
    }
}

private extension SummaryFooterItem {
    
    func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view ?? UIView())
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewSelected))
        self.view?.addGestureRecognizer(tap)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    @objc func viewSelected() {
        self.action?()
    }
}

struct SummaryFooterItemViewModel {
    let image: String
    let title: String
    let action: () -> Void
}
