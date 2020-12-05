//
//  ViewController.swift
//  SearchTextField
//
//  Created by Rishu Gupta on 05/12/20.
//

import UIKit

enum OccasionType: CaseIterable {
    case Birthday
    case Wedding
    case Reception
    case Sangeet
    case MehendiSangeet
    case GetTogether
    case BabyShower
    case BabyNaming
    case Engagement
    case Anniversary
    case Other
    
    var name: String {
        switch self {
        case .Birthday:
            return "Birthday"
        case .Wedding:
            return "Wedding"
        case .Reception:
            return "Reception"
        case .Sangeet:
            return "Sangeet"
        case .MehendiSangeet:
            return "Mehendi/ Sangeet"
        case .GetTogether:
            return "Get Together"
        case .BabyShower:
            return "Baby Shower"
        case .BabyNaming:
            return "Baby Naming"
        case .Engagement:
            return "Engagement"
        case .Anniversary:
            return "Anniversary"
        case .Other:
            return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .Birthday:
            return "ic_birthday"
        case .Wedding:
            return "ic_wedding"
        case .Reception:
            return "ic_reception"
        case .Sangeet:
            return "ic_sangeet"
        case .MehendiSangeet:
            return "ic_mehendi"
        case .GetTogether:
            return "ic_get_together"
        case .BabyShower:
            return "ic_baby_shower"
        case .BabyNaming:
            return "ic_baby_naming"
        case .Engagement:
            return "ic_engagement"
        case .Anniversary:
            return "ic_anniversary_new"
        case .Other:
            return "ic_birthday"
        }
    }
    
}

class ViewController: UIViewController {

    // MARK:- IBOutlets
    @IBOutlet weak var textFieldLocation : SearchTextField!
    @IBOutlet weak var textFieldOccasion : SearchTextField!
    
    // MARK:- Variables
    var locations : [ListItem] {
        let cities = [ListItem(id: UUID().uuidString, name: "Mumbai"),
                      ListItem(id: UUID().uuidString, name: "Delhi"),
                      ListItem(id: UUID().uuidString, name: "Bangalore"),
                      ListItem(id: UUID().uuidString, name: "Hyderabad"),
                      ListItem(id: UUID().uuidString, name: "Ahmedabad"),
                      ListItem(id: UUID().uuidString, name: "Chennai"),
                      ListItem(id: UUID().uuidString, name: "Kolkata"),
                      ListItem(id: UUID().uuidString, name: "Surat"),
                      ListItem(id: UUID().uuidString, name: "Pune"),
                      ListItem(id: UUID().uuidString, name: "Jaipur"),
                      ListItem(id: UUID().uuidString, name: "Lucknow"),
                      ListItem(id: UUID().uuidString, name: "Bhopal"),
                      ListItem(id: UUID().uuidString, name: "Visakhapatnam"),
                      ListItem(id: UUID().uuidString, name: "Patna"),
                      ListItem(id: UUID().uuidString, name: "Vadodara"),
                      ListItem(id: UUID().uuidString, name: "Agra"),
                      ListItem(id: UUID().uuidString, name: "Varanasi"),
                      ListItem(id: UUID().uuidString, name: "Raipur"),
                      ListItem(id: UUID().uuidString, name: "Chandigarh")
        ]
        return cities
    }
    var occasions : [ListItem] {
        return OccasionType.allCases.compactMap { (occasion) -> ListItem? in
            return ListItem(id: UUID().uuidString, name: occasion.name, icon: occasion.icon)
        }
    }
    
    
    // MARK:- View LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.initialSetup()
    }

    
    // MARK:- Private Methods
    private func initialSetup() {
        self.title = "Custom Search"
        self.textFieldLocation.customDelegate = self
        self.textFieldOccasion.customDelegate = self
        
        // Set isSearchEnable = false to disable searching in textfield and display dropdown as default
        self.textFieldOccasion.isSearchEnable = false
        
        // Set data source for textfield dropdown list
        self.textFieldLocation.dataList = self.locations
        self.textFieldOccasion.dataList = self.occasions
        
    }

}

//MARK:- Search Textfield delegates
extension ViewController: SearchTextFieldDelegate {
    
    func didSelect(_ textField: SearchTextField, _ item: ListItem) {
        if textField == textFieldLocation {
            print("Selected Location:", item.name)
        } else if textField == textFieldOccasion {
            print("Selected Occasion:", item.name)
        }
    }
    
}
