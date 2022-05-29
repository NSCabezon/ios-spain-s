import Foundation
import Fuzi

class SegmentDTOParser: DTOParser  {    
    public static func parse(_ node: XMLElement) -> SegmentDTO {
        var segmentDTO = SegmentDTO()
        segmentDTO.segmentDescription = node.firstChild(tag:"descSegmentoCliente")?.stringValue.trim()
        if let clientSegmentNode = node.firstChild(tag:"segmentoCliente"){
            var clientSegment = ClientSegmentDTO()
            clientSegment.company = clientSegmentNode.firstChild(tag:"EMPRESA")?.stringValue.trim()
            clientSegment.segment = clientSegmentNode.firstChild(tag:"SEGMENTO")?.stringValue.trim()
            segmentDTO.clientSegment =  clientSegment
        }
        return segmentDTO
    }
}
