//
//  VirtualAssistantExpandableView.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 25/02/2020.
//

import UI
import CoreFoundationLib

protocol VirtualAssistantExpandableViewDelegate: AnyObject {
    func didSelectView()
    func didExpandAnswer(question: String)
    func didTapAnswerLink(question: String, url: URL)
}

class VirtualAssistantExpandableView: XibView, UITextViewDelegate {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var titleView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageViewArrow: UIImageView!
    @IBOutlet private weak var descriptionView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet private weak var descriptionTextView: UITextView!
    
    weak var delegate: VirtualAssistantExpandableViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureViews()
    }
    
    private func configureViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        titleView.addGestureRecognizer(tap)
        descriptionView.isHidden = true
        imageViewArrow.image = Assets.image(named: "icnArrowDownGr")
    }
    
    public func configureLabels(_ faq: HelpCenterFaqItemViewModel) {
        titleLabel.textColor = .darkTorquoise
        titleLabel.configureText(withLocalizedString: faq.question,
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14.0)))
        descriptionTextView.delegate = self
        descriptionTextView.textColor = .lisboaGray
        descriptionTextView.font = UIFont.santander(family: .text, type: .light, size: 14.0)
        descriptionTextView.configureText(withLocalizedString: faq.answer, andConfiguration: nil)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer?) {
        delegate?.didSelectView()
        UIView.animate(withDuration: 0.3, delay: 0, options: .showHideTransitionViews, animations: {
            if self.descriptionView.isHidden {
                self.delegate?.didExpandAnswer(question: self.titleLabel.text ?? "")
                self.imageViewArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                self.descriptionView.isHidden = false
            } else {
                self.imageViewArrow.transform = CGAffineTransform.identity
                self.descriptionView.isHidden = true
            }
        }) 
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.delegate?.didTapAnswerLink(question: titleLabel.text ?? "", url: URL)
        return true
    }
}
