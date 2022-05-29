//
//  ComingFeatureTableViewCell.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 21/02/2020.
//

import UIKit
import CoreFoundationLib

protocol ComingFeatureCellDelegate: AnyObject {
    func didSelectComingFeatureOffer(_ offer: OfferEntity?)
    func didSelectComingFeatureVote(_ viewModel: ComingFeatureVoteViewModel)
    func didUpdateComingFeatureOfferImageAspectRatio(_ ratio: CGFloat, for viewModel: ComingFeatureViewModel)
}

class ComingFeatureTableViewCell: UITableViewCell {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var separatorView: UIView!
    weak var delegate: ComingFeatureCellDelegate?
    var viewModel: ComingFeatureViewModel?
    lazy var offerView: FeatureOfferView = {
        let view = FeatureOfferView(frame: .zero)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var descriptionView: ComingFeatureDescriptionView = {
        let view = ComingFeatureDescriptionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var voteView: ComingFeatureVoteView = {
        let view = ComingFeatureVoteView(frame: .zero)
        view.delegate = self
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

    func setViewModel(_ viewModel: ComingFeatureViewModel) {
        self.viewModel = viewModel
        self.setupOfferView(from: viewModel)
        self.setupVoteView(from: viewModel)
        self.setupDescriptionView(from: viewModel)
    }
}

private extension ComingFeatureTableViewCell {
    
    func configureView() {
        self.stackView.addArrangedSubview(self.offerView)
        self.stackView.addArrangedSubview(self.descriptionView)
        self.stackView.addArrangedSubview(self.voteView)
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    func setupOfferView(from viewModel: ComingFeatureViewModel) {
        guard let offerViewModel = viewModel.offer else { return self.offerView.isHidden = true }
        self.offerView.isHidden = false
        self.offerView.setViewModel(offerViewModel, state: viewModel.state)
    }
    
    func setupDescriptionView(from viewModel: ComingFeatureViewModel) {
        self.descriptionView.setViewModel(viewModel.description)
    }
    
    func setupVoteView(from viewModel: ComingFeatureViewModel) {
        self.voteView.setViewModel(viewModel.vote)
    }
}

extension ComingFeatureTableViewCell: FeatureOfferDelegate {
    
    func didUpdateImageRatio(_ ratio: CGFloat) {
        self.setNeedsLayout()
        self.layoutSubviews()
        self.layoutIfNeeded()
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didUpdateComingFeatureOfferImageAspectRatio(ratio, for: viewModel)
    }
    
    func didSelectOffer(offer: OfferEntity?) {
        self.delegate?.didSelectComingFeatureOffer(offer)
    }
}

extension ComingFeatureTableViewCell: ComingFeatureVoteDelegate {
    func didSelectVoteButton(_ viewModel: ComingFeatureVoteViewModel) {
        self.delegate?.didSelectComingFeatureVote(viewModel)
    }
}
