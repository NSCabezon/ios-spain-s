//
//  OneTagsContainerXibView.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 20/4/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine
import UIOneComponents

private extension OneTagsContainerView {}

final class OneTagsContainerView: XibView {
    private var subscriptions = Set<AnyCancellable>()
    @IBOutlet private var contentView: UIView!
    private let deleteTagsSubject = PassthroughSubject<[TagMetaData], Never>()
    public var deleteTagsPublisher: AnyPublisher<[TagMetaData], Never> {
        deleteTagsSubject.eraseToAnyPublisher()
    }
    private enum Geometry: CGFloat {
        case startX = 0
        case startY = 8.0
        case leftPading = 12.0
        case rightPading = 22.0
        case topBottomPadding = 4
        case labelToBottomPadding = 2.0
        case buttomPadding = 10.0
        case itemInterspacing = 16.0
        case tagHeight = 24.0
    }
    private var newLineTagCount: CGFloat = 1.0
    private var xPos: CGFloat = Geometry.startX.rawValue
    private var yPos: CGFloat = Geometry.startY.rawValue
    private var tags: [TagMetaData] = [TagMetaData]()
    private lazy var deleteAllButton: OneTagButton = {
        let tagView = OneTagButton()
        tagView.titleLabel?.font = .typography(fontName: .oneB300Bold)
        tagView.setTitleColor(UIColor.darkTorquoise, for: .normal)
        tagView.titleLabel?.textAlignment = .center
        tagView.identifier = TagMetaData.deleteTagMetaIdentifier
        tagView.accessibilityIdentifier = TagMetaData.deleteTagMetaIdentifier
        tagView.titleLabel?.accessibilityIdentifier = "generic_button_deleteFilters"
        tagView.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        return tagView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func addTags(from tags: [TagMetaData]) {
        self.tags = tags
        self.newLineTagCount = 1
        self.updateTagsLayout()
        self.updateContainerHeight()
    }
    
    /// This method rebuild all tags each time is called. Each tags ar
    private func updateTagsLayout() {
        self.contentView?.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        if tags.count >= 1 {
            let deleteMeta = TagMetaData(withLocalized: localized("generic_button_deleteFilters"), identifier: TagMetaData.deleteTagMetaIdentifier, accessibilityId: TagMetaData.deleteTagMetaIdentifier)
            if !tags.contains(deleteMeta) {
                tags.append(deleteMeta)
            }
        }
        yPos = Geometry.startY.rawValue
        xPos = Geometry.startX.rawValue
        tags.forEach { (tagMeta) in
            let textWidth = tagMeta.localizedText.text.widthString()
            let textHeight = tagMeta.localizedText.text.heightString()
            let tagViewSize = CGSize(width: textWidth + (Geometry.leftPading.rawValue + Geometry.rightPading.rawValue),
                                  height: textHeight + Geometry.topBottomPadding.rawValue)
            let checkWholeWidth = CGFloat(xPos) + tagViewSize.width
            if checkWholeWidth > Screen.resolution.width - 32.0 {
                xPos = Geometry.startX.rawValue
                yPos += (Geometry.tagHeight.rawValue + Geometry.itemInterspacing.rawValue)
                newLineTagCount += 1
            }
            if tagMeta.identifier == TagMetaData.deleteTagMetaIdentifier {
                let tagviewFrame = CGRect(x: xPos, y: yPos, width: textWidth, height: tagViewSize.height)
                let tagView = self.deleteAllButton
                tagView.frame = tagviewFrame
                tagView.setTitle(tagMeta.localizedText.text, for: .normal)
                self.contentView?.addSubview(tagView)
            } else {
                let tagviewFrame = CGRect(x: xPos, y: yPos, width: tagViewSize.width, height: tagViewSize.height)
                let tagView = OneTagView(frame: tagviewFrame)
                tagView.identifier = tagMeta.identifier
                if let tagAccessibilityIdentifier = tagMeta.accessibilityIdentifier {
                    tagView.setAccessibilityIdentifiers(tagAccessibilityIdentifier)
                }
                tagView.setText(tagMeta.localizedText)
                self.contentView?.addSubview(tagView)
            }
            xPos = CGFloat(xPos) + ( CGFloat(tagViewSize.width) + Geometry.itemInterspacing.rawValue )
        }
    }
    
    private func updateContainerHeight() {
        invalidateIntrinsicContentSize()
        let adjustedHeight = (Geometry.tagHeight.rawValue + Geometry.itemInterspacing.rawValue) * newLineTagCount + Geometry.buttomPadding.rawValue + Geometry.startY.rawValue
        self.frame.size.height = adjustedHeight
        removeHightContraint()
        self.heightAnchor.constraint(equalToConstant: adjustedHeight).isActive = true
        self.setNeedsDisplay()
    }
    
    private func removeHightContraint() {
        self.constraints.first { $0.firstAnchor == heightAnchor }?.isActive = false
    }
    
    @objc private func closeButtonTapped(_ sender: OneTagButton) {
        if self.tags.first(where: {$0.identifier == sender.identifier}) != nil {
            self.tags.removeAll { (tagMeta) -> Bool in
                tagMeta.identifier == sender.identifier
            }
            if tags.count < 2 {
                self.tags.removeAll { (tagMeta) -> Bool in
                    tagMeta.identifier == TagMetaData.deleteTagMetaIdentifier
                }
            }
            self.newLineTagCount = 1.0
            self.updateTagsLayout()
            self.updateContainerHeight()
            deleteTagsSubject.send(self.tags)
        }
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        self.tags.removeAll()
        self.contentView?.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        self.updateTagsLayout()
        deleteTagsSubject.send(self.tags)
    }
}

extension String {
    
    func widthString(usingFont font: UIFont = .typography(fontName: .oneB300Bold)) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes as [NSAttributedString.Key: Any])
        return size.width
    }
    
    func heightString(usingFont font: UIFont = .typography(fontName: .oneB300Bold)) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}
