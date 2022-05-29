//
//  FAQSView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 24/02/2020.
//

import Foundation
import UIKit
import CoreFoundationLib
import UI

protocol FAQSViewDelegate: IdeaViewDelegate {
    func didSelectVirtualAssistant()
}

class FAQSView: XibView {
    @IBOutlet weak var stackViewContainerView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var viewsStackView: UIStackView!
    private let ideaView = IdeaView()
    private let faqsHeaderView = FAQSHeaderView()
    private lazy var otherConsultView: OtherConsultView = {
        let view = OtherConsultView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(otherConsultSelected)))
        return view
    }()
    weak var delegate: FAQSViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    convenience init(faqs: [TransfersFaqsViewModel], _ delegate: FAQSViewDelegate, showVirtualAssistant: Bool) {
        self.init(frame: .zero)
        self.delegate = delegate
        self.viewsStackView.addArrangedSubview(faqsHeaderView)
        self.addFaqsFor(viewModels: faqs)
        self.showOtherConsultView(showVirtualAssistant)
    }
    
    private func addFaqsFor(viewModels: [TransfersFaqsViewModel]) {
        for index in 0..<viewModels.count {
            self.addIdeaView(viewModel: viewModels[index], identifier: "areaFaq\(index)")
        }
    }
    
    private func showOtherConsultView (_ showVirtualAssistant: Bool) {
        if showVirtualAssistant == true {
            self.viewsStackView.addArrangedSubview(self.otherConsultView)
        }
    }
    
    private func addIdeaView(viewModel: TransfersFaqsViewModel, identifier: String) {
        let ideaView = IdeaView(viewModel: viewModel)
        ideaView.accessibilityIdentifier = identifier
        ideaView.delegate = delegate
        self.viewsStackView.addArrangedSubview(ideaView)
    }
    
    private func setupViews() {
        self.stackViewContainerView.drawBorder(cornerRadius: 6, color: UIColor.mediumSkyGray, width: 1)
        self.stackViewContainerView.layer.masksToBounds = true
    }
    
    @objc private func otherConsultSelected() {
        self.delegate?.didSelectVirtualAssistant()
    }
}
