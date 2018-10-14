//  Data Class 사용 
//  ViewController.swift
//  BusanAirQualityParsing
//
//  Created by 김종현 on 2018. 9. 15..
//  Copyright © 2018년 김종현. All rights reserved.
//  XCode 9.41

import UIKit

class ViewController: UIViewController, XMLParserDelegate {
    var items = [AirQuailtyData]()
    var item = AirQuailtyData()
    var myPm10 = ""
    var myPm25 = ""
    var mySite = ""
    var myPm10Cai = ""
    var myPm25Cai = ""
    var currentElement = ""
    var currentTime = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Timer 호출
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.myParse), userInfo: nil, repeats: true)
    }
    
    @objc func myParse() {
        // Do any additional setup after loading the view, typically from a nib.
        let key = "aT2qqrDmCzPVVXR6EFs6I50LZTIvvDrlvDKekAv9ltv9dbO%2F8i8JBz2wsrkpr9yrPEODkcXYzAqAEX1m%2Fl4nHQ%3D%3D"
        
        let strURL = "http://opendata.busan.go.kr/openapi/service/AirQualityInfoService/getAirQualityInfoClassifiedByStation?ServiceKey=\(key)&Date_hour=2018091520&numOfRows=21"
        
        let url = URL(string: strURL)
        print(url!)
        
        if let url = URL(string: strURL) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                
                if (parser.parse()) {
                    print("parsing success")
                    print("PM 10 in Busan")
                    
                    let date: Date = Date()
                    let dayTimePeriodFormatter = DateFormatter()
                    dayTimePeriodFormatter.dateFormat = "YYYY/MM/dd HH시"
                    currentTime = dayTimePeriodFormatter.string(from: date)
                    print(currentTime)
                    
                    for i in 0..<items.count {
                        switch items[i].dPm10Cai {
                            case "1" : items[i].dPm10Cai = "좋음"
                            case "2" : items[i].dPm10Cai = "보통"
                            case "3" : items[i].dPm10Cai = "좋음"
                            case "4" : items[i].dPm10Cai = "매우좋음"
                            default : break
                            
                        }
                        
                        print("\(items[i].dSite) : \(items[i].dPm10)  \(items[i].dPm10Cai)")
                    }
                    
                    items = [AirQuailtyData]()
                    
                } else {
                    print("parsing fail")
                }
            } else {
                print("url error")
            }
        }
    }
    
    // XML Parser Delegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if !data.isEmpty {
//            print("data = \(data)")
            switch currentElement {
                case "pm10" : myPm10 = data
                case "pm25" : myPm25 = data
                case "pm10Cai" : myPm10Cai = data
                case "pm25Cai" : myPm25Cai = data
                case "site" : mySite = data
                default : break
            }
//            print("pm10Cai = \(myPm10Cai)")
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let myItem = AirQuailtyData()
            myItem.dPm10 = myPm10
            myItem.dPm25 = myPm25
            myItem.dPm10Cai = myPm10Cai
            myItem.dPm25Cai = myPm25Cai
            myItem.dSite = mySite
            items.append(myItem)
        }
    }
}

