//
//  LoginViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/3/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let facebookLoginButton = FBSDKLoginButton()
    let loginManager = FBSDKLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLoginButton.delegate = self
        facebookLoginButton.loginBehavior = .web
        facebookLoginButton.readPermissions = ["email"]
        self.view.addSubview(facebookLoginButton)
        constraintsForFacebookLoginButton()
        
        guard let token = FBSDKAccessToken.current() else { return }
        if token.hasGranted("email") {
            print("Granted")
//            let dict = initialRequest()
        }
        
        // TODO: - Run a check to see if the user has already created a RW account with Facebook. (Using the FBSDKAccessToken.current().userID
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)

        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            
            print(user)
        })
//        initialRequest()
        
    }
    func initialRequest() -> [String: Any]? {
        var resultDictionary: [String: Any]?
        guard let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name"], httpMethod: "GET") else { return  nil }
        request.start(completionHandler: { (connection, result, error) in
            print(connection)
            guard error == nil else { print(error?.localizedDescription); return }
            
            guard let resultDict = result as? [String: Any] else { return }
            print(resultDict)
            resultDictionary = resultDict
        })
        
        return resultDictionary
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        
        return true
    }
    
    func constraintsForFacebookLoginButton() {
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let centerXConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .top, relatedBy: .equal, toItem: passwordTextField, attribute: .bottom, multiplier: 1, constant: 8)
        let widthConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .width, relatedBy: .equal, toItem: self.passwordTextField, attribute: .width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0, constant: 30)
        self.view.addConstraints([centerXConstraint, widthConstraint, topConstraint, heightConstraint])
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // MARK: - Chris' Facebook code
    /*
     func returnMyData(){
     if((FBSDKAccessToken.currentAccessToken()) != nil){
     FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, gender"]).startWithCompletionHandler({ (connection, result, error) -> Void in
     if ((error) != nil)
     {
     print("Error: \(error)")
     }
     else
     {
     let resultdict = result as! NSDictionary
     
     let fID = resultdict.objectForKey("id") as! String
     let firstName = resultdict.objectForKey("first_name") as! String
     let lastName = resultdict.objectForKey("last_name") as! String
     let gender = resultdict.objectForKey("gender") as! String
     
     // Adds Facebook data to Firebase
     
     let detailedUser = ["fID": fID, "firstName": firstName, "lastName": lastName, "gender": gender]
     
     //Add Facebook User Detail into facebookUser
     let facebookUserAuthID = ["\(fID)": "\(self.uid)"]
     let facebookUsersReference = self.firebaseURL.child("facebookUser")
     facebookUsersReference.updateChildValues(facebookUserAuthID)
     
     //Add user deatil
     self.addUserDetail(detailedUser)
     }
     })
     }
     }
     
     
     func returnFriendListData() {
     let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: nil)
     graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
     
     if ((error) != nil)
     {
     print("Error: \(error)")
     }
     else
     {
     let resultdict = result as! NSDictionary
     //                print("Result Dict: \(resultdict)")
     
     let data : NSArray = resultdict.objectForKey("data") as! NSArray
     
     for i in 0..<data.count {
     let valueDict : NSDictionary = data[i] as! NSDictionary
     let id = valueDict.objectForKey("id") as! String
     let name = valueDict.objectForKey("name") as! String
     
     //                    print("the id value is \(id)") print("\(name)")
     
     self.createFriend("\(id)", friendName: "\(name)")
     }
     let friends = resultdict.objectForKey("data") as! NSArray
     print("Found \(friends.count) friends")
     
     //Test Query For Miles
     // TODO: - Need to look into why FB wasn't logging in
     
     HealthKitController.sharedController.authorizeHealthKit({ (success, error) in
     if success {
     HealthKitController.sharedController.setLastDaysToZero()
     HealthKitController.sharedController.setupMilesCollectionStatisticQuery()
     HealthKitController.sharedController.setupStepsCollectionStatisticQuery()
     
     self.queryMiles()
     }
     })
     }
     
     
     */
    
}
