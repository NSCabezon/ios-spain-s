//
//  VirtualAssistantHeaderView.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 25/02/2020.
//

import UI
import CoreFoundationLib

class VirtualAssistantHeaderView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var roundedView: UIView!
    @IBOutlet private weak var labelHelp: UILabel!
    @IBOutlet private weak var virtualAssistantImageView: UIImageView!
    weak var delegate: VirtualAssistantSimpleViewProtocol?
    weak var gradientLayer: CAGradientLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: 4.0)
        self.addGradientToView(view: view)
    }
    
    private func commonInit() {
        configureViews()
        configureLabels()
        configureAccessibilityIdentifiers()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    private func configureViews() {
        view?.backgroundColor = .darkTorquoise
        roundedView.layer.cornerRadius = 4
        virtualAssistantImageView.image = Assets.image(named: "icnVirtualAssistant")
    }
    
    private func configureAccessibilityIdentifiers() {
        view?.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterHeaderFaqs.rawValue
        titleLabel.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterTitleVirtualAssistant.rawValue
        roundedView.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterInputVirtualAssistant.rawValue
        labelHelp.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.supportTitleHelpYou.rawValue
    }
    
    func addGradientToView(view: UIView?) {
        guard let view = view else {
            return
        }
        
        self.gradientLayer?.removeFromSuperlayer()
        self.gradientLayer = nil
        
        view.frame = view.bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.lightNavy.cgColor, UIColor.darkTorquoise.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        self.gradientLayer = gradientLayer
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func configureLabels() {
        titleLabel.text = localized("helpCenter_title_virtualAssistant")
        labelHelp.text = localized("support_title_helpYou")
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.delegate?.didTapView(fromOtherConsultations: false)
    }
}
