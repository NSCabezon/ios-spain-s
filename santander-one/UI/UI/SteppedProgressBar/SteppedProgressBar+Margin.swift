//
//  SteppedProgressBar+Margin.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 16/07/2020.
//

import Foundation

extension SteppedProgressBar {
    
    class Margin: UIView {
        
        private let filledView: UIView
        private lazy var filledWidth: NSLayoutConstraint = {
            return self.filledView.widthAnchor.constraint(equalTo: self.widthAnchor)
        }()
        private lazy var zeroWidth: NSLayoutConstraint = {
            return self.filledView.widthAnchor.constraint(equalToConstant: 0)
        }()
        
        private var progressBarType: ProgressBarType
        
        init(color: UIColor, progressBarType: ProgressBarType) {
            self.filledView = UIView()
            self.filledView.translatesAutoresizingMaskIntoConstraints = false
            self.filledView.backgroundColor = color
            self.progressBarType = progressBarType
            super.init(frame: .zero)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        func fill(animated: Bool, completion: @escaping () -> Void) {
            self.zeroWidth.isActive = false
            self.filledWidth.isActive = true
            guard animated == true else {
                self.layoutSubviews()
                return completion()
            }
            self.animate(completion: completion)
        }
        
        func unfill(animated: Bool, completion: @escaping () -> Void) {
            self.filledWidth.isActive = false
            self.zeroWidth.isActive = true
            guard animated == true else {
                self.layoutSubviews()
                return completion()
            }
            self.animate(completion: completion)
        }
        
        func fillContinuous(animated: Bool, completion: @escaping () -> Void) {
            guard animated else {
                self.layoutSubviews()
                return completion()
            }
            self.animate(completion: completion)
        }
        
        private func animate(completion: @escaping () -> Void) {
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.layoutSubviews()
                },
                completion: { finished in
                    guard finished else { return }
                    completion()
                }
            )
        }
        
        private func setup() {
            self.addFilledView()
        }
        
        private func addFilledView() {
            self.addSubview(self.filledView)
            self.filledView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            self.filledView.topAnchor.constraint(equalTo: self.topAnchor, constant: progressBarType.segmentMargin ).isActive = true
            self.filledView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(progressBarType.segmentMargin )).isActive = true
            self.filledWidth.isActive = true
        }
    }
}
