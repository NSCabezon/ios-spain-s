//
//  ComingFeaturesHeaderView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 21/02/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol ComingFeaturesHeaderProtocol: AnyObject {
    func didSelectTryFeatures()
    func didSelectedIndexChanged(_ index: Int)
}

class ComingFeaturesHeaderView: XibView {
    @IBOutlet weak var stackView: UIStackView!
    weak var delegate: ComingFeaturesHeaderProtocol?
    var emptyView: ComingFeaturesEmptyView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let parent = superview else { return }
        self.widthAnchor.constraint(equalTo: parent.widthAnchor).isActive = true
        self.fullFit()
    }
    
    private func configureView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addComingSoonView()
        self.addSegmentedControlView()
        self.addEmptyView()
    }
    
    private func addComingSoonView() {
        let comingSoonView = ComingFeaturesComingSoonView(frame: .zero)
        comingSoonView.delegate = self
        self.stackView.addArrangedSubview(comingSoonView)
    }
    
    private func addSegmentedControlView() {
        let segmentedControlView = ComingFeaturesSegmentControlView(frame: .zero)
        segmentedControlView.delegate = self
        self.stackView.addArrangedSubview(segmentedControlView)
    }
    
    private func addEmptyView() {
        let emptyView = ComingFeaturesEmptyView(frame: .zero)
        emptyView.isHidden = true
        self.stackView.addArrangedSubview(emptyView)
        self.emptyView = emptyView
    }
    
    func setEmptyViewTitle(_ title: String) {
        self.emptyView?.setTitle(title: title)
        self.emptyView?.isHidden = false
    }
    
    func hideEmptyView() {
        self.emptyView?.isHidden = true
    }
}

extension ComingFeaturesHeaderView: ComingFeaturesComingSoonViewDelegate {
    func didSelectTryFeatures() {
        self.delegate?.didSelectTryFeatures()
    }
}

extension ComingFeaturesHeaderView: ComingFeaturesSegmentControlViewDelegate {
    func didSelectedIndexChanged(_ index: Int) {
        self.delegate?.didSelectedIndexChanged(index)
    }
}
