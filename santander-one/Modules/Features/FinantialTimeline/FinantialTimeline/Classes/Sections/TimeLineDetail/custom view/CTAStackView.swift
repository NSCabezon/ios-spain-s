//
//  CTAStackView.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 02/09/2019.
//

import UIKit

class CTAStackView: UIView {
    @IBOutlet var container: UIView!
    
    @IBOutlet weak var topStack: UIStackView!
    @IBOutlet weak var bottomStack: UIStackView!
    @IBOutlet weak var top1: UIView!
    @IBOutlet weak var top2: UIView!
    @IBOutlet weak var top3: UIView!
    @IBOutlet weak var bottom1: UIView!
    @IBOutlet weak var bottom2: UIView!
    @IBOutlet weak var bottom3: UIView!
    
    var CTAs: [CTAAction]?
    var parent: UIViewController?
    var event: TimeLineEvent?
    var ctaEngine: CTAEngine?
    
    var buttons = [GlobileInitialButton]()
    var topViews = [UIView]()
    var bottomViews = [UIView]()
    let maxHorizontalButtons = 3
    weak var delegate = TimeLine.dependencies.configuration?.native?.timeLineDelegate
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.module?.loadNibNamed(String(describing: CTAStackView.self), owner: self, options: [:])
        prepareViewArray()
        addSubviewWithAutoLayout(container)
        bottomStack.isHidden = true
    }
    
    func prepareViewArray() {
        topViews.append(top1)
        topViews.append(top2)
        topViews.append(top3)
        topViews.forEach({$0.isHidden = true})
        bottomViews.append(bottom1)
        bottomViews.append(bottom2)
        bottomViews.append(bottom3)
        bottomViews.forEach({$0.isHidden = true})
    }
    
    func set(_ CTAs: [CTAAction], with parent: UIViewController, and event: TimeLineEvent, ctaEngine: CTAEngine) {
        self.CTAs = CTAs
        self.parent = parent
        self.event = event
        self.ctaEngine = ctaEngine
        setStacks(for: CTAs)
        appendToStacks(for: CTAs)
    }
    
    func setForPeridicEvent(_ CTAs: [CTAAction], parentViewController: UIViewController, ctaEngine: CTAEngine) {
        self.parent = parentViewController
        self.CTAs = CTAs
        self.ctaEngine = ctaEngine
        setStacks(for: CTAs)
        appendToStacks(for: CTAs)
    }
    
    func setStacks(for CTAs: [CTAAction]) {
        bottomStack.isHidden = CTAs.count <= 3 ? true : false
    }
    
    func appendToStacks(for CTAs: [CTAAction]) {
        for index in 0 ..< CTAs.count {
            guard let button = getButton(for: CTAs[index], index: index), index <= 5 else { return }
            if index < maxHorizontalButtons {
                appendToTop(button: button, in: topViews[index])
            } else {
                appendToBottom(button: button, in: bottomViews[index - maxHorizontalButtons])
            }
        }
    }
    
    // TODO: - CTA
    func getButton(for cta: CTAAction, index: Int) -> GlobileInitialButton? {
        guard let action = cta.structure else { return nil }
        let language = GeneralString().languageKey
        let button = GlobileInitialButton(type: .custom)
        button.iconTintColor = .accesibleSky
        button.setTitleColor(.greyishBrown, for: .normal)
        button.setTitle(action.name[language], for: .normal)
        if cta.structure?.action.type == "REMINDER" && event?.deferredDetails?.alertType != nil {
            button.setTitle(CTAsString().deleteAlert, for: .normal)
        }
        getImg(from: action.icon.URL, for: button)
        setAction(for: button, with: cta, and: index)
        return button
    }
    
    func appendToTop(button: GlobileInitialButton, in view: UIView) {
        removeSantanderButton(from: view)
        view.isHidden = false
        view.addSubviewWithAutoLayout(button)
    }
    
    func appendToBottom(button: GlobileInitialButton, in view: UIView) {
        removeSantanderButton(from: view)
        view.isHidden = false
        view.addSubviewWithAutoLayout(button)
    }
    
    func removeSantanderButton(from view: UIView) {
        view.subviews.forEach { (view) in
            guard let santanderButton = view as? GlobileInitialButton else { return }
            santanderButton.removeFromSuperview()
        }
    }
    
    func setAction(for button: GlobileInitialButton, with cta: CTAAction, and index: Int) {
        cta.event = event
        button.tag = index
        button.addTarget(self, action: #selector(onCTATap), for: .touchUpInside)
    }
    
    func getImg(from url: String, for button: GlobileInitialButton) {
        URLImageView.getImage(from: url) { (img) in
            button.setImage(img, position: .top, withPadding: -12)
            if let imageView = button.imageView {
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
                imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
                imageView.topAnchor.constraint(equalTo: button.topAnchor, constant: 12).isActive = true
            }
        }
    }
    
    @objc func onCTATap(_ sender: GlobileInitialButton) {
        guard let action = CTAs?[sender.tag],
            let thisParent = parent as? TimeLineDetailViewController,
            let engine = ctaEngine else { return }
                
        if action.structure?.action.type == "DEEP_LINK" {
            delegate?.onTimeLineCTATap(from: thisParent, with: action)
        } else {
            engine.onTimeLineCTATap(from: thisParent, with: action)
        }
    }
}

