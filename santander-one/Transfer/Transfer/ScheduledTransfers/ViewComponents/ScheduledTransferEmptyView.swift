//
//  ScheduledTransferEmptyView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 05/02/2020.
//

import Foundation
import CoreFoundationLib
import UI

class ScheduledTransferEmptyView: UIView {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var view: UIView?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Public setter
    public func setViewModel(_ viewModel: ScheduledTransferEmptyViewModel) {
        self.titleLabel.configureText(withKey: viewModel.titleLabelKey)
        self.descriptionLabel.configureText(withKey: viewModel.descriptionLabelKey)
        self.setAccessibilityIdentifiers(viewModel)
    }
}

private extension ScheduledTransferEmptyView {
    // MARK: - Config View
    func setupView() {
        self.xibSetup()
        self.configureView()
    }
    
    func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.addSubview(view ?? UIView())
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func configureView() {
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont.santander(family: .headline, type: .regular, size: 20)
        self.titleLabel.textColor = .lisboaGray
        self.descriptionLabel.textAlignment = .center
        self.descriptionLabel.font = UIFont.santander(family: .headline, type: .regular, size: 16)
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.lineBreakMode = .byWordWrapping
        self.descriptionLabel.textColor = .brownishGray
        self.backgroundImageView.image = Assets.image(named: "imgLeaves")
        self.backgroundImageView.contentMode = .scaleToFill
    }
    
    func setAccessibilityIdentifiers(_ viewModel: ScheduledTransferEmptyViewModel) {
        self.titleLabel.accessibilityIdentifier = viewModel.titleLabelKey
        self.descriptionLabel.accessibilityIdentifier = viewModel.descriptionLabelKey
        self.backgroundImageView.accessibilityIdentifier = ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersEmptyImage
    }
}
