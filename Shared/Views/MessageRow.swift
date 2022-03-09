//
//  MessageRow.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-03-08.
//

import SwiftUI

struct MessageRow: View, Identifiable {
    let id: Int
    
    var message: Message
    
    var body: some View {
        HStack {
            Text("\(message.sender.prefix(8).description) > ").font(.system(.body,design: .monospaced))
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

struct MessageRow_Previews: PreviewProvider {
    static var previews: some View {
        MessageRow(id:0, message: create_preview_message())
    }
}
