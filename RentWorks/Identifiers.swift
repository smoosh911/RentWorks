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
        case MainSwipingVC = "toMainSwipingVC"
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
        case renterFilterVC = "segueToFiltersVC"
        case profileVC = "segueToProfileVC"
        case signUpProfileVC = "segueToSignUpProfileVC"
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
        case EULA_URL = "http://www.myrentworks.com/copy-of-public-texts"
        case PrivacyPolicyURL = "http://www.myrentworks.com/privacy-policy"
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
