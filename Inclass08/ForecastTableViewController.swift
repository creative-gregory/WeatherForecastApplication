//
//  ForecastTableViewController.swift
//  Inclass08
//
//  Created by Gregory Hagins II on 3/30/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class Forecast {
    var date:String?
    var temp:Double?
    var min_temp:Double?
    var max_temp:Double?
    var humidity:String?
    var description:String?
    var icon:String?
    
    init(date: String, temp: Double, min_temp: Double, max_temp:Double, humidity:String, description:String, icon:String) {
        self.date = date
        self.temp = temp
        self.min_temp = min_temp
        self.max_temp = max_temp
        self.humidity = humidity
        self.description = description
        self.icon = icon
    }
}

class ForecastTableViewController: UIViewController {
    var forecastArray = [Forecast]()
    @IBOutlet weak var ForecastTable: UITableView!
    @IBOutlet weak var cityLabel: UILabel!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var activityState:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.color = .systemPurple
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.addSubview(activityIndicator)
        
        let forecastNib = UINib(nibName: "ForecastTableViewCell", bundle: nil)
        ForecastTable.register(forecastNib, forCellReuseIdentifier: "Forecast")
    }
    
    func activityIndc() {
        if activityState == false {
//            overlayView.isHidden = false
            activityIndicator.startAnimating()
            self.ForecastTable.isHidden = true
            self.cityLabel.isHidden = true
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {(timer) in
                self.activityState = true
                self.activityIndicator.isHidden = true
                self.ForecastTable.isHidden = false
                self.cityLabel.isHidden = false
                
                self.activityIndicator.stopAnimating()
//                self.overlayView.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onReceivedNotification(notification :)), name: Notification.Name("CityForecast"), object: nil)
        activityIndc()
    }
    
    @objc func onReceivedNotification(notification: Notification) {
        let currentCity = (notification.object! as! [String])
        print(checkForWhiteSpace(input: currentCity[0]))
        
        cityLabel.text = currentCity[0] + ", " + currentCity[1]
        getForecast(city: checkForWhiteSpace(input: currentCity[0]), country: currentCity[1])
    }
    
    func getForecast(city: String, country: String) {
        AF.request("http://api.openweathermap.org/data/2.5/forecast?q=\(city),\(country)&APPID=\(APIKey().apiKey)").responseJSON(completionHandler: {(response) in
            let forecastData = JSON(response.value!)
            let forecastDataArray = forecastData["list"].arrayValue
            
            for (_, element) in forecastDataArray.enumerated() {
                let forecastProfile = Forecast(date: element["dt_txt"].stringValue, temp: element["main"]["temp"].doubleValue, min_temp: element["main"]["temp_min"].doubleValue, max_temp: element["main"]["temp_max"].doubleValue, humidity: element["main"]["humidity"].stringValue, description: element["weather"][0]["description"].stringValue, icon: element["weather"][0]["icon"].stringValue)
                
                self.forecastArray.append(forecastProfile)
                //                print(element["main"]["temp"])
                //                print(index)
                self.ForecastTable.reloadData()
            }
            
//            print(self.forecastArray[0].description!)
//            print(self.forecastArray[0].date!, self.forecastArray[0].temp!, self.forecastArray[0].max_temp!, self.forecastArray[0].min_temp!, self.forecastArray[0].humidity!, self.forecastArray[0].description!)
        })
        
    }
        
       func checkForWhiteSpace(input: String) -> String {
           var result:String = input
           var index:Int = 0
           var whiteSpaceIndex:Int = 0
           
           for letter in input {
               if letter == " " {
                   whiteSpaceIndex = index
               }
               index = index + 1
           }
           
           if whiteSpaceIndex != 0 {
               result.insert("%", at: result.index(result.startIndex, offsetBy: whiteSpaceIndex))
               result.insert("2", at: result.index(result.startIndex, offsetBy: whiteSpaceIndex + 1))
               result.insert("0", at: result.index(result.startIndex, offsetBy: whiteSpaceIndex + 2))
               result.remove(at: result.index(result.startIndex, offsetBy: whiteSpaceIndex + 3))
           }
           
           return result
       }
    
    func convertKelvintoFarh(TempInKelvin: Double) -> Double {
        let result = ((TempInKelvin - 273.15) * (1.8)) + 32
        
        return result
    }
}

extension ForecastTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Forecast", for: indexPath) as! ForecastTableViewCell
        
        let currentForecastProfile = forecastArray[indexPath.row]
        
        cell.dateLabel.text = currentForecastProfile.date!
        cell.currentTempLabel.text = String(format: "%0.01f", convertKelvintoFarh(TempInKelvin: currentForecastProfile.temp!)) + " F"
        cell.maxTempLabel.text = "Max: " + String(format: "%0.01f", convertKelvintoFarh(TempInKelvin: currentForecastProfile.max_temp!)) + " F"
        cell.minTempLabel.text = "Min: " + String(format: "%0.01f", convertKelvintoFarh(TempInKelvin: currentForecastProfile.min_temp!)) + " F"
        cell.humidityLabel.text = "Humidity: " + currentForecastProfile.humidity! + "%"
        cell.conditionLabel.text = currentForecastProfile.description!.capitalized
        
//        AF.request("http://openweathermap.org/img/wn/\(currentForecastProfile.icon!)@2x.png").responseImage { response in
//            if case .success(let image) = response.result {
////                print("image downloaded: \(image)")
//                cell.conditionImageView.image = image
//            }
//        }
        let url = URL(string: "http://openweathermap.org/img/wn/\(currentForecastProfile.icon!)@2x.png")
        cell.conditionImageView.af.setImage(withURL: url!)

        return cell
    }
}

extension ForecastTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

