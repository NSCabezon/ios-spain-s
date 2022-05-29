//
//  PendingRequestView.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 09/07/2020.
//

import Foundation
import CoreFoundationLib

final class PendingRequestView: DesignableView {
    
    @IBOutlet private weak var topShadowView: UIView!
    @IBOutlet private weak var bottomShadowView: UIView!
    @IBOutlet private weak var pendingCollectionView: PendingRequestCollectionView!
    
    public var presenter: PendingSolicitudesPresenterProtocol?
    
    override func commonInit() {
        super.commonInit()
        
        configureView()
        configureShadowViews()
    }
    
    func viewDidLoad(presenter: PendingSolicitudesPresenterProtocol, delegate: PendingRequestCollectionViewDelegate) {
        self.presenter = presenter
        self.presenter?.view = self
        self.pendingCollectionView.pendingRequestDelegate = delegate
        self.presenter?.shouldShow { [weak self] _ in
            self?.presenter?.viewDidLoad()
        }
    }
    
    func configureView() {
        presenter?.view = self
        self.backgroundColor = UIColor.black.withAlphaComponent(0.05)
    }
    
    func configureShadowViews() {
        topShadowView.backgroundColor = .iceBlue
        bottomShadowView.backgroundColor = .iceBlue
        topShadowView.addShadow(location: .bottom, height: 1)
        bottomShadowView.addShadow(location: .top, height: 1)
    }
}

extension PendingRequestView: PendingSolicitudesViewProtocol {
    func observeBecomeActive() {}
    func expandView() {}
    
    func showPendingSolicitudes(_ pendingSolicitudes: [StickyButtonCarrouselViewModelProtocol]) {
        self.pendingCollectionView.setViewModels(pendingSolicitudes)
    }
    
    func hide(completion: (() -> Void)?) {
        self.hideAnimated(completion: completion)
    }
}

private extension PendingRequestView {
    func hideAnimated(completion: (() -> Void)?) {
        completion?()
    }
}
