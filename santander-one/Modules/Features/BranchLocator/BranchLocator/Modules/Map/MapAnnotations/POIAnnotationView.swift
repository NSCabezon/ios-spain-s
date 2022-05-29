import UIKit
import MapKit

private let kPOIImage = #imageLiteral(resourceName: "touchpointWhite")
private let kMapAnimationTime = 0.300

public class POIAnnotationView: MKAnnotationView {
	
	var poi: POIAnnotation?
    weak var basicInfoDelegate: POIDetailDelegate?
	var imgView: UIImageView?
    var leadignConstraint: NSLayoutConstraint?

    // MARK: - life cycle
    
    override public var annotation: MKAnnotation?{
        willSet{
                if #available(iOS 11.0, *) {
                    clusteringIdentifier = String(describing: ClusterView.self)
                } else {
                    // Fallback on earlier versions
                    // 
                }
        }
    }
    
    
    
    
	public init(poiAnnotation: POIAnnotation, reuseIdentifier: String?) {
        super.init(annotation: poiAnnotation, reuseIdentifier: reuseIdentifier)
		self.poi = poiAnnotation
        self.canShowCallout = false
		
		self.image = poiAnnotation.mapPin.objectType?.code?.bgImage
		let imgView = UIImageView(image: poiAnnotation.mapPin.getIcon())
		
        if poi?.mapPin.subType?.code == SubTypeCode.nonSantanderATM &&
			(poi?.mapPin.specialType?.code != SubTypeCode.popular && poi?.mapPin.subType?.code != SubTypeCode.pastor) {
            imgView.image = UIImage(resourceName: "atm")
            imgView.tintColor = .santanderRed
        } else if poi?.mapPin.specialType?.isPopularOrPastor ?? false {
            imgView.image = UIImage(resourceName: "popular")?.withRenderingMode(.alwaysOriginal)
            self.image = poi?.mapPin.objectType?.code?.bgImage
        } else if poi?.mapPin.subType?.code == SubTypeCode.workCafe {
            imgView.image = UIImage(resourceName: "workcafe")
        } else {
            imgView.tintColor = .santanderRed
        }
		
		imgView.translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(imgView)
		
		self.imgView = imgView
        
        setImageViewConstraints(isSelected: false)
    }
    
    func setImageViewConstraints(isSelected: Bool){
        guard let imgView = self.imgView else{
            return
        }
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        let aspectRatioConstraint = NSLayoutConstraint(item: imgView, attribute: .width, relatedBy: .equal, toItem: imgView, attribute: .height, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: imgView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYContraint = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -2)
        
        //to force delete the constraint added before
        guard var leadingPin = self.leadignConstraint else{
            let defaultConstraint = NSLayoutConstraint(item: imgView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.30, constant: 0)
            addConstraints([aspectRatioConstraint, centerXConstraint, centerYContraint, defaultConstraint])
            leadignConstraint = defaultConstraint
            return
        }
        
        if isSelected{
            self.removeConstraint(self.leadignConstraint!)
            leadingPin = NSLayoutConstraint(item: imgView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.45, constant: 0)
        }else{
            self.removeConstraint(self.leadignConstraint!)
            leadingPin = NSLayoutConstraint(item: imgView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.30, constant: 0)
        }
        
        addConstraints([aspectRatioConstraint, centerXConstraint, centerYContraint, leadingPin])
        leadignConstraint = leadingPin
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false // This is important: Don't show default callout.
        self.image = kPOIImage
    }
	
	override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		
        if selected {
            self.imgView?.tintColor = UIColor.white
            
            if poi?.mapPin.subType?.code == SubTypeCode.nonSantanderATM &&
                (poi?.mapPin.specialType?.code != SubTypeCode.popular && poi?.mapPin.subType?.code != SubTypeCode.pastor) {
                self.imgView?.image = UIImage(resourceName: "atm")
                self.imgView?.tintColor = .white
                self.image = poi?.mapPin.objectType?.code?.selectedBgImage
            } else if poi?.mapPin.specialType?.isPopularOrPastor ?? false {
                self.image = poi?.mapPin.objectType?.code?.selectedBgImagePopular
                self.imgView?.image = UIImage(resourceName: "popular")?.withRenderingMode(.alwaysTemplate)
                self.imgView?.tintColor = .white
                
            } else if poi?.mapPin.subType?.code == SubTypeCode.workCafe {
                self.image = UIImage(resourceName: "touchPointBigWorkCafe")
                self.imgView?.image = UIImage(resourceName: "workcafeWhite")
            } else if poi?.mapPin.subType?.code == SubTypeCode.post {
                self.image = UIImage(resourceName: "touchpointBigBlue")
                self.imgView?.image = UIImage(resourceName: "icCorreosY")
                
            } else {
                self.image = poi?.mapPin.objectType?.code?.selectedBgImage
            }
            setImageViewConstraints(isSelected: true)
		} else {
			self.image = poi?.mapPin.objectType?.code?.bgImage
			
            if poi?.mapPin.subType?.code == SubTypeCode.nonSantanderATM &&
                (poi?.mapPin.specialType?.code != SubTypeCode.popular && poi?.mapPin.subType?.code != SubTypeCode.pastor) {
                self.imgView?.image = UIImage(resourceName: "atm")
                self.imgView?.tintColor = .santanderRed
            } else if poi?.mapPin.specialType?.isPopularOrPastor ?? false {
                self.imgView?.image = UIImage(resourceName: "popular")
                self.imgView?.image?.withRenderingMode(.alwaysOriginal)
                self.image = poi?.mapPin.objectType?.code?.bgImage
            } else if poi?.mapPin.subType?.code == SubTypeCode.workCafe {
                self.imgView?.image = UIImage(resourceName: "workcafe")
            } else if poi?.mapPin.subType?.code == SubTypeCode.post {
                self.imgView?.image = UIImage(resourceName: "icCorreos")
                
            } else {
                self.imgView?.tintColor = .santanderRed
            }
            setImageViewConstraints(isSelected: false)
		}
		
		if let poiAnnotation = annotation as? POIAnnotation {
			basicInfoDelegate?.didTapOnPin(poiAnnotation: poiAnnotation, selected: selected)
		}
    }
}
