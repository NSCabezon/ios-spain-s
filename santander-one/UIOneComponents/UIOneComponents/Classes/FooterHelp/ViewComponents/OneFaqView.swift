//
//  OneFaqView.swift
//  UIOneComponents
//
//  Created by Cristobal Ramos Laina on 23/11/21.
//

import UI
import CoreFoundationLib
import CoreDomain

protocol OneFaqViewDelegate: AnyObject {
    func didTapOnFaq(_ view: OneFaqView)
}

class OneFaqView: XibView {
    
    weak var delegate: OneFaqViewDelegate?
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleTextView: UITextView!
    @IBOutlet private weak var imageView: UIImageView!
    
    private var isOpen = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setView(_ faq: FaqsViewModel) {
        self.titleLabel.configureText(withKey: faq.question)
        self.subtitleTextView.configureText(withLocalizedString: localized(faq.answer), andConfiguration: nil)
    }
    
    func open() {
        if self.subtitleTextView.isHidden {
            UIView.animate(withDuration: 0.2, animations: {
                self.view?.layoutSubviews()
                self.subtitleTextView.isHidden = false
                self.imageView.image = Assets.image(named: "oneIcnArrowRoundedUp")
            })
        } else {
            self.close()
        }
    }
    
    func close() {
        if !self.subtitleTextView.isHidden {
            UIView.animate(withDuration: 0.2, animations: {
                self.subtitleTextView.isHidden = true
                self.imageView.image = Assets.image(named: "oneIcnArrowRoundedDown")
                self.view?.layoutSubviews()
            })
        }
    }
}

private extension OneFaqView {
    func setup() {
        self.titleLabel.font = .typography(fontName: .oneB300Regular)
        self.titleLabel.textColor = .oneDarkTurquoise
        self.subtitleTextView.font = .typography(fontName: .oneB300Regular)
        self.subtitleTextView.textColor = .oneLisboaGray
        self.separatorView.backgroundColor = .oneMediumSkyGray
        self.imageView.image = Assets.image(named: "oneIcnArrowRoundedDown")
        self.subtitleTextView.isHidden = true
        self.setAccesibilityIdentifiers()
    }
    
    @IBAction func didTapOnIdea(_ sender: Any) {
        self.delegate?.didTapOnFaq(self)
    }
    
    func setAccesibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccesibilityOneFooterHelp.oneFooterFaqTitle
        self.subtitleTextView.accessibilityIdentifier = AccesibilityOneFooterHelp.oneFooterFaqSubtitle
        self.imageView.accessibilityIdentifier = AccesibilityOneFooterHelp.oneFooterFaqImage
    }
}
