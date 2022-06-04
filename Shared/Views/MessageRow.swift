//
//  MessageRow.swift
//  WICRS Client
//
//  Created by Willem on 2022-03-08.
//

import SwiftUI

struct MessageRow: View, Identifiable {
    let id: Int
    
    var message: Message
    
    var body: some View {
        HStack {
            Text("\(get_nick(id: message.sender, hub_id: message.hub_id)) > ").font(.system(.body,design: .monospaced))
            Text(message.content)
            Spacer()
        }
#if os(macOS)
        .background(Color(nsColor: id % 2 == 0 ? .alternatingContentBackgroundColors[0] : .alternatingContentBackgroundColors[1]))
#else
        .background(Color(id % 2 == 0 ? UIColor.systemBackground : UIColor.secondarySystemBackground))
#endif
    }
}

func get_nick(id: UUIDString, hub_id: UUIDString) -> String {
    if let nick = try? HubLoader.shared.loadNickFromRemote(server: AppConfig.server, hub_id: hub_id, member_id: id) {
        return nick
    } else {
        return id.prefix(8).description
    }
}

struct MessageRow_Previews: PreviewProvider {
    static var previews: some View {
        MessageRow(id:0, message: create_preview_message())
    }
}
