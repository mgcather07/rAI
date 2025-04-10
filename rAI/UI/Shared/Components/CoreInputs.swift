//
//  CoreInputs.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import SwiftUI

// MASTER -> Toggle-able.
public struct CoreInputText : View {
    @State public var label: String = ""
    @Binding public var text: String
    @Binding public var isEdit: Bool
    
    public init(label: String, text: Binding<String>, isEdit: Binding<Bool>) {
        self.label = label
        self._text = text
        self._isEdit = isEdit
    }
    
    public var body: some View {
        if !isEdit {
            TextLabel(label, text: text)
        } else {
            CoreTextField(label, text: $text)
        }
    }
}

// Master VIEW MODE
public struct TextLabel: View {
    @State public var title: String
    @State public var subtitle: String
    
    public init(_ title: String, text: String) {
        self.title = title
        self.subtitle = text
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.trailing)
            Spacer()
            Text(subtitle)
                .font(.headline)
                .foregroundColor(.white)
        }
        .onAppear() {
            if subtitle.isEmpty {
                self.subtitle = "Empty"
            }
        }
    }
}

// Edit Mode.
public struct CoreTextField: View {
    @Binding var text: String
    var onChange: (String) -> Void
    var placeholder: String = ""
    @Binding var isEditable: Bool // Add this line to bind an external state for edit/view mode.
    @Environment(\.colorScheme) var colorScheme

    public init(_ placeholder: String, text: Binding<String>, isEditable: Binding<Bool>, onChange: @escaping (String) -> Void = { _ in }) {
        self._text = text
        self._isEditable = isEditable // Initialize it here.
        self.placeholder = placeholder
        self.onChange = onChange
    }
    
    public init(_ placeholder: String, text: Binding<String>, onChange: @escaping (String) -> Void = { _ in }) {
        self._text = text
        self._isEditable = .constant(true) // Initialize it here.
        self.placeholder = placeholder
        self.onChange = onChange
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            
            TextField("", text: $text)
                .font(.headline)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Spacer()
                        if !text.isEmpty && isEditable {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 15)
                                .onTapGesture {
                                    self.text = ""
                                }.zIndex(10.0)
                        }
                    }
                )
                .transition(.scale)
                .animation(.easeInOut, value: text)
                .onChange(of: text) { newValue in
                    onChange(newValue) // Call onChange when text changes
                }
                
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, 15)
                    .transition(.move(edge: .leading))
            }
        }
    }
}

public struct InputTextMultiLine: View {
    @Binding var text: String
    var placeholder: String
    var title: String
    var color: Color
    @Binding var isEdit: Bool
    @Environment(\.colorScheme) var colorScheme

    public init(_ placeholder: String, text: Binding<String>, color: Color = .white) {
        self._text = text
        self.placeholder = placeholder
        self.title = placeholder
        self.color = color
        self._isEdit = .constant(false)
    }
    
    public init(_ placeholder: String, text: Binding<String>, color: Color = .white, isEdit: Binding<Bool>) {
        self._text = text
        self.placeholder = placeholder
        self.title = placeholder
        self.color = color
        self._isEdit = isEdit
    }

    public var body: some View {
        
        if !isEdit {
            TextLabel(self.title, text: text)
        } else {
            VStack {
                
                AlignLeft {
                    Text(placeholder)
                        .foregroundColor(.blue)
                }
               
                ZStack(alignment: .topLeading) {
                    
                    TextEditor(text: $text)
                        .foregroundColor(.white)
                        .padding(10)
                        .animation(.easeInOut, value: text)
                        
                    
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .padding(.top, 15)
                            .padding(.leading, 20)
                            .transition(.move(edge: .leading))
                    }

                }
                .overlay(
                   RoundedRectangle(cornerRadius: 10)
                    .stroke(.white, lineWidth: 1)
                )
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 0)
            }
            .frame(minHeight: 125)
            .padding(.top)
            
        }
        
        
    }
}

