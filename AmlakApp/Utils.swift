//
//  Utils.swift
//  AmlakApp
//
//  Created by nader on 6/31/1402 AP.
//

import Foundation


func clearFarsiText(inputText: String) -> String{
    var searchText = inputText
    searchText = searchText.replacingOccurrences(of: "ي", with: "ی")
    searchText = searchText.replacingOccurrences(of: "ك", with: "ک")
    searchText = searchText.replacingOccurrences(of: "۰", with: "0")
    searchText = searchText.replacingOccurrences(of: "۱", with: "1")
    searchText = searchText.replacingOccurrences(of: "۲", with: "2")
    searchText = searchText.replacingOccurrences(of: "۳", with: "3")
    searchText = searchText.replacingOccurrences(of: "۴", with: "4")
    searchText = searchText.replacingOccurrences(of: "۵", with: "5")
    searchText = searchText.replacingOccurrences(of: "۶", with: "6")
    searchText = searchText.replacingOccurrences(of: "۷", with: "7")
    searchText = searchText.replacingOccurrences(of: "۸", with: "8")
    searchText = searchText.replacingOccurrences(of: "۹", with: "9")
    
    searchText = searchText.replacingOccurrences(of: "٠", with: "0")
    searchText = searchText.replacingOccurrences(of: "١", with: "1")
    searchText = searchText.replacingOccurrences(of: "٢", with: "2")
    searchText = searchText.replacingOccurrences(of: "٣", with: "3")
    searchText = searchText.replacingOccurrences(of: "٤", with: "4")
    searchText = searchText.replacingOccurrences(of: "٥", with: "5")
    searchText = searchText.replacingOccurrences(of: "٦", with: "6")
    searchText = searchText.replacingOccurrences(of: "٧", with: "7")
    searchText = searchText.replacingOccurrences(of: "٨", with: "8")
    searchText = searchText.replacingOccurrences(of: "٩", with: "9")
    return searchText;
}
