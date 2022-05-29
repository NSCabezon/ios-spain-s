import UIKit
import UI

protocol DirectLinkPresenter: class {
    var configureLabelLocalized: LocalizedStylableText { get }
    func showDirectLink()
    func hideDirectLink()
    func selectedDirectLink(index: Int)
    func selectedChangeConfiguration()
}

protocol DirectLinkItemProtocol {
    var image: String { get }
    var title: LocalizedStylableText { get }
    var tag: Int { get }
}

class DirectLinkView: UIView {
    @IBOutlet private weak var directLinkView: UIView!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var directLinkContentView: UIView!
    @IBOutlet private weak var directLinkImage: UIImageView!
    @IBOutlet private weak var directLinkBottomSpace: NSLayoutConstraint!
    @IBOutlet private weak var directLinkBackgroundView: UIView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    private lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        return panGesture
    }()
    private lazy var shadowTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(blackViewTapHandler(_:)))
        tap.require(toFail: panGesture)
        return tap
    }()
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(directLinkMenuTapHandler(_:)))
        tap.require(toFail: panGesture)
        return tap
    }()
    private let directLinkClosedDistance: CGFloat = 30
    private var directLinkOpenedDistance: CGFloat {
        var newValue = directLinkClosedDistance
        newValue += directLinkContentView.frame.size.height
        newValue += 38
        return newValue
    }
    private let timeFinish: Double = 0.2
    private let timeAutomatic: Double = 0.3
    weak var delegate: DirectLinkPresenter?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isOpaque = false
        backgroundColor = .clear
        directLinkBackgroundView.backgroundColor = UIColor.sanGreyDark.withAlphaComponent(0.7)
        directLinkBackgroundView.addGestureRecognizer(shadowTapGesture)
        directLinkBackgroundView.isHidden = true
        directLinkBackgroundView.alpha = 0
        directLinkView.addGestureRecognizer(panGesture)
        directLinkView.addGestureRecognizer(tapGesture)
        directLinkView.backgroundColor = .sanRed
        directLinkView.drawShadow(offset: 0, opaticity: 0.57, color: .uiBlack, radius: 6)
        directLinkView.drawBorder(cornerRadius: 24, color: .sanRed, width: 0)
        directLinkBottomSpace.constant = directLinkClosedDistance
        updateDirectLinkImageMenu(open: false)
        updateDirectLinkState(open: false)
        separatorView.backgroundColor = .sanRed
        labelTitle.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 18)))
        directLinkContentView.drawBorder(cornerRadius: 4, color: .uiWhite, width: 0)
    }
    
    func closeDirectLink() {
        updateDirectLinkMenu(time: timeAutomatic, open: false)
    }
    
    func drawItems(title: LocalizedStylableText, items: [DirectLinkItemProtocol]) {
        for item in contentStackView.arrangedSubviews {
            contentStackView.removeArrangedSubview(item)
            item.removeFromSuperview()
        }
        labelTitle.set(localizedStylableText: title)
        var copyItems = items
        while copyItems.count > 0 {
            let stackView = UIStackView()
            stackView.axis = NSLayoutConstraint.Axis.horizontal
            stackView.distribution = UIStackView.Distribution.fillEqually
            stackView.alignment = UIStackView.Alignment.fill
            if let left = copyItems.first, let view = UINib(nibName: "DirectLinkItemView", bundle: .module).instantiate(withOwner: nil, options: nil)[0] as? DirectLinkItemView {
                view.configure(title: left.title, image: Assets.image(named: left.image), isSeparator: false)
                view.tag = left.tag
                let tap = UITapGestureRecognizer(target: self, action: #selector(directLinkItemTapHandler(_:)))
                view.addGestureRecognizer(tap)
                stackView.addArrangedSubview(view)
                copyItems.remove(at: 0)
            }
            if let right = copyItems.first, let view = UINib(nibName: "DirectLinkItemView", bundle: .module).instantiate(withOwner: nil, options: nil)[0] as? DirectLinkItemView {
                view.configure(title: right.title, image: Assets.image(named: right.image), isSeparator: true)
                view.tag = right.tag
                let tap = UITapGestureRecognizer(target: self, action: #selector(directLinkItemTapHandler(_:)))
                view.addGestureRecognizer(tap)
                stackView.addArrangedSubview(view)
                copyItems.remove(at: 0)
            }
            contentStackView.addArrangedSubview(stackView)
            contentStackView.addConstraint(NSLayoutConstraint(item: stackView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 90))
            if copyItems.count > 0 {
                let separator = UIView()
                separator.backgroundColor = .lisboaGray
                contentStackView.addArrangedSubview(separator)
                contentStackView.addConstraint(NSLayoutConstraint(item: separator, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 1))
            }
        }
    }
 
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            break
        case .changed:
            let yTranslation = sender.translation(in: self).y
            sender.setTranslation(.zero, in: self)
            let finalDistance = directLinkBottomSpace.constant - yTranslation
            switch finalDistance {
            case ..<directLinkClosedDistance:
                directLinkBottomSpace.constant = directLinkClosedDistance
                directLinkBackgroundView.isHidden = true
                directLinkBackgroundView.alpha = 0
                updateDirectLinkImageMenu(open: false)
                updateDirectLinkState(open: false)
            case directLinkClosedDistance ... directLinkOpenedDistance:
                directLinkBottomSpace.constant = finalDistance
                directLinkBackgroundView.isHidden = false
                let percentage = ( finalDistance - directLinkClosedDistance ) / ( directLinkOpenedDistance - directLinkClosedDistance )
                directLinkBackgroundView.alpha = percentage
                let open = percentage >= 0.5
                updateDirectLinkImageMenu(open: open)
                updateDirectLinkState(open: open)
            default:
                directLinkBottomSpace.constant = directLinkOpenedDistance
                directLinkBackgroundView.isHidden = false
                directLinkBackgroundView.alpha = 1
                updateDirectLinkImageMenu(open: true)
                updateDirectLinkState(open: true)
            }
            layoutIfNeeded()
        case .cancelled, .ended:
            updateToFinalPosition()
        case .failed, .possible: //Ignoring
            break
        @unknown default:
            break
        }
    }
    
    @objc func blackViewTapHandler(_ sender: UITapGestureRecognizer) {
        closeDirectLinkMenu(time: timeAutomatic)
    }
    
    @objc func directLinkMenuTapHandler(_ sender: UITapGestureRecognizer) {
        if directLinkBottomSpace.constant == directLinkClosedDistance {
            openDirectLinkMenu(time: timeAutomatic)
        } else {
            closeDirectLinkMenu(time: timeAutomatic)
        }
    }
    
    @objc func directLinkItemTapHandler(_ sender: UITapGestureRecognizer) {
        if let tag = sender.view?.tag {
            delegate?.selectedDirectLink(index: tag)
        }
    }
        
    @IBAction func didPressSettingsButton(_ sender: Any) {
        delegate?.selectedChangeConfiguration()
    }
    
    private func updateDirectLinkState(open: Bool) {
        if open {
            delegate?.showDirectLink()
        } else {
            delegate?.hideDirectLink()
        }
    }
    
    private func updateDirectLinkImageMenu(open: Bool) {
        if open {
            directLinkImage.image = Assets.image(named: "icnDoubleArrowDown")
        } else {
            directLinkImage.image = Assets.image(named: "icnDoubleArrowUp")
        }
    }
    
    private func closeDirectLinkMenu(time: Double) {
        updateDirectLinkMenu(time: time, open: false)
    }
    
    private func openDirectLinkMenu(time: Double) {
        updateDirectLinkMenu(time: time, open: true)
    }
    
    private func updateDirectLinkMenu(time: Double, open: Bool) {
        directLinkBackgroundView.isHidden = false
        directLinkBottomSpace.constant = open ? directLinkOpenedDistance: directLinkClosedDistance
        updateDirectLinkState(open: open)
        UIView.animate(withDuration: time, animations: {
            self.directLinkBackgroundView.alpha = open ? 1: 0
            self.updateDirectLinkImageMenu(open: open)
            self.layoutIfNeeded()
        }, completion: { _ in
            if !open {
                self.directLinkBackgroundView.isHidden = true
            }
        })
    }
    
    private func updateToFinalPosition() {
        if ( directLinkBottomSpace.constant - directLinkClosedDistance ) / ( directLinkOpenedDistance - directLinkClosedDistance ) >= 0.5 {
            openDirectLinkMenu(time: timeFinish)
        } else {
            closeDirectLinkMenu(time: timeFinish)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: { !$0.isHidden && $0.point(inside: self.convert(point, to: $0), with: event) })
    }
}
