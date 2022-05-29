import UIKit
import CoreFoundationLib

protocol FaqItemViewDelegate: AnyObject {
    func didSelectFaqItemView()
    func didExpandAnswer(question: String)
    func didTapAnswerLink(question: String, url: URL)
}

class FaqItemView: XibView, UITextViewDelegate {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionTextView: UITextView!
    @IBOutlet private var titleView: UIView!
    @IBOutlet private var descriptionView: UIView!
    @IBOutlet private var separatorView: UIView!
    @IBOutlet private var imageViewArrow: UIImageView!
    @IBOutlet private var scrollviewHeightConstraint: NSLayoutConstraint!
    weak var delegate: FaqItemViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureViews()
    }

    func configure(_ data: FaqsItemViewModel, separator: Bool) {
        self.titleLabel.configureText(withKey: data.title)
        self.descriptionTextView.configureText(withLocalizedString: localized(data.description), andConfiguration: nil)
        self.separatorView.isHidden = !separator
    }
    
    func close() {
        if !self.descriptionView.isHidden {
            self.imageViewArrow.transform = CGAffineTransform.identity
            self.descriptionView.isHidden = true
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.delegate?.didTapAnswerLink(question: titleLabel.text ?? "", url: URL)
        return true
    }
}

// MARK: - Private Methods

private extension FaqItemView {
    func configureViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.titleView.addGestureRecognizer(tap)
        self.descriptionView.isHidden = true
        self.imageViewArrow.image = Assets.image(named: "icnArrowDownGreen")
        self.titleLabel.textColor = .darkTorquoise
        self.descriptionTextView.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.descriptionTextView.font = .santander(family: .text, type: .light, size: 14)
        self.descriptionTextView.delegate = self
        self.descriptionView.backgroundColor = UIColor.white
        self.titleView.backgroundColor = UIColor.white
        self.separatorView.backgroundColor = UIColor.mediumSkyGray
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer?) {
        self.delegate?.didSelectFaqItemView()
        UIView.animate(withDuration: 0.3, delay: 0, options: .showHideTransitionViews, animations: {
            if self.descriptionView.isHidden {
                self.delegate?.didExpandAnswer(question: self.titleLabel.text ?? "")
                self.imageViewArrow.transform = CGAffineTransform(rotationAngle: .pi)
                self.descriptionView.isHidden = false
            } else {
                self.imageViewArrow.transform = CGAffineTransform.identity
                self.descriptionView.isHidden = true
            }
        })
    }
}
