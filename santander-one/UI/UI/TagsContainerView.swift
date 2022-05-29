//
//  TagsContainerView.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 10/02/2020.
//
import CoreFoundationLib
import UIKit
import OpenCombine

public protocol TagsContainerViewDelegate: AnyObject {
    func didRemoveFilter(_ remaining: [TagMetaData])
}

public final class TagsContainerView: UIDesignableView {
    
    public weak var delegate: TagsContainerViewDelegate?
    private let deleteTagsSubject = PassthroughSubject<[TagMetaData], Never>()
    public var deleteTagsPublisher: AnyPublisher<[TagMetaData], Never> {
        deleteTagsSubject.eraseToAnyPublisher()
    }

    private enum Geometry: CGFloat {
        case startX = 10
        case startY = 5.0
        case leftPading = 12.0
        case rightPading = 22.0
        case topBottomPadding = 14
        case labelToBottomPadding = 2.0
        case buttomToLabelPadding = 20.0
        case itemInterspacing = 7.0
        case tagHeight = 30
    }
    
    private var newLineTagCount: CGFloat = 1.0
    private var xPos: CGFloat = Geometry.startX.rawValue
    private var yPos: CGFloat = Geometry.startY.rawValue
    private var tags: [TagMetaData] = [TagMetaData]()
    private lazy var deleteAllButton: TagButton = {
        let tagView = TagButton()
        tagView.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 12)
        tagView.setTitleColor(UIColor.darkTorquoise, for: .normal)
        tagView.titleLabel?.textAlignment = .center
        tagView.identifier = TagMetaData.deleteTagMetaIdentifier
        tagView.accessibilityIdentifier = TagMetaData.deleteTagMetaIdentifier
        tagView.titleLabel?.accessibilityIdentifier = "generic_label_deleteFiltersButton"
        tagView.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        return tagView
    }()
    
    override public func commonInit() {
        super.commonInit()
    }
    
    /// With the provided metadata array this class build the tags view and append to the container itself
    /// - Parameter tags: array of metadata to be used by tags
    public func addTags(from tags: [TagMetaData]) {
        self.tags = tags
        self.updateTagsLayout()
        self.updateContainerHeight()
    }
    
    /// This method rebuild all tags each time is called. Each tags ar
    private func updateTagsLayout() {
        self.contentView?.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        if tags.count >= 2 {
            let deleteMeta = TagMetaData(withLocalized: localized("generic_button_deleteFilters"), identifier: TagMetaData.deleteTagMetaIdentifier, accessibilityId: TagMetaData.deleteTagMetaIdentifier)
            if !tags.contains(deleteMeta) {
                tags.append(deleteMeta)
            }
        }

        yPos = Geometry.startY.rawValue
        xPos = Geometry.startX.rawValue
        tags.forEach { (tagMeta) in
            
            let textWidth = tagMeta.localizedText.text.widthOfString()
            let textHeight = tagMeta.localizedText.text.heightOfString()
            let tagViewSize = CGSize(width: textWidth + (Geometry.leftPading.rawValue + Geometry.rightPading.rawValue),
                                  height: textHeight + Geometry.topBottomPadding.rawValue)
            
            let checkWholeWidth = CGFloat(xPos) + CGFloat(textWidth) + Geometry.itemInterspacing.rawValue
            if checkWholeWidth > Screen.resolution.width - 25.0 {
                xPos = Geometry.startX.rawValue
                yPos += (Geometry.tagHeight.rawValue + Geometry.itemInterspacing.rawValue)
                newLineTagCount += 1
            }
            let tagviewFrame = CGRect(x: xPos, y: yPos, width: tagViewSize.width, height: tagViewSize.height)
            if tagMeta.identifier == TagMetaData.deleteTagMetaIdentifier {
                let tagView = self.deleteAllButton
                tagView.frame = tagviewFrame
                tagView.setTitle(tagMeta.localizedText.text, for: .normal)
                self.contentView?.addSubview(tagView)
            } else {
                let tagView = TagView(frame: tagviewFrame)
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
        let adjustedHeight = Geometry.tagHeight.rawValue * newLineTagCount + Geometry.topBottomPadding.rawValue
        self.frame.size.height += adjustedHeight
        self.heightAnchor.constraint(equalToConstant: adjustedHeight).isActive = true
        self.setNeedsDisplay()
    }
    
    @objc private func closeButtonTapped(_ sender: TagButton) {
        if self.tags.first(where: {$0.identifier == sender.identifier}) != nil {
            self.tags.removeAll { (tagMeta) -> Bool in
                tagMeta.identifier == sender.identifier
            }
            // if theres more than 2 buttons delete button are included
            if tags.count > 2 {
                self.tags.removeAll { (tagMeta) -> Bool in
                    tagMeta.identifier == TagMetaData.deleteTagMetaIdentifier
                }
            }
            self.updateTagsLayout()
            deleteTagsSubject.send(self.tags)
            self.delegate?.didRemoveFilter(self.tags)
        }
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        self.tags.removeAll()
        self.contentView?.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        self.updateTagsLayout()
        deleteTagsSubject.send(self.tags)
        self.delegate?.didRemoveFilter(self.tags)
    }
}

public extension String {
    
    func widthOfString(usingFont font: UIFont? = UIFont.santander(family: .text, type: .bold, size: 10)) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes as [NSAttributedString.Key: Any])
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont = UIFont.santander(family: .text, type: .bold, size: 10)) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}
