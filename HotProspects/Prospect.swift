//
//  Prospect.swift
//  HotProspects
//
//  Created by Christopher Walter on 6/1/20.
//  Copyright © 2020 Christopher Walter. All rights reserved.
//

import SwiftUI

class Prospect: Identifiable, Codable, Comparable {

    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    // fileprivate(set), which means “this property can be read from anywhere, but only written from the current file”
    var created = Double(Date().timeIntervalSince1970)
    
    // Prospect can read and write to Prospects and vice versa because they are in the same File! They are not in the same class, but they are in the same file!
    fileprivate(set) var isContacted = false
//    var isContacted = false
    
    static func < (lhs: Prospect, rhs: Prospect) -> Bool {
        if Prospects.sortByName {
            return lhs.name < rhs.name
        }
        else
        {
            return lhs.created < rhs.created
        }
        
    }
    
    static func == (lhs: Prospect, rhs: Prospect) -> Bool {
        return lhs.name == rhs.name && lhs.emailAddress == rhs.emailAddress
    }
    
    // I do not need to specify how to encode and decode this data. Not sure why not, but it is working out just fine without it, so i commented it out.
    
    // make this enum to help with encoding and decoding
//    enum CodingKeys: CodingKey {
//        case name, id, emailAddress
//    }
//
//    public required init(from decoder: Decoder) throws {
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        name = try container.decode(String.self, forKey: .name)
//        id = try container.decode(UUID.self, forKey: .id)
//        emailAddress = try container.decode(String.self, forKey: .emailAddress)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//        try container.encode(emailAddress, forKey: .emailAddress)
//        try container.encode(id, forKey: .id)
//
//    }
    
    

}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]

    static var sortByName = true // we will either sort by name or by createdDate.
    static let saveKey = "SavedData"
    init() {
        // this snippet is for Loading from User defaults. I switched to Documents Directory as part of a challenge
//        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
//            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
//                self.people = decoded
//                return
//            }
//        }
//
//        self.people = []
        self.people = []
        
        loadData() // this will load the people/ sort them if possible
    }
    
    // this will save to userDefaults
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }
    
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
//        save()
        saveData()
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
//        save()
        saveData()
    }
    
    
    private func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    //        print(paths[0])
            return paths[0]
        }
    // this will load from documents directory. I added this for one of the challenges
    private func loadData() {
        print("loading")
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPeople")

        do {
            let data = try Data(contentsOf: filename)
            people = try JSONDecoder().decode([Prospect].self, from: data).sorted()
            print("load successful")
        } catch {
            print(error)
            print("Unable to load saved data.")
        }
    }
        
    private func saveData() {
        print("saving")
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPeople")
            people = people.sorted()
            let data = try JSONEncoder().encode(self.people)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            print("save successful")
        } catch {
            print("Unable to save data.")
        }
    }
}
