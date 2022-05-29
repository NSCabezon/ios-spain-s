import Fuzi

class PersonBasicDataDTOParser: DTOParser {
    
    func parse(_ node: XMLElement) -> PersonBasicDataDTO {
        
        var personBasicDataDTO = PersonBasicDataDTO()
        
        self.parseAddress(&personBasicDataDTO, node: node)
        self.parseDocument(&personBasicDataDTO, node: node)
        self.parseBirthDate(&personBasicDataDTO, node: node)
        self.parseContactInfo(&personBasicDataDTO, node: node)
        return personBasicDataDTO
    }
}

// MARK: - Private Methods
extension PersonBasicDataDTOParser {
    
    private func parseAddress(_ dto: inout PersonBasicDataDTO, node: XMLElement) {
        
        if let homeAddressList = findChild(node: node, childName: "listaDomicilios"), let descriptions = homeAddressList.firstChild(tag: "descripciones") {
            let tranlatableDescriptions = descriptions.children(tag: "descripcionTraducible")
            var address = ""
            var nodes = [String]()
            for tranlatableDescription in tranlatableDescriptions {
                if let description = tranlatableDescription.firstChild(tag: "DESCRIPCION")?.stringValue {
                    let trimedDescription = description.trim()
                    address += " " + trimedDescription
                    if !trimedDescription.isEmpty {
                        nodes.append(trimedDescription)
                    }
                }
            }
            dto.mainAddress = address.trim()
            dto.addressNodes = nodes
        }
    }
    
    private func parseDocument(_ dto: inout PersonBasicDataDTO, node: XMLElement) {
        
        if let document = findChild(node: node, childName: "documentoIdentificacion") {
            if let documentTypeValue = document.firstChild(tag: "TIPO_DOCUM_PERSONA_CORP")?.stringValue {
                dto.documentType = DocumentType(rawValue: documentTypeValue.trim())
            }
            if let documentNumberValue = document.firstChild(tag: "CODIGO_DOCUM_PERSONA_CORP")?.stringValue {
                dto.documentNumber = documentNumberValue.trim()
            }
        }
    }
    
    private func parseContactInfo(_ dto: inout PersonBasicDataDTO, node: XMLElement) {
        if let contactInfo = findChild(node: node, childName: "informacionContacto") {
            let contactInfoElements = contactInfo.children(tag: "contacto")
            
            if let phoneNumberElement = contactInfoElements.first(where: { $0.firstChild(tag: "descTipoDispositivo")?.stringValue == "TELÉFONO" }) {
                parsePhone(phoneNumberElement, &dto)
                parseHours(phoneNumberElement, &dto)
            }
            
            if let emailElement = contactInfoElements.first(where: { $0.firstChild(tag: "descTipoDispositivo")?.stringValue == "E-MAIL" }) {
                parseMail(emailElement, &dto)
            }
        }
    }
    
    private func parseBirthDate(_ dto: inout PersonBasicDataDTO, node: XMLElement) {
        if let birthDateValue = findChild(node: node, childName: "fechaNacimiento")?.stringValue {
            dto.birthDate = birthDateValue.trim().toDate(dateFormat: DateFormats.TimeFormat.YYYYMMDD.rawValue)
        }
    }
    
    private func parseMail(_ emailElement: XMLElement, _ dto: inout PersonBasicDataDTO) {
        if let emailValue = emailElement.firstChild(tag: "contacto")?.stringValue {
            dto.email = emailValue.trim()
        }
    }
    
    private func parsePhone(_ phoneNumberElement: XMLElement, _ dto: inout PersonBasicDataDTO) {
        if let phoneValue = phoneNumberElement.firstChild(tag: "contacto")?.stringValue {
            dto.phoneNumber = phoneValue.trim()
        }
    }
    
    private func parseHours(_ phoneNumberElement: XMLElement,_ dto: inout PersonBasicDataDTO) {
        
        if let contactHourFromValue = phoneNumberElement.firstChild(tag: "horaDesde")?.stringValue {
            dto.contactHourFrom = contactHourFromValue.trim().toDate(dateFormat: DateFormats.TimeFormat.HHmmssZ.rawValue)
        }
        
        if let contactHourToValue = phoneNumberElement.firstChild(tag: "horaHasta")?.stringValue {
            dto.contactHourTo = contactHourToValue.trim().toDate(dateFormat: DateFormats.TimeFormat.HHmmssZ.rawValue)
        }
    }
    
    private func findChild(node: XMLElement, childName: String) -> XMLElement?{
        if let child = node.firstChild(tag: childName){
            return child
        }
        else{
            if node.children.count > 0{
                for childNode in node.children{
                    if let foundChild = findChild(node: childNode, childName: childName){
                        return foundChild
                    }
                }
            }
        }
        return nil
    }
}
