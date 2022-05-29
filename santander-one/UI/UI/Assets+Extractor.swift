//
//  Assets+Extractor.swift
//  UI
//
//  Created by Marcos Álvarez Mesa on 25/3/21.
//

import Foundation

public extension Assets {
    
    private enum Constants {
        static let extractionSubdirectory = "extractedAssetImages"
        static let imageExtensionPNG = "png"
    }
    
    static func getBase64Image(_ name: String) -> String {
        guard let image = Assets.image(named: name),
              let imageData = image.pngData() else { return "" }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}
