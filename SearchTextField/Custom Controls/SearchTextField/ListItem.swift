//
//  ListItem.swift
//  SearchTextField
//
//  Created by Rishu Gupta on 05/12/20.
//

import Foundation

struct ListItem {
    var id: String
    var name: String
    var icon: String?

    init(id: String, name: String, icon: String? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
    }

}
