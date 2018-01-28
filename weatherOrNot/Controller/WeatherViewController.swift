//
//  ViewController.swift
//  weatherOrNot
//
//  Created by Alex Votry on 1/21/18.
//  Copyright © 2018 Alex Votry. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, ChangeCityDelegate {
    
    //constants
    let WEATHER_URL = "http://api.wunderground.com/api/c5f6dc09f77c887d/"
    let ICON_URL = "http://icons.wxug.com/i/c/j/"
    let weather = WeatherDataModel()
    var currentCity = "Edmonds"
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var rainFall: UILabel!
    @IBOutlet weak var WeatherIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getConditionsNow(url: "\(WEATHER_URL)conditions/q/WA/\(currentCity).json")
    }
    
    //MARK - get API
    func getConditionsNow(url: String) {
//        let city = "Edmonds"
//        let method = "conditions"
//        let url = "\(WEATHER_URL)\(method)/q/WA/\(city).json"
        
        Alamofire.request(url).responseJSON { response in
            if response.result.isSuccess {
                let weatherJSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON["current_observation"])
            }
            else {
                print("Error \(response.result.error!)")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    //MARK: - JSON Parsing
    func updateWeatherData(json: JSON) {
        if let tempNow = json["temp_f"].double {
            weather.temp = Int(tempNow)
            weather.icon = json["icon"].stringValue
            weather.rainfall = json["precip_1hr_string"].doubleValue
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = json["response"].stringValue
        }
    }
    
    func updateUIWithWeatherData() {
        let url = URL(string: "\(ICON_URL)\(weather.icon).gif")
        print("url: \(weather.icon)")
        let data = try? Data(contentsOf: url!)
        WeatherIcon.image = UIImage(data: data!)
        temperatureLabel.text = "\(weather.temp)°"
        rainFall.text = String(weather.rainfall)
        cityLabel.text = currentCity
    }
    
    //MARK: - Change City Delegate methods
    func userEnteredANewCityName(city: String) {
        let method = "conditions"
        currentCity = city
        getConditionsNow(url: "\(WEATHER_URL)\(method)/q/WA/\(city).json")
    }
    
    override func prepare(for seque: UIStoryboardSegue, sender: Any?) {
        if seque.identifier == "changeCityName" {
            let destinationVC = seque.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }


}

