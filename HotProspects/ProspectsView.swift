//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Christopher Walter on 6/1/20.
//  Copyright © 2020 Christopher Walter. All rights reserved.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    // This enum is used, so that we can have multiple types of versions of this view. on different tabs
    enum FilterType {
        case none, contacted, uncontacted
    }
    let filter: FilterType
    
    // this will filter the prospects being displayed
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    @EnvironmentObject var prospects: Prospects
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    // to turn on QR Scanner
    @State private var isShowingScanner = false
    
    var body: some View {
        NavigationView {
           List {
                ForEach(filteredProspects) { prospect in
                    HStack {
                        if prospect.isContacted && self.filter == .none {
                            Image(systemName: "checkmark.circle")
                        }
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    .contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted" ) {
                            self.prospects.toggle(prospect)

                        }
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                }
                
               
            
            }
                .navigationBarTitle(title)
        
            .navigationBarItems(leading: Button(action: {
                // toggle sortByName I could not think of a better way to do this. Try to figure out how to do it with Encapsulation
                Prospects.sortByName = !Prospects.sortByName
            }){
                Image(systemName: "arrow.up.arrow.down.square")
                Text(Prospects.sortByName ? "Name": "Most Recent")
                },trailing: Button(action: {
//                    let prospect = Prospect()
//                    prospect.name = "Paul Hudson"
//                    prospect.emailAddress = "paul@hackingwithswift.com"
//                    self.prospects.people.append(prospect)
                    self.isShowingScanner = true
                }) {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                })
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: self.handleScan)
            }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.isShowingScanner = false
       // more code to come
        
        switch result {
        case .success(let code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]

            self.prospects.add(person)
            
        case .failure(let error):
            print("Scanning failed")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.hour = 9 // this will cause notification to trigger next time 9 am comes about
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // use this for testing. Will send notification in 5 seconds
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        // more code to come
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()

            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                        
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
