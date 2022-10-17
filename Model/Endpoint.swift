/*
    Copyright (C) 2018 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A model-level object that describes how to make a TCP connection.
 */

import Foundation

/// A model-level object that describes how to make a TCP connection.  This
/// includes the transport to use, the name and port to connect to, and where
/// to use TLS.
///
/// This type is codable because the app uses it to save and restore the state
/// of the UI.  If you change this type you’re likely to invalidate that state,
/// which isn’t a big deal with certainly worth thinking about.

struct Endpoint : Codable {

    /// Describes all the known transports.
    ///
    /// - important: Before changing these values, see the comments associated
    ///   with `EndpointPicker`.
    ///
    /// - socketStream: Use `SocketStreamTransport`.
    /// - streamTask: Use `StreamTaskTransport`.
    /// - bsdSockets: Use `BSDSocketsTransport`.
    /// - nwTCPConnection: Use `NWTCPTransport`.
    
    enum Transport : Int, Codable {
        case socketStream
        case streamTask
        case bsdSockets
        case nwTCPConnection
    }

    /// The transport to use.
    
    var transport: Transport

    /// The host to connect to.  This can be a numeric IP address, either IPv4
    /// or IPv6.
    
    var hostName: String

    /// THe port on which to connect.
    
    var port: Int

    /// True if the connection should use TLS.
    
    var useTLS: Bool

    /// A reasonable ’nil’ value for situations where a default value is needed
    /// but `nil` is not allowed.
    
    static var empty: Endpoint = Endpoint(transport: .socketStream, hostName: Endpoint.defaultHostName, port: 12345, useTLS: false)
    
    /// The host name to use in the `empty` value.  This is here because I want
    /// to return different results on the simulator versus a real device.
    
    private static var defaultHostName: String = {
        #if arch(i386) || arch(x86_64)
            return "127.0.0.1"          // On the simulator it makes sense to default to localhost.
        #else
            return "guy-smiley.local"   // My machine!
        #endif
    }()
}

extension ConversationTransport {

    /// Creates an object that uses a transport configured by `endpoint`.
    ///
    /// - Parameter endpoint: Specifies the transport to use and various
    ///     parameters for that transport.
    /// - Throws: An error if the transport doesn’t support the configuration in
    ///     `endpoint`.

    convenience init(endpoint: Endpoint) throws {
        let transport = try ConversationTransport.transport(for: endpoint)
        self.init(localizedName: endpoint.hostName, transport: transport)
    }

    /// Creates a `TCPTransport` for the specified endpoint.
    ///
    /// This is exported for the benefit of our test code.  The app itself
    /// creates a `ConversationTransport` object directly via its initialiser.
    ///
    /// - Parameter endpoint: Specifies the transport to use and various
    ///     parameters for that transport.
    /// - Returns: The transport itself.
    /// - Throws: An error if the transport doesn’t support the configuration in
    ///     `endpoint`.

    static func transport(for endpoint: Endpoint) throws -> TCPTransport {
        let transport: TCPTransport
        switch endpoint.transport {
        case .socketStream:
            transport = SocketStreamTransport(hostName: endpoint.hostName, port: endpoint.port, useTLS: endpoint.useTLS, queue: .main)
        case .streamTask:
            transport = StreamTaskTransport(hostName: endpoint.hostName, port: endpoint.port, useTLS: endpoint.useTLS, queue: .main)
        case .bsdSockets:
            transport = try BSDSocketsTransport(numericAddress: endpoint.hostName, port: endpoint.port, useTLS: endpoint.useTLS, queue: .main)
        case .nwTCPConnection:
            transport = try NWTCPTransport(hostName: endpoint.hostName, port: endpoint.port, useTLS: endpoint.useTLS, queue: .main)
        }
        return transport
    }
}

