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
        case CardDetailVC = "segueShowCardDetailsVC"
        case cardDetailContainerVC = "segueCardDetailContainerVC"
        case PropertiesViewVC = "toPropertiesViewVC"
        case noInternetVC = "segueToNoInternetVC"
        case propertyMatchesVC = "segueToPropertyMatchesVC"
        case mainVC = "segueToMainVC"
        case reportUserVC = "segueToReportUserVC"
        case renterMatchesVC = "segueToRenterMatchesVC"
        case appInfoSelectionVC = "segueToAppInformationSelectionVC"
        case chooseAccountTypeVC = "toAccountTypeVC"
        case propertyDetailContainterVC = "detailsContainerVC"
        case messagingVC = "segueToMessagingVC"
        case renterMainVC = "segueToRenterMainVC"
        case filterVC = "segueToFiltersVC"
        case profileVC = "segueToProfileVC"
        case signUpProfileVC = "segueToSignUpProfileVC"
        case swipingVC = "toSwipingVC"
        case landlordMainVC = "segueToLandlordMainVC"
    }
    
    enum ViewControllers: String {
        case messageVC = "messageVC"
    }
    
    enum Notifications: String {
        case recievedMessage = "receivedMessageNotification"
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
        case MessageCell = "messageCell"
    }
    
    enum UserDefaults: String {
        case landlordMatchCount = "landlordMatchCount"
        case renterMatchCount = "renterMatchCount"
        case renterMatchedPropertiesIDs = "renterMatchedPropertyIDs"
        case propertyMatchCount = "propertyMatchCount"
        case propertyMatchedRenterIDs = "propertyMatchedRenterIDs"
    }
    
    enum RentWorksAdmin: String {
        case email = "rentworksdev@gmail.com"
        case complaintsEmail = "rentworkscomplaints@gmail.com"
        case EULA_URL = "http://www.garteum.com/eula"
        case PrivacyPolicyURL = "http://www.garteum.com/privacy-policy"
        case MIT_URL = "http://www.garteum.com/mit"
        case Acknowledgments = "http://www.garteum.com/acknowledgements"
    }
    
    enum CreatingUserNotificationObserver: String {
        case imageUploading = "Image Uploading"
        case imageFinishedUploading = "Image Finished Uploading"
        case creatingLandlord = "Creating Landlord"
        case finishedCreatingLandlord = "Finished Creating Landlord"
        case creatingRenter = "Creating Renter"
        case finishedCreatingRenter = "Finished Creating Renter"
        case creatingProperty = "Creating Property"
        case finishedCreatingProperty = "Finished Creating Property"
        static let allValues: [CreatingUserNotificationObserver] = [imageUploading, imageFinishedUploading, creatingLandlord, finishedCreatingLandlord, creatingRenter, finishedCreatingRenter, creatingProperty, finishedCreatingProperty]
    }
}
