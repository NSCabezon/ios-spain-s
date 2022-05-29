//
//  SteppedProgressBar+Step.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 16/07/2020.
//

import UIKit

extension SteppedProgressBar {
    
    struct StepConfiguration {
        let index: Int
        let unfilledColor: UIColor
        let filledColor: UIColor
    }
    
    class Step: UIView {
        enum StepState {
            case selected
            case unselected
            case done
        }
        
        private let stepView: UIView = {
            let view = UIView()
            view.layer.cornerRadius = Contants.stepHeight / 2
            view.layer.borderWidth = 2.0
            view.layer.backgroundColor = UIColor.white.cgColor
            return view
        }()
        private let numberLabel: UILabel = {
            let stepLabel = UILabel()
            stepLabel.textAlignment = .center
            stepLabel.font = .santander(family: .text, type: .bold, size: 10)
            stepLabel.isAccessibilityElement = false
            return stepLabel
        }()
        private let tickView: UIView = {
            let view = UIView()
            view.layer.cornerRadius = Contants.stepHeight / 2
            view.layer.backgroundColor = UIColor.bostonRed.cgColor
            return view
        }()
        private let tickImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = Contants.stepHeight / 2
            imageView.layer.backgroundColor = UIColor.bostonRed.cgColor
            imageView.image = Assets.image(named: "icnTickWhite")
            return imageView
        }()
        private var state: StepState = .unselected
        private var configuration: StepConfiguration?

        init(configuration: StepConfiguration) {
            super.init(frame: .zero)
            self.configuration = configuration
            self.setupView()
            self.setStep(configuration.index)
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        override func layoutSubviews() {
            self.layer.cornerRadius = self.frame.size.width/2
            self.layer.masksToBounds = true
        }
        
        func setState(_ state: StepState) {
            self.state = state
            self.setupState()
        }
        
        private func setupState() {
            switch self.state {
            case .done:
                self.setStepDone()
            case .selected:
                self.setStepSelected()
            case .unselected:
                self.setStepUnselected()
            }
        }
        
        private func setupView() {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundColor = .clear
            self.widthAnchor.constraint(equalToConstant: Contants.stepHeight).isActive = true
            self.heightAnchor.constraint(equalToConstant: Contants.stepHeight).isActive = true
            self.addStepView()
            self.addTickView()
        }
        
        private func addStepView() {
            self.addSubview(self.stepView)
            self.stepView.fullFit()
            self.stepView.addSubview(self.numberLabel)
            self.numberLabel.fullFit(topMargin: 0, bottomMargin: 2, leftMargin: 0, rightMargin: 0)
        }
        
        private func addTickView() {
            self.addSubview(self.tickView)
            self.tickView.fullFit()
            self.tickView.addSubview(self.tickImageView)
            self.tickImageView.fullFit(topMargin: 3, bottomMargin: 3, leftMargin: 3, rightMargin: 3)
            self.tickImageView.contentMode = .scaleAspectFit
        }
        
        private func setStep(_ step: Int) {
            self.numberLabel.text = "\(step)"
            self.setupState()
        }
        
        private func setStepDone() {
            self.tickView.isHidden = false
            self.stepView.isHidden = true
        }
        
        private func setStepSelected() {
            guard let configuration = self.configuration else { return }
            self.stepView.layer.borderColor = configuration.filledColor.cgColor
            self.numberLabel.textColor = configuration.filledColor
            self.tickView.isHidden = true
            self.stepView.isHidden = false
        }
        
        private func setStepUnselected() {
            guard let configuration = self.configuration else { return }
            self.stepView.layer.borderColor = configuration.unfilledColor.cgColor
            self.numberLabel.textColor = .grafite
            self.tickView.isHidden = true
            self.stepView.isHidden = false
        }
    }
}
