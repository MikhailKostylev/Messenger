//
//  ChatAppUser.swift
//  Messenger
//
//  Created by Mikhail Kostylev on 01.04.2022.
//

import Foundation

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        //        joe-gmail-com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}
