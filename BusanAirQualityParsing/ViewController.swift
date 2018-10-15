//  Data Class 사용
//  ViewController.swift
//  BusanAirQualityParsing
//
//  Created by 김종현 on 2018. 9. 15..
//  Copyright © 2018년 김종현. All rights reserved.
//  XCode 9.41

import UIKit

class ViewController: UIViewController, XMLParserDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var items = [AirQuailtyData]()
    var item = AirQuailtyData()
    var myPm10 = ""
    var myPm25 = ""
    var mySite = ""
    var myPm10Cai = ""
    var myPm25Cai = ""
    var currentElement = ""
    var currentTime = ""
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        
        // Timer 호출
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.myParse), userInfo: nil, repeats: true)
    }
    
    @objc func myParse() {
        // Do any additional setup after loading the view, typically from a nib.
        let key = "공공데이터 Key"
        
        let strURL = "http://opendata.busan.go.kr/openapi/service/AirQualityInfoService/getAirQualityInfoClassifiedByStation?ServiceKey=\(key)&numOfRows=21"
        
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
                    print("PM10")
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
                    
                    print("-----------------------")
                    print("PM2.5")
                    for i in 0..<items.count {
                        switch items[i].dPm25Cai {
                        case "1" : items[i].dPm25Cai = "좋음"
                        case "2" : items[i].dPm25Cai = "보통"
                        case "3" : items[i].dPm25Cai = "좋음"
                        case "4" : items[i].dPm25Cai = "매우좋음"
                        default : break
                        }
                        
                        print("\(items[i].dSite) : \(items[i].dPm25)  \(items[i].dPm25Cai)")
                    }
                    
                    print("-----------------------")
                    
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
    
    // UITableView Delegate Methods 호출
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = myTableView.dequeueReusableCell(withIdentifier: "RE", for: indexPath)
        let myItem = items[indexPath.row]
        
        let mySite = myCell.viewWithTag(1) as! UILabel
        let myPM10 = myCell.viewWithTag(2) as! UILabel
        let myPM10Cai = myCell.viewWithTag(3) as! UILabel
        
        mySite.text = myItem.dSite
        myPM10.text = myItem.dPm10
        myPM10Cai.text = myItem.dPm10Cai
        
        return myCell
    }
}

