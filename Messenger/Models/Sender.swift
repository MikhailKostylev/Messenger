//
//  MessageKind.swift
//  Messenger
//
//  Created by Mikhail Kostylev on 01.04.2022.
//

import Foundation
import MessageKit

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}
