//
//  ComingFeatureVoteView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 21/02/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol ComingFeatureVoteDelegate: AnyObject {
    func didSelectVoteButton(_ viewModel: ComingFeatureVoteViewModel)
}

class ComingFeatureVoteView: XibView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var voteView: UIView!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var voteFeatureButton: UIButton!
    weak var delegate: ComingFeatureVoteDelegate?
    private var viewModel: ComingFeatureVoteViewModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    private func configureView() {
        self.voteView.backgroundColor = .skyGray
        self.voteView.roundCorners(corners: .allCorners, radius: 5)
        self.voteLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.voteLabel.textColor = .darkTorquoise
        self.voteLabel.text = localized("shortly_button_like")
    }
    
    private func setAccessibilityIdentifier() {
        self.voteFeatureButton.accessibilityIdentifier = "voteFeatureButton"
        self.voteLabel.accessibilityIdentifier = "voteLabel"
    }
    
    public func setViewModel(_ viewModel: ComingFeatureVoteViewModel) {
        self.viewModel = viewModel
        self.heartPressed()
    }
    
    private func heartPressed() {
        guard let viewModel = self.viewModel else { return }
        self.heartImageView.image = viewModel.entity.isVoted ? Assets.image(named: "icnHeartSelected") : Assets.image(named: "icnHeart")
        self.voteFeatureButton.isEnabled = !viewModel.entity.isVoted
    }
    
    @IBAction func voteButtonPressed(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        viewModel.entity.isVoted = true
        self.heartPressed()
        self.delegate?.didSelectVoteButton(viewModel)
    }
}
