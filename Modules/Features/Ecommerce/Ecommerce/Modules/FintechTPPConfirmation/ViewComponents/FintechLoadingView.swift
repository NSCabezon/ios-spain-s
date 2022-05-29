//
//  FintechLoadingView.swift
//  Ecommerce
//
//  Created by alvola on 16/04/2021.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

final class FintechLoadingView: FintechTicketContainerView {
    
    private lazy var shadow1View: UIView = {
        let view = newShadow()
        ticketView.addSubview(view)
        return view
    }()
    
    private lazy var dottedLine1View: DottedLineView = {
        let view = DottedLineView()
        view.translatesAutoresizingMaskIntoConstraints = false
        ticketView.addSubview(view)
        view.lineDashPattern = [8, 4]
        view.strokeColor = .brownGray
        return view
    }()
    
    private lazy var shadow2View: UIView = {
        let view = newShadow()
        ticketView.addSubview(view)
        return view
    }()
    
    private lazy var dottedLine2View: DottedLineView = {
        let view = DottedLineView()
        view.translatesAutoresizingMaskIntoConstraints = false
        ticketView.addSubview(view)
        view.lineDashPattern = [8, 4]
        view.strokeColor = .brownGray
        return view
    }()
    
    private lazy var shadow3View: UIView = {
        let view = newShadow()
        ticketView.addSubview(view)
        return view
    }()
    
    private lazy var loadingImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        image.setPointsLoader()
        return image
    }()
    
    private lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.font = UIFont.santander(size: 14.0)
        label.textColor = .lisboaGray
        label.text = localized("ecommerce_label_loadingProcess")
        return label
    }()
    
    private var newShadow: () -> UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightSkyBlue
        view.layer.cornerRadius = 7.0
        return view
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

private extension FintechLoadingView {
    func setup() {
        configureShadow1Constraints()
        configureDottedLine1ViewConstraints()
        configureShadow2Constraints()
        configureDottedLine2ViewConstraints()
        configureShadow3Constraints()
        configureLoadingImageConstraints()
        configureLoadingLabelConstraints()
        setAccesibilityIdentifiers()
    }
    
    func configureShadow1Constraints() {
        NSLayoutConstraint.activate([
            shadow1View.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: 23.0),
            ticketView.trailingAnchor.constraint(equalTo: shadow1View.trailingAnchor, constant: 23.0),
            shadow1View.topAnchor.constraint(equalTo: ticketView.topAnchor, constant: 21.0),
            shadow1View.heightAnchor.constraint(equalToConstant: 64.0)
        ])
    }
    
    func configureDottedLine1ViewConstraints() {
        NSLayoutConstraint.activate([
            dottedLine1View.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: 23.0),
            ticketView.trailingAnchor.constraint(equalTo: dottedLine1View.trailingAnchor, constant: 23.0),
            dottedLine1View.topAnchor.constraint(equalTo: shadow1View.bottomAnchor, constant: 12.0),
            dottedLine1View.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }
    
    func configureShadow2Constraints() {
        NSLayoutConstraint.activate([
            shadow2View.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: 23.0),
            ticketView.trailingAnchor.constraint(equalTo: shadow2View.trailingAnchor, constant: 23.0),
            shadow2View.topAnchor.constraint(equalTo: dottedLine1View.bottomAnchor, constant: 13.0),
            shadow2View.heightAnchor.constraint(equalToConstant: 44.0)
        ])
    }
    
    func configureDottedLine2ViewConstraints() {
        NSLayoutConstraint.activate([
            dottedLine2View.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: 23.0),
            ticketView.trailingAnchor.constraint(equalTo: dottedLine2View.trailingAnchor, constant: 23.0),
            dottedLine2View.topAnchor.constraint(equalTo: shadow2View.bottomAnchor, constant: 13.0),
            dottedLine2View.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }
    
    func configureShadow3Constraints() {
        NSLayoutConstraint.activate([
            shadow3View.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: 23.0),
            ticketView.trailingAnchor.constraint(equalTo: shadow3View.trailingAnchor, constant: 23.0),
            shadow3View.topAnchor.constraint(equalTo: dottedLine2View.bottomAnchor, constant: 13.0),
            shadow3View.heightAnchor.constraint(equalToConstant: 107.0),
            ticketView.bottomAnchor.constraint(equalTo: shadow3View.bottomAnchor, constant: 23.0)
        ])
    }
    
    func configureLoadingImageConstraints() {
        NSLayoutConstraint.activate([
            loadingImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loadingImageView.topAnchor.constraint(equalTo: ticketView.bottomAnchor, constant: 17.0),
            loadingImageView.heightAnchor.constraint(equalToConstant: 11.0)
        ])
    }
    
    func configureLoadingLabelConstraints() {
        NSLayoutConstraint.activate([
            loadingLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: loadingImageView.bottomAnchor, constant: 2.0),
            loadingLabel.heightAnchor.constraint(equalToConstant: 28.0)
        ])
    }
    
    func setAccesibilityIdentifiers() {
        shadow1View.accessibilityIdentifier = AccessibilityFintechLoadingView.emptyLoading
        shadow2View.accessibilityIdentifier = AccessibilityFintechLoadingView.emptyLoading
        shadow3View.accessibilityIdentifier = AccessibilityFintechLoadingView.emptyLoading
        loadingImageView.accessibilityIdentifier = AccessibilityFintechLoadingView.loader
        loadingLabel.accessibilityIdentifier = AccessibilityFintechLoadingView.loadingLabel
    }
}
