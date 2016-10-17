//
//  MatchesViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/14/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class MatchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserMatchingDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        MatchController.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func currentUserDidMatchWith(IDsOf users: [String]) {
        
        var usersArray: [TestUser] = []
        
        for id in users {
            let user = FirebaseController.users.filter({$0.id == id})
            guard let unwrappedUser = user.first else { return }
            usersArray.append(unwrappedUser)
        }
        
        MatchController.allMatches = usersArray

        self.tableView.reloadData()
        
    }
    
    @IBAction func backNavigationButtonTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MatchController.allMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath) as? MatchTableViewCell else { return UITableViewCell() }
        
        let matchingUser = MatchController.allMatches[indexPath.row]
        
        cell.updateWith(user: matchingUser)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
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
