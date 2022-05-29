//
//  CardBlockReasonsView.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 27/5/21.
//

import UI
import CoreFoundationLib

enum CardBlockReason {
    case lost
    case stolen
    case cardDeterioration
}

protocol CardBlockReasonsViewDelegate: AnyObject {
    func newSelectedView(option: CardBlockReasonOption?)
}

struct CardBlockReasonOption {
    let option: CardBlockReason
    var reason: String
}

final class CardBlockReasonsView: XibView {
    @IBOutlet private weak var blockCardImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    private var reasonViews = [OptionWithTextFieldView: CardBlockReasonOption]()
    private weak var delegate: CardBlockReasonsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setup(delegate: CardBlockReasonsViewDelegate, showCommentReason: Bool) {
        self.delegate = delegate
        let reasons: [CardBlockReason] = [.lost, .stolen]
        reasons.forEach { option in
            let view = OptionWithTextFieldView()
            let viewModel = self.createViewModelFor(option, showCommentReason: showCommentReason)
            view.setViewModel(viewModel)
            view.setDelegate(self)
            self.stackView.addArrangedSubview(view)
            self.reasonViews[view] = CardBlockReasonOption(option: option, reason: "")
        }
    }
}

private extension CardBlockReasonsView {
    func setAppearance() {
        self.setupLabels()
        self.setupImages()
    }
    
    func setupLabels() {
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.text = localized("blockCard_text_wearStole")
        self.bottomLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.bottomLabel.textColor = .mediumSanGray
        self.bottomLabel.text = localized("blockCard_text_info")
    }
    
    func setupImages() {
        self.blockCardImageView.tintColor = .lisboaGray
        self.blockCardImageView.image = Assets.image(named: "icnBlockCard")?.withRenderingMode(.alwaysTemplate)
    }
    
    func createViewModelFor(_ reason: CardBlockReason, showCommentReason: Bool) -> OptionWithTextFieldViewModel {
        var expandableViewModel: OptionWithTextFieldReasonViewModel?
        if showCommentReason {
            expandableViewModel = OptionWithTextFieldReasonViewModel(description: localized("blockCard_label_comment"), placeholderText: localized("blockCard_hint_commentary"))
        }
        switch reason {
        case .lost:
            return OptionWithTextFieldViewModel(title: localized("blockCard_input_loss"), subtitle: localized("blockCard_text_cardWillLocked"), expandable: expandableViewModel)
        case .stolen:
            return OptionWithTextFieldViewModel(title: localized("blockCard_input_stole"), subtitle: localized("blockCard_text_cardWillLocked"), expandable: expandableViewModel)
        case .cardDeterioration:
            return OptionWithTextFieldViewModel(title: localized("blockCard_input_wear"), subtitle: localized("blockCard_text_continueUsingCard"), expandable: expandableViewModel)
        }
    }
}

extension CardBlockReasonsView: OptionWithTextFieldViewDelegate {
    func didTapOnView(_ view: OptionWithTextFieldView) {
        self.reasonViews.forEach { key, _ in
            key.deselectView()
        }
        view.selectView()
        self.delegate?.newSelectedView(option: reasonViews[view])
    }
    
    func textFieldUpdated(text: String, view: OptionWithTextFieldView) {
        self.reasonViews[view]?.reason = text
        self.delegate?.newSelectedView(option: self.reasonViews[view])
    }
}
