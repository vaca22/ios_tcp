/*
    Copyright (C) 2018 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Binds a conversation view controller to its transport.
 */

import UIKit

/// Binds a conversation view controller to its transport.  This is a controller
/// that the app delegate creates to move the details of running a conversation
/// off into a separate entity.  The app controller managers a single instance
/// of this but you could imagine a more complex app, where multiple
/// conversations can be on screen at a time, having multiple instances.

class ActiveConversation : ConversationViewController.Delegate {

    /// Creates the object with the specified view controller and transport.
    ///
    /// The created object becomes the delegate for the view controller.
    ///
    /// - Parameters:
    ///   - viewController: The view controller being displayed.
    ///   - transport: The transport which updates that controller.

    init(viewController: ConversationViewController, transport: ConversationTransport) {
        self.viewController = viewController
        self.transport = transport
        self.viewController.delegate = self
    }
    
    /// The value passed to the initialiser.

    let viewController: ConversationViewController

    /// The value passed to the initialiser.

    let transport: ConversationTransport
    
    typealias Delegate = ActiveConversationDelegate

    weak var delegate: Delegate? = nil
    
    /// The client calls this when everything is set up and it wants the object
    /// to start the transport and routing updates between it and the
    /// conversation view controller.
    
    func start() {
        self.viewController.conversation = self.transport.conversation
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(conversationDidChange(note:)),
            name: ConversationTransport.conversationDidChange,
            object: self.transport
        )
        self.transport.start()
    }
    
    /// The client calls this when it wants the object to stop the transport and
    /// to stop routing updates between that and the conversation view
    /// controller.

    func stop() {
        NotificationCenter.default.removeObserver(self)
        self.transport.stop()
    }
    
    func send(message: String, conversationViewController: ConversationViewController) {
        self.transport.send(message: message)
    }
    
    func close(conversationViewController: ConversationViewController) {
        self.delegate?.close(activeConversation: self)
    }
    
    /// Updates the conversation view controller with the latest conversatino
    /// from the transport; call in response to the
    /// `ConversationTransport.conversationDidChange` notification.

    @objc
    private func conversationDidChange(note: Notification) {
        self.viewController.conversation = self.transport.conversation
    }
}

/// Delegate protocol for `ActiveConversation`.

protocol ActiveConversationDelegate : AnyObject {

    /// Called when the user indicates that they want to close the conversation.
    ///
    /// - Parameter activeConversation: The sender.

    func close(activeConversation: ActiveConversation)
}
