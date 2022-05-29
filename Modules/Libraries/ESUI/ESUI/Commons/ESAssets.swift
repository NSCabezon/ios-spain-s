//
//  ESAssets.swift
//  ESUI
//
//  Created by Carlos Monfort Gómez on 07/04/2021.
//

import Foundation

public final class ESAssets {
    public static func image(named name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle(for: ESAssets.self), compatibleWith: nil)
    }
}
