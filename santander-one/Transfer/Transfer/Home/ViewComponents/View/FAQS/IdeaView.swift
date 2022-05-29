//
//  IdeaView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 24/02/2020.
//

import Foundation
import UIKit
import CoreFoundationLib
import UI

protocol IdeaViewDelegate: AnyObject {
    func didExpandAnswer(question: String)
    func didTapAnswerLink(question: String, url: URL)
}

class IdeaView: XibView, UITextViewDelegate {
    weak var delegate: IdeaViewDelegate?
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var arrowDownImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    convenience init(viewModel: TransfersFaqsViewModel) {
        self.init(frame: .zero)
        self.questionLabel.configureText(withKey: viewModel.question)
        self.answerTextView.configureText(withLocalizedString: localized(viewModel.answer), andConfiguration: nil)
    }
    
    func setup() {
        self.answerTextView?.font = UIFont.santander(family: .text, type: .light, size: 14.0)
        self.answerTextView?.textColor = UIColor.gray
        self.answerTextView?.delegate = self
        self.questionLabel?.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        self.questionLabel?.textColor = UIColor.darkTorquoise
        self.arrowDownImageView.image = Assets.image(named: "icnArrowBlueDown")
        self.separatorView.backgroundColor = UIColor.mediumSkyGray
        self.answerTextView.isHidden = true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.delegate?.didTapAnswerLink(question: questionLabel.text ?? "", url: URL)
        return true
    }
    
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
}
