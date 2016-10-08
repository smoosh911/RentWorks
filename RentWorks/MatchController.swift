//
//  MatchController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MatchController {
    
    static func observeMatchesFor(user: TestUser) {
        
        FirebaseController.matchesRef.child(user.id).observe(FIRDataEventType.value, with: { (snapshot)in

            print(snapshot.value)
            
            
        })
        
    }
    
    
}
