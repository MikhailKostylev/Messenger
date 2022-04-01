//
//  Media.swift
//  Messenger
//
//  Created by Mikhail Kostylev on 01.04.2022.
//

import Foundation
import MessageKit

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
