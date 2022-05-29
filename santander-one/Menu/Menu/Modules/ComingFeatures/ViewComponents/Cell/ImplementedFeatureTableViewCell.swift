//
//  ImplementedFeatureTableViewCell.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 26/02/2020.
//

import UIKit
import CoreFoundationLib

protocol ImplementedFeatureCellDelegate: AnyObject {
    func didSelectImplementedFeatureOffer(_ offer: OfferEntity?)
    func didUpdateImplementedFeatureOfferImageAspectRatio(_ ratio: CGFloat, for viewModel: ImplementedFeatureViewModel)
}

class ImplementedFeatureTableViewCell: UITableViewCell {

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    weak var delegate: ImplementedFeatureCellDelegate?
    private var viewModel: ImplementedFeatureViewModel?
    lazy var offerView: FeatureOfferView = {
        let view = FeatureOfferView(frame: .zero)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var descriptionView: ImplementedFeatureDescriptionView = {
        let view = ImplementedFeatureDescriptionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.offerView.isHidden = true
        self.offerView.prepareForReuse()
    }

    func setViewModel(_ viewModel: ImplementedFeatureViewModel) {
        self.viewModel = viewModel
        self.setupOfferView(from: viewModel)
        self.setupDescriptionView(from: viewModel)
    }
}

private extension ImplementedFeatureTableViewCell {
    
    func configureView() {
        self.stackView.addArrangedSubview(self.offerView)
        self.stackView.addArrangedSubview(self.descriptionView)
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    func setupOfferView(from viewModel: ImplementedFeatureViewModel) {
        guard let offerViewModel = viewModel.offer else { return self.offerView.isHidden = true }
        self.offerView.isHidden = false
        self.offerView.setViewModel(offerViewModel, state: viewModel.state)
    }
    
    func setupDescriptionView(from viewModel: ImplementedFeatureViewModel) {
        self.descriptionView.setViewModel(viewModel.description)
    }
}

extension ImplementedFeatureTableViewCell: FeatureOfferDelegate {
    
    func didUpdateImageRatio(_ ratio: CGFloat) {
        self.setNeedsLayout()
        self.layoutSubviews()
        self.layoutIfNeeded()
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didUpdateImplementedFeatureOfferImageAspectRatio(ratio, for: viewModel)
    }
    
    func didSelectOffer(offer: OfferEntity?) {
        self.delegate?.didSelectImplementedFeatureOffer(offer)
    }
}
