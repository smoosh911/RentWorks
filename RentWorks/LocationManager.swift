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
    static public func getDistancesArrayFor(entities: [Any], usingLocation desiredLocation: String, completion: @escaping (_ distanceDict: [String: Int]) -> Void) {
        let group = DispatchGroup()
        var distanceDict: [String: Int] = [:]
        if let renters = entities as? [Renter] {
            for renter in renters {
                group.enter()
                var renterLocation = ""
                if renter.wantedZipCode == nil || renter.wantedZipCode == "" {
                    renterLocation = "\(renter.wantedCity!), \(renter.wantedState!)"
                } else {
                    renterLocation = renter.wantedZipCode!
                }
                distanceBetweenTwoLocations(source: renterLocation, destination: desiredLocation, completion: { (distance) in
                    if distance == nil || renter.email == nil {
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
                var propertyLocation = ""
                if property.zipCode == nil || property.zipCode == "" {
                    propertyLocation = "\(property.city!), \(property.state!)"
                } else {
                    propertyLocation = property.zipCode!
                }
                distanceBetweenTwoLocations(source: propertyLocation, destination: desiredLocation, completion: { (distance) in
                    if distance == nil || property.propertyID == nil {
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
    
    // makes calls to the http://api.geonames.org/ api
    static public func getCitiesWith(cityName: String, resultCount: Int, country: String = "US", completion: @escaping (_ cities: [City]?) -> Void) {
        var cityName = cityName
        
        if cityName.characters.contains(" ") {
            cityName = cityName.replaceWhitespaceWithURLSpaces()
            print(cityName)
        }
        
        var cities: [City] = []
        
        let baseURLString = "http://api.geonames.org/searchJSON?"
        let username = "rentworksdev"
        let fullURLString = baseURLString + "q=\(cityName)&country=\(country)&maxRows=\(resultCount)&username=\(username)"
        guard let requestURL: URL = URL(string: fullURLString) else { completion(nil); return }
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        
        let group = DispatchGroup()
        group.enter()
        let task = session.dataTask(with: urlRequest) { (data, response, error) -> Void in
            if (error != nil) {
                log(ErrorManager.JsonErrors.reachingService)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    guard let jsonUnwrapped = json as? [String: Any] else {
                        log(ErrorManager.JsonErrors.gettingJSON)
                        completion(nil)
                        return
                    }
                    
                    if let geonames = jsonUnwrapped["geonames"] as? [[String: AnyObject]] {
                        for city in geonames {
                            guard let name = city["name"] as? String, let country = city["countryName"] as? String, let state = city["adminName1"] as? String, let lat = city["lat"]?.floatValue, let lng = city["lng"]?.floatValue else {
                                log(ErrorManager.JsonErrors.obtainingValuesFromJson)
                                completion(nil)
                                return
                            }
                            
                            let newCity = City(name: name, state: state, country: country, latitude: lat, longitude: lng)
                            cities.append(newCity)
                        }
                        group.leave()
                    }
                } catch {
                    log(ErrorManager.JsonErrors.gettingJSON)
                    completion(nil)
                }
            }
        }
        
        task.resume()
        
        group.notify(queue: .main, execute: {
            completion(cities)
        })
    }
}

class City {
    var name: String!
    var state: String!
    var country: String!
    var latitude: Float!
    var longitude: Float!
    
    init(name: String, state: String, country: String, latitude: Float, longitude: Float) {
        self.name = name
        self.state = state
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public func getCityStateString() -> String {
        return "\(self.name!), \(self.state!)"
    }
}
