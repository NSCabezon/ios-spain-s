//
//  DirectDebitActionView.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 08/04/2020.
//

import UIKit
import UI

protocol DirectDebitActionDelegate: AnyObject {
    func didSelectDirectDebit()
    func didSelectOpenUrl(with url: String)
}

class DirectDebitActionView: XibView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    private var viewModel: DirectDebitActionViewModel?
    weak var delegate: DirectDebitActionDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: DirectDebitActionViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
        self.iconImageView.image = Assets.image(named: viewModel.imageName)
    }
    
    @IBAction func directActionPressed(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        switch viewModel.type {
        case .operative:
            self.delegate?.didSelectDirectDebit()
        case let .externalUrl(urlString):
            self.delegate?.didSelectOpenUrl(with: urlString)
        }
    }
}

private extension DirectDebitActionView {
    func setAppearance() {
        self.configLabels()
        self.configContainerView()
        self.configImageViews()
    }
    
    func configLabels() {
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 16.0)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.accessibilityIdentifier = "titleLabel"
        self.descriptionLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        self.descriptionLabel.textColor = .grafite
        self.descriptionLabel.accessibilityIdentifier = "descriptionLabel"
    }
    
    func configContainerView() {
        self.containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.containerView.layer.shadowOpacity = 0.59
        self.containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.containerView.layer.shadowRadius = 0.0
        self.containerView?.drawBorder(cornerRadius: 5, color: UIColor.lightSkyBlue, width: 1)
    }
    
    func configImageViews() {
        self.arrowImageView.image = Assets.image(named: "icnArrowRightGray")
        self.arrowImageView.accessibilityIdentifier = "btnArrow"
        self.iconImageView.clipsToBounds = false
        self.iconImageView.accessibilityIdentifier = "btnIcon"
    }
}
