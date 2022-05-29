//
//  EmitterTableViewHeader.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/21/20.
//

import Foundation

protocol EmitterTableViewHeaderDelegate: AnyObject {
    func searchEmitterBy(emitterCode: String)
}

class EmitterTableViewHeader: UIView {
    private let searchEmittersLabel = SearchEmittersLabel()
    private let searchEmitterView = SearchEmitterView()
    private let frecuentEmittersLabel = SearchEmittersLabel()
    private weak var delegate: EmitterTableViewHeaderDelegate?
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var topSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 23).isActive = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.addSubview(stackView)
        self.stackView.fullFit()
        self.searchEmitterView.setDelegate(self)
        self.stackView.addArrangedSubview(topSeparatorView)
        self.stackView.addArrangedSubview(searchEmittersLabel)
        self.stackView.addArrangedSubview(searchEmitterView)
        self.stackView.addArrangedSubview(frecuentEmittersLabel)
        self.searchEmittersLabel.setLocalizedKey("receiptsAndTaxes_label_stationSearch")
        self.frecuentEmittersLabel.setLocalizedKey("receiptsAndTaxes_label_frequentStations")
    }
    
    func setDelegate(_ delegate: EmitterTableViewHeaderDelegate) {
        self.delegate = delegate
    }
    
    func setFrecuentEmitterHidden() {
        self.frecuentEmittersLabel.removeFromSuperview()
    }
    
    func showFrecuentEmitter() {
        self.stackView.addArrangedSubview(frecuentEmittersLabel)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let parent = superview else { return }
        self.widthAnchor.constraint(equalTo: parent.widthAnchor, multiplier: 1).isActive = true
        self.fullFit()
    }
}

extension EmitterTableViewHeader: SearchEmitterViewDelegate {
    func didSelectClear() {
        self.delegate?.searchEmitterBy(emitterCode: "")
    }
    
    func didSelectSeardch(term: String) {
      self.delegate?.searchEmitterBy(emitterCode: term)
    }
}
