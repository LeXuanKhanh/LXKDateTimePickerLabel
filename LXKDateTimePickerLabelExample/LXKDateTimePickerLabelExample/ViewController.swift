//
//  ViewController.swift
//  dateTimePickerLabel
//
//  Created by Le Xuan Khanh on 2/16/22.
//

import UIKit
import LXKDateTimePickerLabel

class ViewController: UIViewController {
    
    
    @IBOutlet weak var dateTimePickerLabel: LXKDateTimePickerLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var isAnimationSwitch: UISwitch!
    @IBOutlet weak var isNotifySwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dateTimePickerLabel.pickerType = .dateAndTime
        dateTimePickerLabel.onButtonDoneTapped = { [weak self] date in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.dateLabel.text = "\(date)"
            
        }
        
        dateTimePickerLabel.onValueChanged = { [weak self] date in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.dateLabel.text = "\(date)"
        }
        
    }

    @IBAction func setMinDate(_ sender: Any) {
        if let maxDate = dateTimePickerLabel.datePicker.maximumDate {
            dateTimePickerLabel.setMaxDate(date: Date.randomBetween(start: maxDate.add(value: -2, to: .month)!, end: maxDate.add(value: 1, to: .minute)!), isNotify: isNotifySwitch.isOn)
        } else {
            dateTimePickerLabel.setMaxDate(date: generateRandomDate(), isNotify: isNotifySwitch.isOn)
        }
    }
    
    
    @IBAction func setMaxDate(_ sender: Any) {
        if let minDate = dateTimePickerLabel.datePicker.minimumDate {
            dateTimePickerLabel.setMaxDate(date: Date.randomBetween(start: minDate.add(value: 1, to: .minute)!, end: Date().add(value: 2, to: .month)!), isNotify: isNotifySwitch.isOn)
        } else {
            dateTimePickerLabel.setMaxDate(date: generateRandomDate(), isNotify: isNotifySwitch.isOn)
        }
    }
    
    
    @IBAction func changeDate(_ sender: Any) {
        let randomDate = Date.randomBetween(start: dateTimePickerLabel.datePicker.minimumDate ?? Date().add(value: -2, to: .month)!, end: dateTimePickerLabel.datePicker.maximumDate ?? Date().add(value: 2, to: .month)!)
        dateTimePickerLabel.setDate(date: randomDate, animated: isAnimationSwitch.isOn, isNotify: isNotifySwitch.isOn)
    }
    
    @IBAction func changePickerType(_ sender: Any) {
        let randomInt = Int.random(in: 0...2)
        let mode = UIDatePicker.Mode.init(rawValue: randomInt)!
        dateTimePickerLabel.pickerType = mode
    }
    
    @IBAction func pickerTypeDateTimeTapped(_ sender: Any) {
        dateTimePickerLabel.pickerType = .dateAndTime
    }
    
    @IBAction func pickerTypeDateTapped(_ sender: Any) {
        dateTimePickerLabel.pickerType = .date
    }
    
    @IBAction func pickerTypeTimeTapped(_ sender: Any) {
        dateTimePickerLabel.pickerType = .time
    }
    
    @IBAction func pickerStyleWheelsTapped(_ sender: Any) {
        dateTimePickerLabel.pickerStyle = .wheels
    }
    
    @IBAction func pickerStyleCompactTapped(_ sender: Any) {
        dateTimePickerLabel.pickerStyle = .compact
    }
    
    @IBAction func pickerStyleInlineTapped(_ sender: Any) {
        dateTimePickerLabel.pickerStyle = .inline
    }
    
    func generateRandomDate() -> Date {
        return Date.randomBetween(start: Date().add(value: -2, to: .month)!, end: Date().add(value: 2, to: .month)!)
    }
    
}

extension Date {
    
    static func randomBetween(start: String, end: String, format: String = "yyyy-MM-dd") -> String {
        let date1 = Date.parse(start, format: format)
        let date2 = Date.parse(end, format: format)
        return Date.randomBetween(start: date1, end: date2).dateString(format)
    }

    static func randomBetween(start: Date, end: Date) -> Date {
        var date1 = start
        var date2 = end
        if date2 < date1 {
            let temp = date1
            date1 = date2
            date2 = temp
        }
        let span = TimeInterval.random(in: date1.timeIntervalSinceNow...date2.timeIntervalSinceNow)
        return Date(timeIntervalSinceNow: span)
    }

    func dateString(_ format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    static func parse(_ string: String, format: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.default
        dateFormatter.dateFormat = format

        let date = dateFormatter.date(from: string)!
        return date
    }
    
    func add(value: Int, to component: Calendar.Component) -> Date?{
        var dateComponent = DateComponents()
        
        switch component {
        case .second:
            dateComponent.second = value
        case .minute:
            dateComponent.minute = value
        case .hour:
            dateComponent.hour = value
        case .day:
            dateComponent.day = value
        case .month:
            dateComponent.month = value
        case .year:
            dateComponent.year = value
        default: break
        }
        
        return Calendar.current.date(byAdding: dateComponent, to: self)
    }
}


