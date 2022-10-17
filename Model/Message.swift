/*
    Copyright (C) 2018 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A model object representing a message in a conversation.
 */

import Foundation

/// A model object representing a message in a conversation.

struct Message {

    /// The text of the message.
    
    var text: String

    /// The date that the message was sent or received.
    
    var date: Date

    /// The direction of the message, either incoming or outgoing.
    
    var direction: Direction
    
    /// Describes the direction of the message.
    ///
    /// - incoming: The message was received by this device.
    /// - outgoing: The message was sent by this device.
    
    enum Direction {
        case incoming
        case outgoing
    }
}
