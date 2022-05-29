//
//  OpinatorView.swift
//  UI
//
//  Created by Tania Castellano Brasero on 28/7/21.
//

import Foundation
import CoreFoundationLib

public protocol OpinatorViewDelegate: AnyObject {
    func didSelectOpinator(_ opinatorPath: String)
}

public final class OpinatorView: XibView {
    @IBOutlet private weak var feedbackImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    public weak var delegate: OpinatorViewDelegate?
    private var viewModel: OpinatorViewModel?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    public func setViewModel(_ viewModel: OpinatorViewModel) {
        self.viewModel = viewModel
        let localizedConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14),
                                                                 alignment: .left,
                                                                 lineBreakMode: .byTruncatingTail)
        descriptionLabel.textColor = .lisboaGray
        descriptionLabel.configureText(withKey: viewModel.description, andConfiguration: localizedConfig)
    }
}

private extension OpinatorView {
    func setAppearance() {
        view?.backgroundColor = .paleYellow
        view?.drawRoundedAndShadowedNew(radius: 6,
                                        borderColor: .veryLightGray,
                                        widthOffSet: 1,
                                        heightOffSet: 2)
        view?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                          action: #selector(didTapOnOpinator)))
        feedbackImageView.image = Assets.image(named: "imgFeedback")
        arrowImageView.image = Assets.image(named: "icnArrowRight")
        self.setAccesibilityIdentifiers()
    }
    
    @objc func didTapOnOpinator() {
        guard let opinatorSelected = self.viewModel?.opinatorPath else { return }
        delegate?.didSelectOpinator(opinatorSelected)
    }
    
    func setAccesibilityIdentifiers() {
        feedbackImageView.accessibilityIdentifier = AccessibilityOpinator.feedbackImage
        arrowImageView.accessibilityIdentifier = AccessibilityOpinator.icnArrowRight
        descriptionLabel.accessibilityIdentifier = viewModel?.description
        view?.accessibilityIdentifier = viewModel?.accessibilityOfView
    }
}
