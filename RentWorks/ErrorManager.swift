//
//  ErrorManager.swift
//  RentWorks
//
//  Created by Michael Perry on 12/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class ErrorManager {
    enum RenterErrors: String {
        case error = "error"
        static let errorContentType = "error"
        static let errorID = "renterError"
        static let firebaseRetrievalError = "ERROR: renter retrieval from firebase"
        static let propertyRetrievalError = "ERROR: renter property retrieval from database"
    }
    
}
