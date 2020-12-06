//
//  SearchField.swift
//  StatusBuddy
//
//  Created by Gui Rambo on 05/12/20.
//

import Cocoa
import SwiftUI

struct SearchField: NSViewRepresentable {
    
    @Binding var searchTerm: String
    
    typealias NSViewType = CustomSearchField
    
    func makeNSView(context: Context) -> CustomSearchField {
        let field = CustomSearchField()
        
        field.delegate = context.coordinator
        field.placeholderString = "Search"
        
        return field
    }
    
    func updateNSView(_ nsView: CustomSearchField, context: Context) {
        nsView.stringValue = searchTerm
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}

extension SearchField {
    
    final class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: SearchField
        
        init(_ parent: SearchField) {
            self.parent = parent
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            handleFieldNotification(obj)
        }
        
        func controlTextDidChange(_ obj: Notification) {
            handleFieldNotification(obj)
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            handleFieldNotification(obj)
        }
        
        private func handleFieldNotification(_ note: Notification) {
            guard let field = note.object as? NSSearchField else { return }
            
            parent.searchTerm = field.stringValue
        }
    }
    
}

final class CustomSearchField: NSSearchField {
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        guard let window = window else { return }
        
        NotificationCenter.default.addObserver(forName: NSWindow.didBecomeKeyNotification, object: window, queue: .main) { [weak self] note in
            guard let self = self else { return }
            
            guard note.object as? NSWindow == self.window else { return }
            
            self.window?.makeFirstResponder(self)
        }
    }
    
}
