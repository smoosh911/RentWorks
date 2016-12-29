//
//  ErrorManager.swift
//  RentWorks
//
//  Created by Michael Perry on 12/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class ErrorManager {
    
    static let customError = "customError"
    
    enum LogType: String {
        case logType = "logType"
        static let error = "genericLogError"
        static let warning = "genericLogWarning"
        static let print = "genericLogPrint"
    }
    
    enum ErrorFields: String {
        case error = "Error Fileds"
        static let name = "name"
        static let message = "full_text"
    }
    
    enum JsonErrors: String {
        case error = "JSONError"
        static let gettingJSON = "couldn't retrieve JSON"
        static let reachingService = "couldn't reach service"
        static let obtainingValuesFromJson = "couldn't retreivee JSON values"
    }
    
    enum LandlordErrors: String {
        case error = "error"
        static let errorID = "landlordError"
        static let creationError = "ERROR: couldn't create landlord"
        static let firebaseRetrievalError = "ERROR: landlord retrieval from firebase"
        static let retrievalError = "ERROR: landlord or landlord attribute retrieval from database"
    }
    
    enum PropertyErrors: String {
        case error = "error"
        static let errorID = "propertyError"
        static let creationError = "ERROR: couldn't create property"
        static let firebaseRetrievalError = "ERROR: property retrieval from firebase"
        static let retrievalError = "ERROR: property or property attribute retrieval from database"
    }
    
    enum RenterErrors: String {
        case error = "error"
        static let errorContentType = "error"
        static let errorID = "renterError"
        static let firebaseRetrievalError = "ERROR: renter retrieval from firebase"
        static let propertyRetrievalError = "ERROR: renter property retrieval from database"
    }
    
}
