//
//  SearchBar.swift
//  GameTime
//
//  Created by Zach Eriksen on 10/13/20.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared
            .sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct SearchBar: View {
    public var onSearch: (String) -> Void
    
    @State private var text: String = ""
    @State private var isEditing: Bool = false
    
    private var isActive: Bool {
        !text.isEmpty || isEditing
    }
    
    private var activeBackgroundColor: Color = Color(.systemGray6)
    private var inactiveBackgroundColor: Color = Color(.systemGray5)
    private var backgroundColor: Color {
        isActive ? activeBackgroundColor : inactiveBackgroundColor
    }
    
    public init(onSearch: @escaping (String) -> Void) {
        self.onSearch = onSearch
    }
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(.systemGray))
                    TextField("Search", text: $text, onCommit:  {
                        onSearch(text)
                        hideKeyboard()
                        isEditing = false
                    })
                    .onTapGesture {
                        isEditing = true
                    }
                    if !text.isEmpty {
                        Button(action: {
                            text = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(.systemGray))
                        }
                    }
                }
                .padding(8)
                .background(backgroundColor)
                .border(backgroundColor, width: 1)
                .cornerRadius(8)
                .animation(.default)
                
                if isEditing {
                    Button("Cancel") {
                        hideKeyboard()
                        isEditing = false
                    }
                    .transition(.move(edge: .trailing))
                    .animation(.default)
                }
            }
            if isActive {
                Button(action: {
                    onSearch(text)
                    hideKeyboard()
                    isEditing = false
                }) {
                    Text("Search").font(.title3)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity,
                       minHeight: 44, maxHeight: 44, alignment: .center)
                .background(Color.blue)
                .cornerRadius(8)
                .padding(8)
                .transition(.move(edge: .trailing))
                .animation(.easeInOut)
            }
        }
        .padding(8)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar {
            print($0)
        }
    }
}
