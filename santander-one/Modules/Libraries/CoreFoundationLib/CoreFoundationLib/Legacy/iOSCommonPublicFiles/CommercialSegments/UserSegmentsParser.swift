

public struct UserSegmentsParser: Parser {
    
    public init() { }
    
    public func serialize(_ responseString: String) -> SegmentsListDTO? {
        do{
            let document = try XML.parse(responseString)
            switch document["segmentosComerciales"] {
            case .failure:
                return nil
            case .sequence(let elements):
                if let element = elements.first {
                    let bdpSegments = readFeed(element: element)
                    return SegmentsListDTO(bdpSegments: bdpSegments, xmlString:responseString)
                } else {
                    return nil
                }
            case .singleElement(let element):
                let bdpSegments = readFeed(element: element)
                return SegmentsListDTO(bdpSegments: bdpSegments, xmlString:responseString)
            }
        } catch {
            return nil
        }
    }
    
    public func deserialize(_ parseable: SegmentsListDTO) -> String? {
        return parseable.xmlString
    }
    
    private func readFeed(element: XML.Element) -> [BDPSegmentDTO] {
        let comercialSegments = element.childElements.filter { (element) -> Bool in
            return element.name == "segComercial"
        }
        var bdpSegments: [BDPSegmentDTO] = []
        for comercialSegment in comercialSegments {
            let bdpSegment = readBDPSegment(element: comercialSegment)
            bdpSegments.append(bdpSegment)
        }
        return bdpSegments
    }
    
    private func readBDPSegment(element: XML.Element) -> BDPSegmentDTO {
        var bdpSegmentType: String?
        var commercialSegments: [CommercialSegmentDTO] = []
        for children in element.childElements {
            switch children.name {
            case "tipoSegmentoBDP":
                bdpSegmentType = children.text
            case "comercialSegment":
                let commercialSegment = readCommercialSegment(element: children)
                commercialSegments.append(commercialSegment)
            default:
                break
            }
        }
        let bdpSegment = BDPSegmentDTO(bdpSegmentType: bdpSegmentType, commercialSegments: commercialSegments)
        return bdpSegment
    }
    
    private func readCommercialSegment(element: XML.Element) -> CommercialSegmentDTO {
        var commercialSegmentType: String?
        var topBarBackground: String?
        var contact: ContactDTO?
        var segmentOperations: SegmentOperationsDTO?
        for children in element.childElements {
            switch children.name {
            case "tipoSegmentoComercial":
                commercialSegmentType = children.text
            case "topBarBackground":
                topBarBackground = children.text
            case "contact":
                contact = readContact(element: children)
            case "operations":
                segmentOperations = readOperations(element: children)
            default:
                break
            }
        }
        let comercialSegment = CommercialSegmentDTO(commercialSegmentType: commercialSegmentType, topBarBackground: topBarBackground, contact: contact, segmentOperations: segmentOperations)
        return comercialSegment
    }
    
    private func readContact(element: XML.Element) -> ContactDTO {
        var twitterContact: SocialNetworksContactDTO?
        var facebookContact: SocialNetworksContactDTO?
        var googlePlusContact: SocialNetworksContactDTO?
        var whatsAppContact: SimpleContactDTO?
        var mailContact: SimpleContactDTO?
        var contactAreas: [ContactAreaDTO] = []
        for children in element.childElements {
            switch children.name {
            case "contactArea":
                let contactArea = readContactArea(element: children)
                contactAreas.append(contactArea)
            case "contactTwitter":
                twitterContact = readSocialNetworkContact(element: children)
            case "contactFacebook":
                facebookContact = readSocialNetworkContact(element: children)
            case "contactGPlus":
                googlePlusContact = readSocialNetworkContact(element: children)
            case "contactWhatsapp":
                whatsAppContact = readSimpleContact(element: children)
            case "contactMail":
                mailContact = readSimpleContact(element: children)
            default:
                break
            }
        }
        return ContactDTO(twitterContact: twitterContact, facebookContact: facebookContact, googlePlusContact: googlePlusContact, whatsAppContact: whatsAppContact, mailContact: mailContact, contactAreas: contactAreas)
    }
    
    private func readContactArea(element: XML.Element) -> ContactAreaDTO {
        var title: String?
        var contents: [ContactAreaContentDTO] = []
        for children in element.childElements {
            switch children.name {
            case "contactAreaContent":
                let contactAreaContent = readContactAreaContent(element: children)
                contents.append(contactAreaContent)
            case "contactAreaTitle":
                title = children.text
            default:
                break
            }
        }
        let contactArea = ContactAreaDTO(title: title, contents: contents)
        return contactArea
    }

    private func readContactAreaContent(element: XML.Element) -> ContactAreaContentDTO {
        var title: String?
        var subtitle: String?
        var phoneList: [ContactAreaPhoneDTO] = []
        for children in element.childElements {
            switch children.name {
            case "contactAreaContentPhone1", "contactAreaContentPhone2":
                let contactAreaContentPhone = readContactAreaContentPhone(element: children)
                phoneList.append(contactAreaContentPhone)
            case "contactAreaContentTitle":
                title = children.text
            case "contactAreaContentSubtitle":
                subtitle = children.text
            default:
                break
            }
        }
        let contactAreaContent = ContactAreaContentDTO(title: title, subtitle: subtitle, phoneList: phoneList)
        return contactAreaContent
    }
    
    private func readContactAreaContentPhone(element: XML.Element) -> ContactAreaPhoneDTO {
        let number = element.attributes["number"]
        let fromAbroadText = "Si llama desde el extranjero"
        let numberToDisplay = element.text?.replacingOccurrences(of: fromAbroadText, with: "")
        let contactAreaPhone = ContactAreaPhoneDTO(number: number, numberToDisplay: numberToDisplay)
        return contactAreaPhone
    }
    
    private func readSocialNetworkContact(element: XML.Element) -> SocialNetworksContactDTO {
        var active: Bool?
        var account: String?
        var url: String?
        var appUrl: String?
        for children in element.childElements {
            switch children.name {
            case "active":
                active = readBoolValue(text: children.text)
            case "account":
                account = children.text
            case "url":
                url = children.text
            case "appUrl":
                appUrl = children.text
            default:
                break
            }
        }
        return SocialNetworksContactDTO(active: active, account: account, url: url, appUrl: appUrl)
    }
    
    private func readSimpleContact(element: XML.Element) -> SimpleContactDTO {
        var active: Bool?
        var account: String?
        var hint: String?
        for children in element.childElements {
            switch children.name {
            case "active":
                active = readBoolValue(text: children.text)
            case "mail":
                account = children.text
            case "phone":
                account = children.text
            case "hint":
                hint = children.text
            default:
                break
            }
        }
        return SimpleContactDTO(active: active, account: account, hint: hint)
    }
    
    private func readOperations(element: XML.Element) -> SegmentOperationsDTO {
        var easyPayMinValue: Double?
        for children in element.childElements {
            switch children.name {
            case "easyPayment":
                easyPayMinValue = readDoubleValue(text: children.text)
            default:
                break
            }
        }
        return SegmentOperationsDTO(easyPayMinValue: easyPayMinValue)
    }
    
    private func readBoolValue(text: String?) -> Bool {
        return text?.uppercased() == "TRUE" || text?.uppercased() == "Y"
    }
    
    private func readDoubleValue(text: String?) -> Double? {
        guard let text = text else {
            return nil
        }
        return Double(text)
    }
}
