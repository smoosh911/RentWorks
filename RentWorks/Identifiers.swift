//
//  Segues.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class Identifiers {
    enum Segues: String {
        case editPropertyDetailsVC = "segueEditPropertyDetails"
        case addPropertyVC = "segueAddProperty"
        case MoreCardsVC = "segueShowNoMoreCardsVC"
        case MainSwipingVC = "toMainSwipingVC"
        case noInternetVC = "segueToNoInternetVC"
        case propertyMatchesVC = "segueToPropertyMatchesVC"
        case mainVC = "segueToMainVC"
        case reportUserVC = "segueToReportUserVC"
        case renterMatchesVC = "segueToRenterMatchesVC"
        case appInfoSelectionVC = "segueToAppInformationSelectionVC"
        case chooseAccountTypeVC = "toAccountTypeVC"
        case propertyDetailContainterVC = "detailsContainerVC"
    }
    
    enum StoryboardIDs: String {
        case noInternetVC = "noInternetVC"
    }
    
    enum TableViewCells: String {
        case PropertyCell = "propertyCell"
        case ReportUser = "cellReportUser"
        case AppInfo = "appInfoCell"
    }
    
    enum CollectionViewCells: String {
        case PropertyImageCell = "propertyImageCell"
    }
    
    enum UserDefaults: String {
        case landlordMatchCount = "landlordMatchCount"
        case renterMatchCount = "renterMatchCount"
        case propertyMatchCount = "propertyMatchCount"
    }
    
    enum RentWorksAdmin: String {
        case email = "rentworksdev@gmail.com"
        case complaintsEmail = "rentworkscomplaints@gmail.com"
        case EULA_URL = "http://www.myrentworks.com/copy-of-public-texts"
        case PrivacyPolicyURL = "http://www.myrentworks.com/privacy-policy"
    }
}
