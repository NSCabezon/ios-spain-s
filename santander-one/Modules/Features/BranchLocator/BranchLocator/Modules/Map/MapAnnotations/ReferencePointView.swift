import Foundation
import MapKit

class ReferencePointView: MKAnnotationView {
	
	var referencePoint: ReferencePoint?
	
	// MARK: - life cycle
	
	init(referencePoint: ReferencePoint, reuseIdentifier: String?) {
		super.init(annotation: referencePoint, reuseIdentifier: reuseIdentifier)
		self.referencePoint = referencePoint
		self.canShowCallout = false
		self.image = UIImage(resourceName: "referencePoint")
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.canShowCallout = false // This is important: Don't show default callout.
		self.image = UIImage(resourceName: "referencePoint")
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

	}
}
