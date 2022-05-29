//
//  IdeaView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 24/02/2020.
//

import Foundation
import UIKit
import CoreFoundationLib

public protocol IdeaViewDelegate: AnyObject {
    func didExpandAnswer(question: String)
    func didTapAnswerLink(question: String, url: URL)
}

final class IdeaView: XibView {
    weak var delegate: IdeaViewDelegate?
    @IBOutlet weak private var separatorView: UIView!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var answerTextView: UITextView!
    @IBOutlet weak private var arrowDownImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.setAccessibilityIdentifier()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    convenience init(viewModel: FaqsViewModel) {
        self.init(frame: .zero)
        self.questionLabel.configureText(withKey: viewModel.question)
        self.answerTextView.configureText(withKey: viewModel.answer, andConfiguration: nil)
    }
    
    func setup() {
        self.answerTextView?.font = UIFont.santander(family: .text, type: .light, size: 14.0)
        self.answerTextView?.textColor = UIColor.lisboaGray
        self.answerTextView?.delegate = self
        self.questionLabel?.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        self.questionLabel?.textColor = UIColor.darkTorquoise
        self.arrowDownImageView.image = Assets.image(named: "icnArrowBlueDown")
        self.answerTextView.isHidden = true
        self.separatorView.backgroundColor = UIColor.mediumSkyGray
        self.setAccessibilityIdentifier()
    }
    
}

// MARK: - TextView Delegate

extension IdeaView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.delegate?.didTapAnswerLink(question: questionLabel.text ?? "", url: URL)
        return true
    }
}

// MARK: - Private extension

private extension IdeaView {
    @IBAction func didTapOnIdea(_ sender: Any) {
        if self.answerTextView.isHidden == true {
            self.delegate?.didExpandAnswer(question: questionLabel.text ?? "")
            self.answerTextView.isHidden = false
            self.arrowDownImageView.image = Assets.image(named: "icnArrowBlueUp")
        } else {
            self.answerTextView.isHidden = true
            self.arrowDownImageView.image = Assets.image(named: "icnArrowBlueDown")
        }
    }
    
    func setAccessibilityIdentifier(){
        self.questionLabel.accessibilityIdentifier = IdeaViewComponent.viewLabelQuestion
        self.answerTextView.accessibilityIdentifier = IdeaViewComponent.viewAnswerTextView
    }
}
