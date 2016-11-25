//
//  LaunchScreenCopyViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 11/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import SystemConfiguration

class LaunchScreenCopyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseController.handleUserInformationScenarios(completion: { (success) in
            
            if !self.isInternetAvailable() {
                self.performSegue(withIdentifier: Identifiers.Segues.noInternetVC.rawValue, sender: self)
            } else {
                let storyboard: UIStoryboard!
                if success {
                    if UserController.userCreationType == "landlord" {
                        storyboard = UIStoryboard(name: "LandlordMain", bundle: nil)
                    } else {
                        storyboard = UIStoryboard(name: "RenterMain", bundle: nil)
                    }
                    let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                    self.present(mainVC, animated: true, completion: nil)
                    
                } else {
                    storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
                    self.present(loginVC, animated: true, completion: nil)
                }
            }
            
        })
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
