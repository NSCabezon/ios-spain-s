//
//  TricksCourtainView.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 09/07/2020.
//

import Foundation
import CoreFoundationLib

public protocol TipsCurtainViewDelegate: AnyObject {
    func didScrollToIndex(_ index: Int)
}

public final class TricksCourtainView: XibView {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var tipIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tricksCarouselView: TricksCarouselView!
    @IBOutlet weak var curtainScrollView: UIScrollView!
    @IBOutlet weak var euroImageView: UIImageView!
    
    public weak var delegate: TipsCurtainViewDelegate?
    var viewModels: [TrickViewModel]?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    public func setViewModels(_ viewModels: [TrickViewModel]) {
        self.viewModels = viewModels
        self.tricksCarouselView.setTipsViewModels(viewModels)
    }
    
    public func setTricksCarouselTitle(_ localizedKey: String) {
        self.tricksCarouselView.setTitle(localizedKey)
    }
    
    public func setTrickCourtainToolbarTitle(_ localizedKey: String) {
        self.topTitleLabel.text = localized(localizedKey)
    }
    
    public func setViewModelOfIndex(_ index: Int) {
        guard self.viewModels?.count ?? 0 > index else { return }
        if let viewModel = self.viewModels?[index] {
            self.titleLabel.configureText(withKey: viewModel.title, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
            self.descriptionLabel.configureText(withKey: viewModel.description)
            guard let imageUrl = viewModel.imageUrl else { return }
            self.tipIconImageView?.loadImage(urlString: imageUrl)
        }
    }
    
    public func scrollToIndex(_ index: Int) -> Int? {
        guard let count = self.viewModels?.count else { return nil }
        if index < count {
            self.tricksCarouselView.scrollToIndex(index)
            return index
        } else {
            let lastPosition = count - 1
            guard lastPosition > 0 else { return nil}
            self.tricksCarouselView.scrollToIndex(lastPosition)
            return lastPosition
        }
    }
    
    @IBAction func didPressCloseButton(_ sender: UIButton) {
        self.removeFromSuperview()
    }
}

private extension TricksCourtainView {
    func setAppearance() {
        self.tricksCarouselView.setControllerDelegate(self)
        self.setLabels()
        self.setButton()
        self.euroImageView.image = Assets.image(named: "icnTricks")
    }
    
    func setButton() {
        self.closeButton.backgroundColor = .clear
        self.closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
    }
    
    func setLabels() {
        self.topTitleLabel.font = .santander(family: .text, type: .bold, size: 16.0)
        self.topTitleLabel.textColor = .santanderRed
        
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 30.0)
        
        self.descriptionLabel.textColor = .grafite
        self.descriptionLabel.font = .santander(family: .text, type: .regular, size: 18.0)
    }
}

extension TricksCourtainView: TricksCollectionViewControllerDelegate {
    public func didPressTrick(index: Int) {
        self.setViewModelOfIndex(index)
        if let newIndex = self.scrollToIndex(index + 1) {
            self.delegate?.didScrollToIndex(newIndex)
        }
        self.curtainScrollView.layoutIfNeeded()
        self.curtainScrollView.setContentOffset(.zero, animated: true)
    }
}
