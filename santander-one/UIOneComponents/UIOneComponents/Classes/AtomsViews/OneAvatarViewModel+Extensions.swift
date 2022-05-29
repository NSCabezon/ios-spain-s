//
//  OneAvatarViewModel+Extensions.swift
//  UIOneComponents
//
//  Created by Angel Abad Perez on 7/10/21.
//

import CoreFoundationLib
import UI

extension OneAvatarViewModel {
    private var colorsEngine: ColorsByNameEngine {
        return self.dependenciesResolver.resolve()
    }
    public var color: UIColor {
        let colorType = self.colorsEngine.get(self.fullName ?? "")
        let colorsByNameViewModel = ColorsByNameViewModel(colorType)
        return colorsByNameViewModel.color
    }
}
