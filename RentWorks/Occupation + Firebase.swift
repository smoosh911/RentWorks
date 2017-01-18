//
//  Occupation + Firebase.swift
//  RentWorks
//
//  Created by Michael Perry on 1/15/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation

extension Occupation {
    var dictionaryRepresentation: [String: Any]? {
        guard let title = title,
            let employer = employer
            else {
                return nil
        }
        
        var dictionaryRepresentation: [String: Any] = [:]
        
        dictionaryRepresentation[UserController.kTitle] = title
        dictionaryRepresentation[UserController.kEmployer] = employer
        dictionaryRepresentation[UserController.kCity] = city ?? ""
        dictionaryRepresentation[UserController.kState] = state ?? ""
        dictionaryRepresentation[UserController.kStartDate] = startDate?.timeIntervalSince1970
        dictionaryRepresentation[UserController.kEndDate] = endDate?.timeIntervalSince1970
        
        return dictionaryRepresentation
    }
}
