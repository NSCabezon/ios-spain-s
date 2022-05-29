import Foundation
import SANLibraryV3
import SANLegacyLibrary

struct HelperMultimedia {
    func encodeData(image: Data?) -> String? {
        guard let imageData = image else { return "" }
        return imageData.base64EncodedString()
    }

    func encodeDataStringWithEmoji(_ text: String?) -> String {
        let utf8string = text?.data(using: .utf8)
        guard let base64EncodedString = utf8string?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) else {
            return ""
        }
        return base64EncodedString
    }

    func getImageFormat(_ base64Image: String?) -> BizumAttachmentImageType {
        guard let base64Image = base64Image, !base64Image.isEmpty  else {
            return .noImage
        }
        return .jpg
    }

    func decodeImage(text: String) -> Data? {
        guard !text.isEmpty, let data = Data(base64Encoded: text) else { return nil }
        return data
    }

    func decodeText(_ text: String?) -> String? {
        guard let text = text, !text.isEmpty, let data = Data(base64Encoded: text) else { return nil }
        let decodedString = String(data: data, encoding: .utf8)
        return decodedString
    }
}
