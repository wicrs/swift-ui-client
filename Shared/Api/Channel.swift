//
//  Channel.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-09.
//

import Foundation

struct Message : Codable {
    let id: UUIDString
    let hub_id: UUIDString
    let channel_id: UUIDString
    let sender: UUIDString
    let created: DateString
    let content: String
}

struct Channel : Codable {
    let id: UUIDString
    let hub_id: UUIDString
    var description: String
    var name: String
    let created: DateString
}
