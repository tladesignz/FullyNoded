//
//  FirstTime.swift
//  BitSense
//
//  Created by Peter on 05/04/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class FirstTime {
    
    static let sharedInstance = FirstTime()
    
    func firstTimeHere() {
        print("firstTimeHere")
        
        //KeychainWrapper.standard.removeAllKeys()
        
        if UserDefaults.standard.object(forKey: "firstTime") == nil {
            
            UserDefaults.standard.set("500", forKey: "miningFee")
            
            func randomString(length: Int) -> String {
                
                let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                return String((0...length-1).map{ _ in letters.randomElement()! })
                
            }
            
            let password = randomString(length: 32)
            
            let saveSuccessful:Bool = KeychainWrapper.standard.set(password, forKey: "AESPassword")
            
            if saveSuccessful {
                
                print("Encryption key saved successfully: \(saveSuccessful)")
                
            } else {
                
                print("error saving encryption key")
                
            }
            
            UserDefaults.standard.set(true, forKey: "firstTime")
            
        }
        
    }
    
}

