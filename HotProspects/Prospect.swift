//
//  Prospect.swift
//  HotProspects
//
//  Created by Christopher Walter on 6/1/20.
//  Copyright © 2020 Christopher Walter. All rights reserved.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    let id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    // fileprivate(set), which means “this property can be read from anywhere, but only written from the current file”
    
    // Prospect can read and write to Prospects and vice versa because they are in the same File! They are not in the same class, but they are in the same file!
    fileprivate(set) var isContacted = false
//    var isContacted = false
    

}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]

    static let saveKey = "SavedData"
    init() {
        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                self.people = decoded
                return
            }
        }

        self.people = []
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
}
