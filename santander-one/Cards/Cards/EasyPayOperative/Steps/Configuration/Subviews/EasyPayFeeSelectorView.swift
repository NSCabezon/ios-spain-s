//
//  EasyPayFeeSelectorView.swift
//  Cards
//
//  Created by alvola on 03/12/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol EasyPayFeeSelectorViewDelegate: AnyObject {
    func didSelectFeeNumber(_ fee: Int)
    func didTrackFeeNumber()
}

final class EasyPayFeeSelectorView: UIView {
    
    private lazy var substractButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Assets.image(named: "icnSubsRound"), for: .normal)
        button.addTarget(self, action: #selector(subsPressed), for: .touchUpInside)
        container.addSubview(button)
        return button
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Assets.image(named: "icnAddRound"), for: .normal)
        button.addTarget(self, action: #selector(addPressed), for: .touchUpInside)
        container.addSubview(button)
        
        return button
    }()
    
    private lazy var feeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.lineBreakMode = .byClipping
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.textColor = .lisboaGray
        label.font = UIFont.santander(size: 22.0)
        container.addSubview(label)
        return label
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.mediumSkyGray.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 6.0
        view.backgroundColor = .white
        addSubview(view)
        return view
    }()
    
    private let max: Int
    private let min: Int
    private let delay: Double
    private var current: Int {
        didSet {
            guard current >= min && current <= max else { return current = oldValue}
            resetFeeLabel()
            feeLabel.configureText(withLocalizedString: localized("easyPay_label_monthlyPayment",
                                                                  [StringPlaceholder(.value, String(current))]))
            guard oldValue != current else { return }
            startTimer()
        }
    }
    private var timer: Timer?
    
    public weak var delegate: EasyPayFeeSelectorViewDelegate?
    
    init(max: Int, min: Int, delay: Double) {
        self.max = max
        self.min = min
        self.delay = delay
        self.current = 0
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCurrent(_ current: Int) {
        self.current = current
    }
}

private extension EasyPayFeeSelectorView {
    func setup() {
        containerConstraints()
        substractButtonConstraints()
        addButtonConstraints()
        feeLabelConstraints()
        current = min + 1
    }
    
    func containerConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            container.topAnchor.constraint(equalTo: self.topAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 17.0),
            container.heightAnchor.constraint(equalToConstant: 61.0)
        ])
    }
    
    func substractButtonConstraints() {
        NSLayoutConstraint.activate([
            substractButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.0),
            substractButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            substractButton.heightAnchor.constraint(equalToConstant: 38.0),
            substractButton.widthAnchor.constraint(equalToConstant: 38.0)
        ])
    }
    
    func addButtonConstraints() {
        NSLayoutConstraint.activate([
            container.trailingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 13.0),
            addButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 38.0),
            addButton.widthAnchor.constraint(equalToConstant: 38.0)
        ])
    }
    
    func feeLabelConstraints() {
        NSLayoutConstraint.activate([
            feeLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            feeLabel.leadingAnchor.constraint(equalTo: substractButton.trailingAnchor, constant: 20.0),
            feeLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -2.0),
            feeLabel.heightAnchor.constraint(equalToConstant: 37.0)
        ])
    }
    
    @objc func addPressed() {
        current += 1
        self.delegate?.didTrackFeeNumber()
    }
    
    @objc func subsPressed() {
        current -= 1
        self.delegate?.didTrackFeeNumber()
    }
    
    func startTimer() {
        guard delay > 0 else { return }
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            timer.invalidate()
            self.timer = nil
            self.delegate?.didSelectFeeNumber(self.current)
        }
    }
    
    func resetFeeLabel() {
        feeLabel.textColor = .lisboaGray
        feeLabel.font = UIFont.santander(size: 22.0)
        feeLabel.attributedText = nil
    }
}
