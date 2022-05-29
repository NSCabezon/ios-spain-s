//
//  MKCoordinateRegionExtension.swift
//  LocatorApp
//
//  Created by Ivan Cabezon on 31/7/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation
import MapKit

private let kSpanMargin = 1.15

extension MKCoordinateRegion {
	init(annotations: [MKAnnotation]) {
		var minLat: CLLocationDegrees = 90.0
		var maxLat: CLLocationDegrees = -90.0
		var minLon: CLLocationDegrees = 180.0
		var maxLon: CLLocationDegrees = -180.0
		
		for annotation in annotations {
			let lat = Double(annotation.coordinate.latitude)
			let long = Double(annotation.coordinate.longitude)
			if lat < minLat {
				minLat = lat
			}
			if long < minLon {
				minLon = long
			}
			if lat > maxLat {
				maxLat = lat
			}
			if long > maxLon {
				maxLon = long
			}
		}
		
		let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * kSpanMargin, longitudeDelta: (maxLon - minLon) * kSpanMargin)
		let center = CLLocationCoordinate2DMake((maxLat - span.latitudeDelta / 2), maxLon - span.longitudeDelta / 2)
		self.init(center: center, span: span)
	}
	
	var mapRect: MKMapRect {
		let aPoint = MKMapPoint(CLLocationCoordinate2DMake(center.latitude + span.latitudeDelta / 2, center.longitude - span.longitudeDelta / 2))
		let bPoint = MKMapPoint(CLLocationCoordinate2DMake(center.latitude - span.latitudeDelta / 2, center.longitude + span.longitudeDelta / 2))
		return MKMapRect(x: min(aPoint.x, bPoint.x), y: min(aPoint.y, bPoint.y), width: abs(aPoint.x - bPoint.x), height: abs(aPoint.y - bPoint.y))
	}
}
