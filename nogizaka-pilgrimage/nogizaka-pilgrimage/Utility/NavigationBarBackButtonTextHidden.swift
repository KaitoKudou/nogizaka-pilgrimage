//
//  NavigationBarBackButtonTextHidden.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/20.
//

import SwiftUI

struct NavigationBarBackButtonTextHidden: ViewModifier {
  @Environment(\.presentationMode) var presentation

  func body(content: Content) -> some View {
    content
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: { presentation.wrappedValue.dismiss() }) {
            Image(systemName: "chevron.backward")
                  .foregroundStyle(.white)
          }
        }
      }
  }
}

extension View {
  func navigationBarBackButtonTextHidden() -> some View {
    return self.modifier(NavigationBarBackButtonTextHidden())
  }
}

