//
//  SavingTipsCurtainView.swift
//  Menu
//
//  Created by David Gálvez Alonso on 25/03/2020.
//

import Foundation

import UI
import CoreFoundationLib

protocol SavingTipsCurtainViewDelegate: AnyObject {
    func didScrollToIndex(_ index: Int)
}

class SavingTipsCurtainView: UIDesignableView {
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var topTitleLabel: UILabel!
    
    @IBOutlet private weak var tipIconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var savingTipsView: SavingTipsView!
    @IBOutlet private weak var curtainScrollView: UIScrollView!
    
    @IBOutlet private weak var euroImageView: UIImageView!
    
    weak var delegate: SavingTipsCurtainViewDelegate?
    var savingTipsViewModels: [SavingTipViewModel]?
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        
        savingTipsView.setDelegate(self)
        configureLabels()
        configureButton()
        
        euroImageView.image = Assets.image(named: "icnTricks")
    }
    
    @IBAction func didPressCloseButton(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    func setSavingTips(_ savingTips: [SavingTipViewModel]) {
        savingTipsView.setSavingTips(savingTips)
        savingTipsViewModels = savingTips
    }
    
    func setDataOfIndex(_ index: Int) {
        guard savingTipsViewModels?.count ?? 0 > index else { return }
        
        if let values = savingTipsViewModels?[index] {
            titleLabel.configureText(withKey: values.title,
                                     andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 30.0),
                                                                                          lineHeightMultiple: 0.75))
            descriptionLabel.configureText(withKey: values.description)
            if let imageUrl = values.imageUrl {
                tipIconImageView?.loadImage(urlString: imageUrl)
            }
        }
    }
    
    func scrollToIndex(_ index: Int) -> Int? {
        guard let count = savingTipsViewModels?.count else { return nil }
        
        if index < count {
            savingTipsView.scrollToIndex(index)
            return index
        } else {
            let lastPosition = count - 1
            guard lastPosition > 0 else { return nil}
            savingTipsView.scrollToIndex(lastPosition)
            return lastPosition
        }
    }
}

private extension SavingTipsCurtainView {
    
    func configureButton() {
        closeButton.backgroundColor = .clear
        closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
    }
    
    func configureLabels() {
        topTitleLabel.font = UIFont.santander(family: .text, type: .bold, size: 16.0)
        topTitleLabel.text = localized("toolbar_title_tricksToSave")
        topTitleLabel.textColor = .santanderRed
        
        titleLabel.textColor = UIColor.lisboaGray
        
        descriptionLabel.textColor = .grafite
        descriptionLabel.font = UIFont.santander(family: .text, type: .regular, size: 18.0)
    }
}

extension SavingTipsCurtainView: SavingTipCollectionViewControllerDelegate {
    
    func didPressCell(index: Int) {
        setDataOfIndex(index)

        if let newIndex = scrollToIndex(index + 1) {
            delegate?.didScrollToIndex(newIndex)
        }
        self.curtainScrollView.layoutIfNeeded()
        self.curtainScrollView.setContentOffset(.zero, animated: true)
    }
}
