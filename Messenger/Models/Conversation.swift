//
//  Conversation.swift
//  Messenger
//
//  Created by Mikhail Kostylev on 01.04.2022.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}
