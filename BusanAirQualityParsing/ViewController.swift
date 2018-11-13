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
        
        // 시작할때 한번 호출
        myParse()
        
        // 1시간 마다 호출
        Timer.scheduledTimer(timeInterval: 60*60, target: self, selector: #selector(ViewController.myParse), userInfo: nil, repeats: true)
        
        myTableView.reloadData()
    }
    
     @objc func myParse() {
        
        print("in Timer!")
        // Do any additional setup after loading the view, typically from a nib.
        let key = "E%2FeSbG29KCzlKt24hzLXa%2FztaQQR9XfK0364bMCEN569c0u2qJV4wUYDsaf4cz6XTYesGAj%2BBm5fW1CFwoD3pA%3D%3D"

        let strURL = "http://opendata.busan.go.kr/openapi/service/EnvironmentalRadiationInfoService/getEnvironmentalRadiationInfoDetail?ServiceKey=\(key)&numOfRows=10"
        
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
                    
                    for i in 0..<items.count {
//                        switch items[i].dPm10Cai {
//                            case "1" : items[i].dPm10Cai = "좋은"
//                            case "2" : items[i].dPm10Cai = "보통" + "  😟"
//                            case "3" : items[i].dPm10Cai = "나쁨" + "  😡"
//                            case "4" : items[i].dPm10Cai = "매우나쁨"
//                            default : break
//                        }
                        print("a")
                        print("\(items[i].dlat) : \(items[i].dlng)  \(items[i].ddata) \(items[i].dlocNm) \(items[i].dcheckTime)")
                    }
                   
                    // 1시간 간격으로 공공데이터를 호출, 파싱, 테이블뷰에 데이터 reload()
                 
                    
                } else {
                    print("parsing fail")
                }
            } else {
                print("url error")
            }
        }
    }
    
    // UITableView Delegate Methods 호출
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let myCell = myTableView.dequeueReusableCell(withIdentifier: "RE", for: indexPath)
//        let myItem = items[indexPath.row]
//
//        let mySite = myCell.viewWithTag(1) as! UILabel
//        let myPM10 = myCell.viewWithTag(2) as! UILabel
//        let myPM10Cai = myCell.viewWithTag(3) as! UILabel
//
//        mySite.text = myItem.dSite
//        myPM10.text = myItem.dPm10 + " ug/m2"
//        myPM10Cai.text = myItem.dPm10Cai
//
        return myCell
    }
    
    // XML Parser Delegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if !data.isEmpty {
            switch currentElement {
                case "pm10" : myPm10 = data
                case "pm25" : myPm25 = data
                case "pm10Cai" : myPm10Cai = data
                case "pm25Cai" : myPm25Cai = data
                case "site" : mySite = data
                default : break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let myItem = AirQuailtyData()
            myItem.dcheckTime = myPm10
            myItem.ddata = myPm25
            myItem.dlat = myPm10Cai
            myItem.dlng = myPm25Cai
            myItem.dlocNm = mySite
            items.append(myItem)
        }
    }
}

