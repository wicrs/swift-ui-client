//
//  HubRow.swift
//  WICRS Client
//
//  Created by Willem on 2022-01-20.
//

import SwiftUI

struct HubRow: View {
    @Binding var hub: Hub
    @State private var showingAlert = false
    
    var body: some View {
        HStack {
            Text(hub.name).help(hub.description)
            Spacer()
            Button {
                showingAlert = true
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(PlainButtonStyle())
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Hub ID"),
                    message: Text(hub.id),
                    dismissButton: .default(Text("Done"))
                )
            }
        }
    }
}

#if (DEBUG)
struct HubRow_Previews: PreviewProvider {
    static var previews: some View {
        HubRowPreviewWrapper()
    }
}

struct HubRowPreviewWrapper: View {
    @State var hub = create_preview_hub()
    var body: some View {
        HubRow(hub: $hub)
    }
}
#endif
