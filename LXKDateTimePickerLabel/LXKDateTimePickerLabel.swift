//
//  LXKDateTimePickerLabel.swift
//  DateTimePickerLabelExample
//
//  Created by Le Xuan Khanh on 2/21/22.
//

import Foundation
import UIKit

public enum LXKDatePickerViewStyle : Int {
    /// Automatically pick the best style available for the current platform & mode.
    case automatic = 0

    /// Use the wheels (UIPickerView) style. Editing occurs inline.
    case wheels = 1

    /// Use a compact style for the date picker. Editing occurs in an overlay.
    case compact = 2

    /// Use a style for the date picker that allows editing in place.
    //@available(iOS 14.0, *)
    case inline = 3
    
    @available(iOS 13.4, *)
    var toStyle: UIDatePickerStyle {
        return UIDatePickerStyle.init(rawValue: self.rawValue)!
    }
}


class LXKDateTimePickerLabel: UILabel {
    let textField: UITextField = {
        let txt = UITextField()
        txt.alpha = 0
        return txt
    }()
    
    var tapRecognizer = UITapGestureRecognizer()
    
    var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    /// countDownTimer style is not supported
    var pickerType = UIDatePicker.Mode.dateAndTime {
        didSet {
            datePicker.datePickerMode = pickerType
            text = currentFormatter.string(from: datePicker.date)
            setPickerInputView()
        }
    }
    
    /// only available in ios 13.4 and above
    var pickerStyle: LXKDatePickerViewStyle = .automatic {
        didSet {
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = pickerStyle.toStyle
                setPickerInputView()
            }
        }
    }
    
    var formatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    var formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
    
    var formatterDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }()
    
    var onValueChanged: ((Date) -> Void)?
    var onButtonDoneTapped: ((Date) -> Void)?
    
    var date: Date {
        return datePicker.date
    }
    
    var currentFormatter: DateFormatter {
        switch pickerType {
        case .time:
            return formatterTime
        case .date:
            return formatterDate
        case .dateAndTime:
            return formatterDateTime
        default:
            return formatterTime
        }
    }
    
    var pickerContainerView: PickerContainerView = {
        let view = PickerContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        layoutViews()
        initValue()
    }
    
    func layoutViews() {
        self.isUserInteractionEnabled = true
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(textField)
        textField.isUserInteractionEnabled = true
       
        tapRecognizer.addTarget(self, action: #selector(onLabelTapped(_:)))
        self.addGestureRecognizer(tapRecognizer)

    }
    
    func initValue() {
        datePicker.datePickerMode = pickerType
        datePicker.addTarget(self, action: #selector(datePickerFromValueChanged), for: .valueChanged)
        
        textField.text = nil
        setPickerInputView()
        // remove cursor
        textField.tintColor = .clear
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneDatePickerPressed))
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()

        textField.inputAccessoryView = toolBar
        
        setDate(date: Date())
    }
    
    func fitInSuperview(view: UIView) {
        view.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    }
    
    @objc private func onLabelTapped(_ sender: Any) {
        textField.becomeFirstResponder()
    }
    
    @objc private func datePickerFromValueChanged() {
        changeValue()
    }
    
    @objc private func doneDatePickerPressed(){
        self.textField.endEditing(true)
        if let onButtonDoneTapped = onButtonDoneTapped {
            onButtonDoneTapped(datePicker.date)
        }
        
    }
    
    func changeValue(isNotify: Bool = true) {
        text = currentFormatter.string(from: datePicker.date)
        
        if isNotify {
            if let onValueChanged = onValueChanged {
                onValueChanged(datePicker.date)
            }
        }
    }
    
    func setDate(date: Date, animated: Bool = false, isNotify: Bool = true) {
        datePicker.setDate(date, animated: animated)
        changeValue(isNotify: isNotify)
    }
    
    func setMaxDate(date: Date, isNotify: Bool = true) {
        datePicker.maximumDate = date
        changeValue(isNotify: isNotify)
    }
     
    func setMinDate(date: Date, isNotify: Bool = true) {
        datePicker.minimumDate = date
        changeValue(isNotify: isNotify)
    }
    
    
    func setPickerInputView() {
        guard #available(iOS 13.4, *) else {
            return setWheelsPickerInputView()
        }
        
        switch datePicker.datePickerStyle {
        case .automatic:
            return setWheelsPickerInputView()
        case .wheels:
            return setWheelsPickerInputView()
        case .compact:
            return setCompactPickerInputView()
        case .inline:
            return setInlinePickerInputView()
        @unknown default:
            return setWheelsPickerInputView()
        }
    }
    
    func setWheelsPickerInputView() {
        textField.inputView = datePicker
        textField.reloadInputViews()
    }
    
    func setCompactPickerInputView() {
        pickerContainerView = PickerContainerView()
        pickerContainerView.translatesAutoresizingMaskIntoConstraints = false
        pickerContainerView.addSubview(datePicker)
        textField.inputView = pickerContainerView
        
        pickerContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: pickerContainerView.centerXAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: pickerContainerView.centerYAnchor).isActive = true
        textField.reloadInputViews()
    }
    
    func setInlinePickerInputView() {
        if pickerType == .time {
            return setCompactPickerInputView()
        }
        
        pickerContainerView = PickerContainerView()
        pickerContainerView.translatesAutoresizingMaskIntoConstraints = false
        pickerContainerView.addSubview(datePicker)
        textField.inputView = pickerContainerView
        
        datePicker.topAnchor.constraint(equalTo: pickerContainerView.topAnchor).isActive = true
        datePicker.widthAnchor.constraint(equalTo: pickerContainerView.widthAnchor).isActive = true
        
        datePicker.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor).isActive = true
        textField.reloadInputViews()
    }
    
}

internal class PickerContainerView: UIInputView {
    override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        allowsSelfSizing = true
    }
    
    override var inputViewStyle: UIInputView.Style {
        return .default
    }
}
