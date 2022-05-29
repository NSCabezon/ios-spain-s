//
//  OneFooterHelpView.swift
//  UIOneComponents
//
//  Created by Cristobal Ramos Laina on 23/11/21.
//

import UI
import CoreFoundationLib
import CoreDomain

public protocol OneFooterHelpViewDelegate: AnyObject {
    func didSelectTip(_ offer: OfferRepresentable?)
    func didSelectVirtualAssistant()
}

public class OneFooterHelpView: XibView {
    
    @IBOutlet private weak var gradientView: OneGradientView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var containerView: OneFooterHelpContainerView!
    
    public weak var delegate: OneFooterHelpViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    public func setFooterHelp(_ viewModel: OneFooterHelpViewModel) {
        self.containerView.addViews(viewModel)
        self.containerView.delegate = self
        self.gradientView.setupType(.oneTurquoiseGradient())
    }
}

private extension OneFooterHelpView {
    
    func setup() {
        self.titleLabel.font = .typography(fontName: .oneH200Bold)
        self.titleLabel.textColor = .oneWhite
        self.titleLabel.text = localized("faqs_title_anyQuestions")
        self.view?.accessibilityIdentifier = AccesibilityOneFooterHelp.oneFooterHelpView
        self.titleLabel.accessibilityIdentifier = AccesibilityOneFooterHelp.oneFooterHelpTitle
    }
}

extension OneFooterHelpView: OneFooterHelpContainerViewDelegate {
    func didSelectVirtualAssistant() {
        self.delegate?.didSelectVirtualAssistant()
    }
    
    func didSelectTip(_ offer: OfferRepresentable?) {
        self.delegate?.didSelectTip(offer)
    }
}
