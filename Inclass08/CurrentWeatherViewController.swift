//
//  CurrentWeatherViewController.swift
//  Inclass08
//
//  Created by Gregory Hagins II on 3/23/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
//import Foundation

class Weather {
    var temp:Double?
    var min_temp:Double?
    var max_temp:Double?
    var humidity:String?
    var description:String?
    var wind_speed:String?
    var wind_degree:String?
    var cloudiness:String?
    var icon:String?
    
    init(temp: Double, min_temp: Double, max_temp:Double, humidity:String, description:String, wind_speed:String, wind_degree:String, cloudi: String, icon: String) {
        self.temp = temp
        self.min_temp = min_temp
        self.max_temp = max_temp
        self.humidity = humidity
        self.description = description
        self.wind_speed = wind_speed
        self.wind_degree = wind_degree
        self.cloudiness = cloudi
        self.icon = icon
    }
}

class CurrentWeatherViewController: UIViewController {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var activityState:Bool = false
    
    @IBOutlet weak var forcastButton: UIButton!
    
    @IBOutlet weak var conditionImageView: UIImageView!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var humLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var cloudLabel: UILabel!
    
    @IBOutlet weak var overlayView: UIImageView!
    
    var city = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.color = .systemPurple
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onReceivedNotification(notification :)), name: Notification.Name("City"), object: nil)
    }
    
    @objc func onReceivedNotification(notification: Notification) {
        let currentCity = (notification.object! as! [String])
        cityLabel.text = "\(currentCity[0]), \(currentCity[1])"
        
        city = currentCity
        print(checkForWhiteSpace(input: currentCity[0]))
        
        getWeather(city: checkForWhiteSpace(input: currentCity[0]), country: currentCity[1])
    }
    
    func activityIndc() {
        if activityState == false {
            overlayView.isHidden = false
            conditionImageView.isHidden = true
            forcastButton.isHidden = true
            activityIndicator.startAnimating()
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {(timer) in
                self.activityState = true
                self.activityIndicator.isHidden = true
                
                self.activityIndicator.stopAnimating()
                self.overlayView.isHidden = true
                self.conditionImageView.isHidden = false
                self.forcastButton.isHidden = false
            }
        }
    }
    
    @IBAction func forecastButton(_ sender: Any) {
        let delayTime:Double = 0.05
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
            NotificationCenter.default.post(name: Notification.Name("CityForecast"), object: self.city)
        }
    }
    
    func getWeather(city: String, country: String) {
        AF.request("http://api.openweathermap.org/data/2.5/weather?q=\(city),\(country)&APPID=\(APIKey().apiKey)").responseJSON(completionHandler: {(response) in
            //            print(response.value!)
            //            print(response.result)
            
            let weatherData = JSON(response.value!)
            let description = weatherData["weather"][0]["description"].stringValue.capitalized

            let weatherProfile = Weather(temp: weatherData["main"]["temp"].doubleValue, min_temp: weatherData["main"]["temp_min"].doubleValue, max_temp: weatherData["main"]["temp_max"].doubleValue, humidity: weatherData["main"]["humidity"].stringValue, description: description, wind_speed: weatherData["wind"]["speed"].stringValue, wind_degree: weatherData["wind"]["deg"].stringValue, cloudi: weatherData["clouds"]["all"].stringValue, icon: weatherData["weather"][0]["icon"].stringValue)

//            print(weatherData["name"])  // check proper city

            self.tempLabel.text = String(format: "%0.01f", self.convertKelvintoFarh(TempInKelvin: weatherProfile.temp!)) + " F"
            self.maxLabel.text = String(format: "%0.01f", self.convertKelvintoFarh(TempInKelvin: weatherProfile.max_temp!)) + " F"
            self.minLabel.text = String(format: "%0.01f", self.convertKelvintoFarh(TempInKelvin: weatherProfile.min_temp!)) + " F"
            self.humLabel.text = weatherProfile.humidity! + "%"
            self.descLabel.text = weatherProfile.description!
            self.speedLabel.text = String(format: "%0.01f", (weatherProfile.wind_speed! as NSString).doubleValue) + " MPH"
            self.windLabel.text = String(format: "%3.01f", (weatherProfile.wind_degree! as NSString).doubleValue) + "°"
            self.cloudLabel.text = weatherProfile.cloudiness! + "%"
            
//            AF.request("http://openweathermap.org/img/wn/\(weatherProfile.icon!)@2x.png").responseImage { response in
//                if case .success(let image) = response.result {
////                    print("image downloaded: \(image)")
//                    self.conditionImageView.image = image
//                }
//            }
            
            let url = URL(string: "http://openweathermap.org/img/wn/\(weatherProfile.icon!)@2x.png")
            self.conditionImageView.af.setImage(withURL: url!)
        })
        

        activityIndc()
    }
    
    func convertKelvintoFarh(TempInKelvin: Double) -> Double {
        let result = ((TempInKelvin - 273.15) * (1.8)) + 32
        
        return result
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
}
