//
//  GpOperativesViewModel.swift
//  Pods
//
//  Created by David Gálvez Alonso on 05/08/2020.
//

import Foundation

public final class GpOperativesViewModel {
    public let type: PGFrequentOperativeOptionProtocol
    public let viewType: ActionButtonFillViewType
    public let action: ((PGFrequentOperativeOptionProtocol, Void) -> Void)?
    public let isDisabled: Bool
    public let entity: Void
    public let highlightedInfo: HighlightedInfo?
    public let isDragDisabled: Bool
    public let renderingMode: UIImage.RenderingMode
    
    public init(type: PGFrequentOperativeOptionProtocol,
                viewType: ActionButtonFillViewType,
                action: ((PGFrequentOperativeOptionProtocol, Void) -> Void)?,
                isDisabled: Bool = false,
                highlightedInfo: HighlightedInfo? = nil,
                isDragDisabled: Bool = false,
                renderingMode: UIImage.RenderingMode = .alwaysTemplate) {
        self.type = type
        self.viewType = viewType
        self.action = action
        self.isDisabled = isDisabled
        self.highlightedInfo = highlightedInfo
        self.isDragDisabled = isDragDisabled
        self.renderingMode = renderingMode
    }
}

extension GpOperativesViewModel: ActionButtonFillViewModelProtocol {
    
}
