//
//  CitiesTableViewController.swift
//  Inclass08
//
//  Created by Gregory Hagins II on 3/23/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit

class CitiesTableViewController: UITableViewController {

    let weatherData = AppData.init().cities
    let countries = Array(AppData.init().cities.keys).sorted()
    var selectedCity:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(weatherData.keys.count)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentCountry = countries[section]

        return currentCountry
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        let countrySection = countries[section]

        return weatherData[countrySection]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cities", for: indexPath)

        let currentSection = indexPath.section

        let countrySection = countries[currentSection]
        let citiesOfCountry = weatherData[countrySection]!
        let cityName = citiesOfCountry[indexPath.row]

        cell.textLabel?.text = cityName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = .systemPurple
//            headerView.backgroundView?.backgroundColor = .black
            headerView.textLabel?.textColor = .white
        }
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let countrySection = countries[indexPath.section]
        
        selectedCity = weatherData[countrySection]![indexPath.row]
        
        let dataToSend = [selectedCity, countrySection]
        print("Section: \(indexPath.section), Key: \(countries[indexPath.section])")
        print("Row: \(indexPath.row), Value: \(weatherData[countrySection]![indexPath.row])")
        
        let delayTime:Double = 0.05
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
            NotificationCenter.default.post(name: Notification.Name("City"), object: dataToSend)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
