//
//  Profile.swift
//  Messenger
//
//  Created by Mikhail Kostylev on 01.04.2022.
//

import Foundation

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}

enum ProfileViewModelType {
    case info, logout
}
