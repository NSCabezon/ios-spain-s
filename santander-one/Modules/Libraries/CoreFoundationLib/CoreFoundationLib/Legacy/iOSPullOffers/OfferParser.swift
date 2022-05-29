import Fuzi
import CoreDomain

public class OfferParser: Parser {
    enum TimeFormat: String {
        case ddMMyyyyHHmmss = "dd-MM-yyyy HH:mm:ss"
        case dd__MM__yyyyHHmmss = "dd/MM/yyyy HH:mm:ss"
        case dd__MM__yyyy = "dd/MM/yyyy"
        case ddMMyyyy = "dd-MM-yyyy"
        case yyyyMMdd = "yyyy-MM-dd"
        case yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
        case yyyy__MM__ddHHmmss = "yyyy/MM/dd HH:mm:ss"
        case yyyy__MM__dd = "yyyy/MM/dd"

        static func allValues() -> [TimeFormat] {
            return [.ddMMyyyyHHmmss, .dd__MM__yyyyHHmmss, .dd__MM__yyyy, .ddMMyyyy, .yyyyMMdd, .yyyyMMddHHmmss, .yyyy__MM__ddHHmmss, .yyyy__MM__dd]
        }
    }

    var logTag: String {
        return String(describing: type(of: self))
    }

    public func deserialize(_ parseable: [OfferDTO]) -> String? {
        var output = "<offers>"
        for offer in parseable {
            var partialOutput = "<product>"
            partialOutput += "<id>\(offer.product.identifier)</id>"

            if offer.product.rulesIds.count > 0 {
                partialOutput += "<rules>"
                for ruleId in offer.product.rulesIds {
                    partialOutput += "<rule>\(ruleId)</rule>"
                }
                partialOutput += "</rules>"
            }
            
            partialOutput += "<iterations>\(offer.product.iterations)</iterations>"
            partialOutput += "<never_expires>\(offer.product.neverExpires)</never_expires>"
            
            if let description = offer.product.description {
                partialOutput += "<description>\(description)</description>"
            }
            
            if let transparentClosure = offer.product.transparentClosure {
                partialOutput += "<transparent_closure>\(transparentClosure)</transparent_closure>"
            }
            
            if offer.product.banners.count > 0 {
                partialOutput += "<banners>"
                partialOutput += deserializeBanner(banners: offer.product.banners)
                partialOutput += "</banners>"
            }
            
            if offer.product.bannersContract.count > 0 {
                partialOutput += "<banners_contract>"
                partialOutput += deserializeBanner(banners: offer.product.bannersContract)
                partialOutput += "</banners_contract>"
            }
            if let date = offer.product.startDateUTC {
                let dateString = deserializeDate(date: date)
                partialOutput += "<start_date_utc>\(dateString)</start_date_utc>"
            }
            if let date = offer.product.endDateUTC {
                let dateString = deserializeDate(date: date)
                partialOutput += "<end_date_utc>\(dateString)</end_date_utc>"
            }
            
            if let action = offer.product.action {
                partialOutput += "<action type=\"\(action.type)\">\(action.getDeserialized())</action>"
            }
            
            partialOutput += "</product>"
            output += partialOutput
        }
        output += "</offers>"
        return output
    }
    
    public func serialize(_ responseString: String) -> [OfferDTO]? {
        var output: [OfferDTO] = []
        guard
            let document = try? XMLDocument(string: responseString),
            let offers = document.root
            else { return output }
        for product in offers.children(tag: "product") {
            let id = product.firstChild(tag: "id")?.stringValue ?? ""
            let iterations = Int(truncating: product.firstChild(tag: "iterations")?.numberValue ?? 0)
            let neverExpires = Bool(product.firstChild(css: "never_expires")?.stringValue.trimed ?? "false") ?? false
            let transparentClosure: Bool = Bool(product.firstChild(css: "transparent_closure")?.stringValue.trimed ?? "false") ?? false
            let description = product.firstChild(tag: "description")?.stringValue.trimed
            
            var outputRulesIds = [String]()
            if let rules = product.firstChild(tag: "rules") {
                for rule in rules.children(tag: "rule") {
                    outputRulesIds.append(rule.stringValue)
                }
            }
            
            var outputBanners = [BannerDTO]()
            if let banners = product.firstChild(tag: "banners") {
                for banner in banners.children(tag: "banner") {
                    let newBanner = serializeBanner(banner: banner)
                    outputBanners.append(newBanner)
                }
            }
            
            var outputBannersContract = [BannerDTO]()
            if let banners = product.firstChild(tag: "banners_contract") {
                for banner in banners.children(tag: "banner") {
                    let newBanner = serializeBanner(banner: banner)
                    outputBannersContract.append(newBanner)
                }
            }
            var startDate: Date?
            if let date = product.firstChild(tag: "start_date_utc")?.stringValue {
                startDate = serializeDate(dateString: date)
            }
            
            var endDate: Date?
            if let date = product.firstChild(tag: "end_date_utc")?.stringValue {
                endDate = serializeDate(dateString: date)
            }
            
            var parsedAction: OfferActionRepresentable?
            if let action = product.firstChild(tag: "action") {
                parsedAction = OfferActionParser().serialize(action.description)
            }
            
            let newProduct = OfferProductDTO(identifier: id, neverExpires: neverExpires, transparentClosure: transparentClosure, description: description, rulesIds: outputRulesIds, iterations: iterations, banners: outputBanners, bannersContract: outputBannersContract, action: parsedAction, startDateUTC: startDate, endDateUTC: endDate)
            output.append(OfferDTO(product: newProduct))
        }
        return output
    }
}

private extension OfferParser {
    func deserializeBanner(banners: [BannerDTO]) -> String {
        var partialOutput = ""
        for banner in banners {
            partialOutput += "<banner app=\"\(banner.app)\" height=\"\(banner.height)\" width=\"\(banner.width)\">"
            partialOutput += "<![CDATA["
            partialOutput += banner.url
            partialOutput += "]]>"
            partialOutput += "</banner>"
        }
        return partialOutput
    }

    func serializeBanner(banner: XMLElement) -> BannerDTO {
        var app = ""
        var height = ""
        var width = ""
        for (key, value) in banner.attributes {
            if key == "app" {
                app = value
            }
            if key == "height" {
                height = value
            }
            if key == "width" {
                width = value
            }
        }
        let url = banner.stringValue.replace("\n", "").trimed
        let newBanner = BannerDTO(app: app, height: Float(height) ?? 0, width: Float(width) ?? 0, url: url)
        return newBanner
    }

    func deserializeDate(date: Date) -> String {
        return toString(date: date, outputFormat: .yyyyMMdd) ?? ""
    }

    func serializeDate(dateString: String) -> Date? {
        let validFormmats: [TimeFormat] = TimeFormat.allValues()
        for format in validFormmats {
            if let date = fromString(input: dateString, inputFormat: format) {
                return date
            }
        }
        return nil
    }
    
    func fromString(input: String?, inputFormat: TimeFormat) -> Date? {
        if let input = input {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = inputFormat.rawValue
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            dateFormatter.locale = Locale.current
            return dateFormatter.date(from: input)
        }
        return nil
    }

    func toString(input: String?, inputFormat: TimeFormat, outputFormat: TimeFormat) -> String? {
        if let input = input, let date = fromString(input: input, inputFormat: inputFormat) {
            return toString(date: date, outputFormat: outputFormat)
        }
        return nil
    }

    func toString(date: Date, outputFormat: TimeFormat) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = outputFormat.rawValue
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale.current
        return formatter.string(from: date).lowercased()
    }
}
