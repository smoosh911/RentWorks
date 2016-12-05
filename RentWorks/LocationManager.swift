//
//  LocationManager.swift
//  RentWorks
//
//  Created by Michael Perry on 12/4/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager {
    // needs work: implement
    static public func distanceBetweenTwoLocations(source: String, destination: String, completion: @escaping (_ distance: Int?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(source, completionHandler: { sourcePlacemark, error in
            if error != nil {
                log(error!)
                completion(nil)
            }
            geocoder.geocodeAddressString(destination, completionHandler: { destinationPlacemark, error2 in
                if error2 != nil {
                    log(error2!)
                    completion(nil)
                }
                guard let sps = sourcePlacemark, let sp = sps.first, let sourceLocation = sp.location, let dps = destinationPlacemark, let dp = dps.first, let destinationLocation = dp.location else { return }
                let distanceMeters = sourceLocation.distance(from: destinationLocation)
                let distanceMI = distanceMeters / 1609.34 // convert to miles
                let roundedTwoDigit = Int(distanceMI)
                completion(roundedTwoDigit)
            })
        })
    }
    
    // needs work: there is some repetitive code in this function
    static public func getDistancesArrayFor(entities: [Any], usingZipcode desiredLocation: String, completion: @escaping (_ distanceDict: [String: Int]) -> Void) {
        let group = DispatchGroup()
        var distanceDict: [String: Int] = [:]
        if let renters = entities as? [Renter] {
            for renter in renters {
                group.enter()
                distanceBetweenTwoLocations(source: renter.wantedZipCode!, destination: desiredLocation, completion: { (distance) in
                    if distance == nil, renter.email == nil {
                        group.leave()
                        return
                    }
                    distanceDict[renter.email!] = distance!
                    group.leave()
                })
            }
        } else if let properties = entities as? [Property] {
            for property in properties {
                group.enter()
                distanceBetweenTwoLocations(source: property.zipCode!, destination: desiredLocation, completion: { (distance) in
                    if distance == nil, property.propertyID == nil {
                        group.leave()
                        return
                    }
                    distanceDict[property.propertyID!] = distance!
                    group.leave()
                })
            }
        }
        group.notify(queue: .main, execute: {
            completion(distanceDict)
        })
    }
}
