//
//  View.swift
//  MapItemPicker
//
//  Created by Victor Vaknin Otte Hansen on 07/03/2025.
//
// NOTE: This file is only for previewing the package and should not be implemented in the main code.

import SwiftUI

struct MapItemPickerUITests: View {
    var body: some View {
        Text("MapItemPickerUITests")
            .mapItemPickerSheet(isPresented: .constant(true), action: { _ in })
    }
}

#Preview {
    MapItemPickerUITests()
}
