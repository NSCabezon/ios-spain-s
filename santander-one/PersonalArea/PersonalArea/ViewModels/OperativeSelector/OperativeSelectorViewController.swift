//
//  OperativeSelectorViewController.swift
//  GlobalPosition
//
//  Created by alvola on 08/01/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol OtherOperativesViewControllerDelegate: AnyObject {
    func didSaveChanges(viewModels: [GpOperativesViewModel])
}

class OperativeSelectorViewController: UIViewController {

    @IBOutlet weak var headerBackView: UIView?
    @IBOutlet weak var separationView: UIView?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var topContainerView: UIView?
    @IBOutlet weak var dragContainer: DragContainer!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var viewModelsScrollView: UIScrollView!
    
    private weak var delegate: OtherOperativesViewControllerDelegate?
    var viewModels: [GpOperativesViewModel]?
    var dottedBorderLayer: CAShapeLayer?
    var isEditingEnable: Bool = true

    lazy var topStackView: ActionButtonsStackView<GpOperativesViewModel> = {
        let stackView = ActionButtonsStackView<GpOperativesViewModel>()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    lazy var bottomStackView: ActionButtonsStackView<GpOperativesViewModel> = {
        let stackView = ActionButtonsStackView<GpOperativesViewModel>()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.configureSizeDottedBorder()
        }
    }

    func commonInit() {
        configureView()
        configureTopStackView()
        configureBottomStackView()
        configureDataStackViews()
        configureButtons()
        configureDottedBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationItem.setHidesBackButton(false, animated: false)
    }
    
    func setData(delegate: OtherOperativesViewControllerDelegate, viewModels: [GpOperativesViewModel]) {
        self.delegate = delegate
        self.viewModels = viewModels
    }
    
    // MARK: - Private methods

    private func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "pg_title_modalFrequentOperative")
        )
        builder.setRightActions(.close(action: #selector(didPressClose)))
        builder.build(on: self, with: nil)
    }
    
    private func configureView() {
        view.backgroundColor = UIColor.white
        topContainerView?.backgroundColor = UIColor.darkTurqLight.withAlphaComponent(0.21)
        headerBackView?.backgroundColor = UIColor.bg
        separationView?.backgroundColor = UIColor.mediumSkyGray
    }
    
    private func configureTopStackView() {
        
        topContainerView?.addSubview(topStackView)
        topContainerView?.topAnchor.constraint(equalTo: topStackView.topAnchor, constant: -12).isActive = true
        topContainerView?.leftAnchor.constraint(equalTo: topStackView.leftAnchor, constant: -8).isActive = true
        topContainerView?.rightAnchor.constraint(equalTo: topStackView.rightAnchor, constant: 8).isActive = true
        topContainerView?.bottomAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 8).isActive = true

        topContainerView?.layer.cornerRadius = 4
    }
    
    private func configureBottomStackView() {
        
        containerView?.addSubview(bottomStackView)
        containerView?.topAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -8).isActive = true
        containerView?.leftAnchor.constraint(equalTo: bottomStackView.leftAnchor, constant: -8).isActive = true
        containerView?.rightAnchor.constraint(equalTo: bottomStackView.rightAnchor, constant: 8).isActive = true
        containerView?.bottomAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: 0).isActive = true
    }
    
    private func configureDataStackViews() {
        guard let viewModels = viewModels else { return }
        let topOfViewModels = Array(viewModels[0..<4])
        topStackView.addActions(topOfViewModels, delegate: self)
        topStackView.setDragEnabled(true)
        guard viewModels.count > 4 else { return }
        let restOfViewModels = Array(viewModels[4..<viewModels.count])
        bottomStackView.addActions(restOfViewModels, delegate: self)
        bottomStackView.setDragEnabled(true)
    }
    
    private func configureButtons() {
        
        saveChangesButton.isHidden = false
        
        saveChangesButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        saveChangesButton.setTitle(localized("displayOptions_button_saveChanges"), for: .normal)
        saveChangesButton.setTitleColor(.santanderRed, for: .normal)
        saveChangesButton.layer.borderWidth = 1
        saveChangesButton.layer.cornerRadius = (saveChangesButton?.bounds.height ?? 0.0) / 2.0
        saveChangesButton.layer.borderColor = UIColor.santanderRed.cgColor
        saveChangesButton.backgroundColor = .clear
    }
    
    private func configureDottedBorder() {
        
        let frameSize = topContainerView?.frame.size ?? CGSize.zero

        dottedBorderLayer = CAShapeLayer()
        dottedBorderLayer?.bounds = topContainerView?.bounds ?? CGRect.zero
        dottedBorderLayer?.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        dottedBorderLayer?.fillColor = UIColor.clear.cgColor
        dottedBorderLayer?.strokeColor = UIColor.darkTurqLight.cgColor
        dottedBorderLayer?.lineWidth = 1.0
        dottedBorderLayer?.lineJoin = .round
        dottedBorderLayer?.lineDashPattern = [4, 4]
        dottedBorderLayer?.path = UIBezierPath(roundedRect: topContainerView?.bounds ?? CGRect.zero, cornerRadius: 5).cgPath

        topContainerView?.layer.addSublayer(dottedBorderLayer ?? CAShapeLayer())
                
        dottedBorderLayer?.isHidden = false
    }
    
    private func configureSizeDottedBorder() {
        let frameSize = topContainerView?.frame.size ?? CGSize.zero
        
        dottedBorderLayer?.bounds = topContainerView?.bounds ?? CGRect.zero
        dottedBorderLayer?.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        dottedBorderLayer?.path = UIBezierPath(roundedRect: topContainerView?.bounds ?? CGRect.zero, cornerRadius: 5).cgPath
    }
    
    @objc private func didPressClose() { navigationController?.popViewController(animated: true) }
    
    @IBAction func saveChangesButtonDidPressed(_ sender: Any) {
        guard let viewModels = self.viewModels else { return }
        dragContainer.resetView()
        delegate?.didSaveChanges(viewModels: viewModels)
    }
    
    @objc func appWillEnterForeground() {
        configureEditableStackViews()
    }
    
    func configureEditableStackViews() {
        topStackView.setDragEnabled(true)
        bottomStackView.setDragEnabled(true)
    }
}

extension OperativeSelectorViewController: DragButtonDelegate, DragHelper {}
