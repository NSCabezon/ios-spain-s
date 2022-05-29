//
//  PhotoThemeModifierProtocol.swift
//  Commons
//
//  Created by Luis Escámez Sánchez on 30/6/21.
//

import CoreDomain

public struct PageInfo {
    public let id: Int
    public let title: LocalizedStylableText
    public let description: LocalizedStylableText
    public var imageName: String
    public var smartColorMode: PGColorMode?
    public var isEditable: Bool
    public var titleKey: String?
    
    public init(id: Int,
                title: LocalizedStylableText,
                description: LocalizedStylableText,
                imageName: String,
                smartColorMode: PGColorMode? = .red,
                isEditable: Bool = false,
                titleKey: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.imageName = imageName
        self.smartColorMode = smartColorMode
        self.isEditable = isEditable
        self.titleKey = titleKey
    }
}

public protocol PhotoThemeModifierProtocol {
    func getPhotoThemeInfo() -> [PageInfo]
    func getPhotoThemeInfo(for id: Int) -> PageInfo?
    func getBackGroundImage(for id: Int) -> BackgroundImagesTheme?
}
