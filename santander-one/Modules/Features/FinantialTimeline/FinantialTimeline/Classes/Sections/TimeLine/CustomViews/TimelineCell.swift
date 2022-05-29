//
//  TimelineCell.swift
//  FinantialTimeline
//
//  Created by Antonio Muñoz Nieto on 28/06/2019.
//

import Foundation
import UIKit
import UI
import CoreFoundationLib

protocol TimeLineCellDelegate: AnyObject {
    func trackLink(with url: URL)
}

class TimeLineCell: UITableViewCell {
    @IBOutlet weak var shadowConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowView: UIImageView!
    @IBOutlet weak var invoicesContentView: UIView!
    @IBOutlet weak var shortDescriptionTextView: OnlyAdmitsClickOnLinksTextView!
    @IBOutlet weak var logo: URLImageView!
    @IBOutlet weak var icon: MerchantLetterIcon!
    weak var delegate: TimeLineCellDelegate?
    var strategy: TLStrategy?
    let iconLabel = UILabel()
    let merchantColors = TimelineCellMerchantColors.shared
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let strategy = self.strategy, !strategy.isList() else { return }
        self.drawLine(from: CGPoint(x: 0, y: self.invoicesContentView.frame.size.height - 2), size: CGSize(width: self.invoicesContentView.frame.size.width, height: 2))
        self.drawLine(from: CGPoint(x: self.invoicesContentView.frame.size.width - 2, y: 0), size: CGSize(width: 2, height: self.invoicesContentView.frame.size.height))
    }
    
    func drawBorder() {
        invoicesContentView.layer.borderWidth = 1
        invoicesContentView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        invoicesContentView.layer.cornerRadius = 2
    }
    
    func drawShadow() {
        invoicesContentView.layer.shadowOpacity = 0.6
        invoicesContentView.layer.shadowColor = UIColor.LightSanGray.cgColor
        invoicesContentView.layer.shadowRadius = 2
        invoicesContentView.layer.shadowOffset = .init(width: 1, height: 3)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    func configureView() {
        icon.addSubview(iconLabel)
        selectionStyle = .none
        shortDescriptionTextView.delegate = self
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        DispatchQueue.main.async {
            guard let isList = self.strategy?.isList(), isList == true else {
                return self.invoicesContentView.backgroundColor = .white
            }
            let color: UIColor = highlighted ? .sky30 : .white
            self.invoicesContentView.backgroundColor = color
        }
    }
    
    func drawLine(from origin: CGPoint, size: CGSize) {
        let border = CALayer()
        border.backgroundColor = UIColor.iceBlue.cgColor
        border.frame = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
        self.invoicesContentView.layer.addSublayer(border)
    }
    
    func setup(with event: TimeLineEvent, textsEngine: TextsEngine, strategy: TLStrategy?, delegate: TimeLineCellDelegate?) {
        self.strategy = strategy
        self.delegate = delegate
        merchantColors.showIconWith(event: event) ? setupIcon(event: event) : setupLogo(event: event)
        switch event.transaction.type {
        case .personalEvent, .customEvent:
            logo.tintColor = .lightGreyBlue
        default:
            logo.tintColor = .BostonRedLight
        }
        if event.identifier == "" {
            setAsNoEventToday(event)
            return
        }
        shortDescriptionTextView.font = .santanderText(with: 14)
        if textsEngine.getEventIsPast(for: event) {
            shortDescriptionTextView.textColor = .mediumSanGray
        } else {
            shortDescriptionTextView.textColor = .lisboaGray
        }
        shortDescriptionTextView.configureText(withLocalizedString: textsEngine.getText(for: event))
        shortDescriptionTextView.textContainerInset = .zero
        drawBorder()
    }
    
    func setAsNoEventToday(_ event: TimeLineEvent) {
        (self as? TimeLineNotTodayCell)?.setNoEventsToday()
    }
    
    func setDateTodayDateCell(date: String) {
        (self as? TimeLineTodayCell)?.setDate(date: date)
    }
    
    func setDateNoTodayDateCell(date: String) {
        (self as? TimeLineNotTodayCell)?.setDate(date: date)
    }
    
    public func addShadowCell() {
        shadowConstraint.constant = 3
        drawShadow()
    }
    public func deleteShadowCell() {
        shadowConstraint.constant = 0
        drawShadow()
    }
    
    func setupIcon(event: TimeLineEvent) {
        logo.isHidden = true
        icon.isHidden = false
        icon.layer.cornerRadius = 0
        icon.setupIcon(event: event)
    }
    
    func setupLogo(event: TimeLineEvent) {
        logo.isHidden = false
        icon.isHidden = true
        logo.layer.cornerRadius = 0
        if let logoUrl = event.logo {
            logo.setImage(fromUrl: logoUrl, placeholder: UIImage.icon(for: event.type)?.withRenderingMode(.alwaysOriginal)) { [weak self] image in
                guard image != nil else { return }
                self?.logo.layer.cornerRadius = (self?.logo.frame.size.height ?? 0)/2

            }
        } else {
            logo.image = UIImage.icon(for: event.type)
            logo.superview?.isHidden = logo.image == nil
            logo.layer.cornerRadius = 0
        }
    }
    
    func setShadow(isLast: Bool) {
        invoicesContentView.layer.shadowColor = UIColor.red.cgColor
        invoicesContentView.layer.shadowOpacity = 0.3
        invoicesContentView.layer.shadowOffset = .init(width: 2, height: 2)
        invoicesContentView.layer.shadowRadius = 3
        invoicesContentView.layer.shadowPath = UIBezierPath(rect: invoicesContentView.bounds).cgPath
        invoicesContentView.layer.shouldRasterize = true
        invoicesContentView.layer.rasterizationScale = UIScreen.main.scale
    }
 }

extension TimeLineCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.delegate?.trackLink(with: URL)
        return true
    }
}
