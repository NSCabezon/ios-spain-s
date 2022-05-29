//
//  FAQSView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 24/02/2020.
//

import Foundation
import UIKit
import CoreFoundationLib

public protocol FAQSViewDelegate: IdeaViewDelegate {
    func didSelectVirtualAssistant()
}

final public class FAQSView: XibView {
    @IBOutlet weak private var stackViewContainerView: UIView!
    @IBOutlet private  var containerView: UIView!
    @IBOutlet weak private var viewsStackView: UIStackView!
    private let ideaView = IdeaView()
    private let faqsHeaderView = FAQSHeaderView()
    private lazy var otherConsultView: OtherConsultView = {
        let view = OtherConsultView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(otherConsultSelected)))
        return view
    }()
    weak public var delegate: FAQSViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    convenience public init(faqs: [FaqsViewModel], _ delegate: FAQSViewDelegate) {
        self.init(frame: .zero)
        self.delegate = delegate
        self.viewsStackView.addArrangedSubview(faqsHeaderView)
        self.addFaqsFor(viewModels: faqs)
        self.viewsStackView.addArrangedSubview(otherConsultView)
    }
    
    public func configureTitle(_ title: String) {
        self.otherConsultView.configureTitle(title)
    }
}

private extension FAQSView {
    func addFaqsFor(viewModels: [FaqsViewModel]) {
        viewModels.enumerated().forEach { (index, viewModel) in
            self.addIdeaView(viewModel: viewModel, identifier: "areaFaq")
        }
    }
    
    func addIdeaView(viewModel: FaqsViewModel, identifier: String) {
        let ideaView = IdeaView(viewModel: viewModel)
        ideaView.delegate = delegate
        ideaView.accessibilityIdentifier = identifier
        self.viewsStackView.addArrangedSubview(ideaView)
    }
    
    func setupViews() {
        self.stackViewContainerView.drawBorder(cornerRadius: 6, color: UIColor.mediumSkyGray, width: 1)
        self.stackViewContainerView.layer.masksToBounds = true
    }
    
    @objc func otherConsultSelected() {
        self.delegate?.didSelectVirtualAssistant()
    }
}
