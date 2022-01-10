//
//  Channel.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-09.
//

import Foundation

public struct Message {
    public let id: UUID
    public let hub_id: UUID
    public let channel_id: UUID
    public let sender: UUID
    public let created: Date
    public let content: String
}

public struct Channel {
    public let id: UUID
    public let hub_id: UUID
    public var description: String
    public var name: String
    public let created: Date
}
