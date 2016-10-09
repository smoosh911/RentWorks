//
//  ImageController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/9/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class ImageController {
    
    static func imageFor(url: String, completion: @escaping ((_ image: UIImage?) -> Void)) {
        
        guard let url = URL(string: url) else { fatalError("Image URL optional is nil") }
        
        NetworkController.performRequestForURL(url: url, httpMethod: .Get) { (data, error) in
            
            guard let data = data else { completion(nil); return }
            
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
    }
    
}
