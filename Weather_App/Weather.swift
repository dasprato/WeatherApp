//
//  Weather.swift
//  Weather_App
//
//  Created by Prato Das on 2017-10-16.
//  Copyright © 2017 Prato Das. All rights reserved.
//

import Foundation
import CoreLocation

struct Weather {
    let summary:String
    let icon:String
    let temperatureMax:Double
    let temperatureMin:Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any]) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        
        guard let temperatureMax = json["temperatureMax"] as? Double else {throw SerializationError.missing("temp is missing")}
        
        guard let temperatureMin = json["temperatureMin"] as? Double else {throw SerializationError.missing("temp is missing")}
        
        
        
        self.summary = summary
        self.icon = icon
        self.temperatureMax = (temperatureMax - 32) * (5/9)
        self.temperatureMin = (temperatureMin - 32) * (5/9)
    }
    
    
    static let basePath = "https://api.darksky.net/forecast/d4d576997fe264a33d55b7804a97d1df/"
    
    static func forecast (withLocation location:CLLocationCoordinate2D, completion: @escaping ([Weather]?) -> ()) {
        
        let url = basePath + "\(location.latitude),\(location.longitude)"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                        
                    }
                }catch {
                    print(error.localizedDescription)
                }
                
                completion(forecastArray)
                
            }
            
            
        }
        
        task.resume()
        
        
        
        
        
        
        
        
        
    }
    
    
}
