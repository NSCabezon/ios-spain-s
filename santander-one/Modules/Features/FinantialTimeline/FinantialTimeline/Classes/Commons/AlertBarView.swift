//
//  AlertView.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 30/09/2019.
//

import UIKit
import UI

protocol AlertBarViewDelegate: AnyObject {
    func onClosePressed()
    func onActionPressed()
}

class AlertBarView: UIView {
    
    weak var alertBarDelegate: AlertBarViewDelegate?
    let parentViewController: UIViewController
    
    var yPositionConstraint = NSLayoutConstraint()
    
    let closeAlertBarButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 58, height: 58))
        let image = UIImage(fromModuleWithName: "SYS022")
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        return button
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let actionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .santander(family: .text, type: .bold, size: 15)
        label.textAlignment = .left
        label.textColor = .turquoise
        label.numberOfLines = 1
        return label
    }()
    
    fileprivate lazy var mediumBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    init(from viewController: UIViewController) {
        self.parentViewController = viewController
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 58))
        addSubviews()
        configConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public override func layoutSubviews() {
        super.layoutSubviews()
        setupViews()
    }
    
    func configConstraints() {
        parentViewController.view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: parentViewController.view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: parentViewController.view.trailingAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 58).isActive = true
        
        yPositionConstraint = topAnchor.constraint(equalTo: parentViewController.view.topAnchor, constant: 0)
    
        yPositionConstraint.isActive = true
    }
    
    private func addSubviews() {
        self.addSubview(mediumBackground)
        self.addSubview(closeAlertBarButton)
        self.addSubview(messageLabel)
        self.addSubview(actionLabel)
        
        setupLayout()
        
        self.isHidden = true
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            closeAlertBarButton.topAnchor.constraint(equalTo: topAnchor),
            closeAlertBarButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            closeAlertBarButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            closeAlertBarButton.heightAnchor.constraint(equalToConstant: 36.0),
            closeAlertBarButton.widthAnchor.constraint(equalTo: closeAlertBarButton.heightAnchor)
            ])
        
        NSLayoutConstraint.activate([
            actionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            actionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18)
            ])
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: closeAlertBarButton.trailingAnchor, constant: 0),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionLabel.leadingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        actionLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)

        mediumBackground.anchor(left: leftAnchor, top: topAnchor, right: rightAnchor, height: 57.0)
        
    }
    
    private func setupViews() {
        backgroundColor = .white
        closeAlertBarButton.addTarget(self, action: #selector(hide), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionPressed))
        actionLabel.isUserInteractionEnabled = true
        actionLabel.addGestureRecognizer(tap)
        
    }
    @objc func hide() {
        hideAlertBar()
        alertBarDelegate?.onClosePressed()
    }
    
    @objc func actionPressed() {
        hideAlertBar()
        alertBarDelegate?.onActionPressed()
    }
    
    private var hideTask: DispatchWorkItem?
    
    /// Show alertBar with message and label.
    ///
    /// - Parameters:
    ///   - messageHTML: main message of the alert. Allow HTML text to show important words in red and bold style
    ///   - actionText: Clickable text to perform and action.
    func showAlertBar(messageHTML: String) {
        
        guard let attr = try? NSMutableAttributedString(htmlString: messageHTML, font: .santander(family: .text, type: .light, size: 15), useDocumentFontSize: false) else { return }
        messageLabel.attributedText = attr
    
        self.isHidden = false
        
        guard parentViewController.navigationController != nil else {
            let navBar = parentViewController.navigationController?.navigationBar.frame.height
            let statusBar = UIApplication.shared.statusBarFrame.height
            self.animateView(with: ((navBar ?? 0) + statusBar))
            return
        }
        
        animateView(with: 0)

    }
    
    func animateView(with height: CGFloat) {
        yPositionConstraint.constant = height
        
        hideTask = DispatchWorkItem { self.hideAlertBar() }
        
        UIView.animate(withDuration: 0.275, animations: {
            self.parentViewController.view.layoutIfNeeded()
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.000, execute: self.hideTask!)
            
        })

    }
    
    
    /// Hide alertBar
    func hideAlertBar() {
        
        yPositionConstraint.constant = -58
        UIView.animate(withDuration: 0.275, animations: {
            self.parentViewController.view.layoutIfNeeded()
        }, completion: { _ in
            self.isHidden = true
            self.hideTask?.cancel()            
        })
    }
    
}

