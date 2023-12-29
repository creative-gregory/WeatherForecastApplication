//
//  API_KEY.swift
//  Inclass08
//
//  Created by Gregory Hagins II on 12/28/23.
//  Copyright © 2023 Gregory Hagins II. All rights reserved.
//

import Foundation

struct APIKey {
    var apiKey: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "API_KEY-Info", ofType: "plist") else {
                fatalError("Couldn't find file 'API_KEY-Info.plist'.")
            }
            
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "API_KEY") as? String else {
                fatalError("Couldn't find key 'API_KEY' in 'API_KEY-Info.plist'.")
            }
            
            return value
        }
    }
}
