//
//  ChooseRangeViewController.swift
//  BitSense
//
//  Created by Peter on 01/09/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import UIKit

class ChooseRangeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let picker = UIPickerView()
    let connectingView = ConnectingView()
    
    var range = ""
    var dict = [String:Any]()
    var isHDMusig = Bool()
    var keyArray = NSArray()
    var isDescriptor = Bool()
    
    let ud = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePicker()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addPicker()
        
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        if isHDMusig {
            
            getHDMusigAddresses()
            
        } else {
            
            DispatchQueue.main.async {
                
                self.performSegue(withIdentifier: "addToKeypool", sender: self)
                
            }
            
        }
        
    }
    
    func configurePicker() {
        
        picker.dataSource = self
        picker.delegate = self
        picker.isUserInteractionEnabled = true
        
        let frame = view.frame
        
        picker.frame = CGRect(x: 0,
                              y: 250,
                              width: frame.width,
                              height: 200)
        
        picker.backgroundColor = self.view.backgroundColor
        
    }
    
    func addPicker() {
        
        view.addSubview(picker)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1000
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let string = "\(row * 100) to \(row * 100 + 199)"
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let row = pickerView.selectedRow(inComponent: component)
        let string = "\(row * 100) to \(row * 100 + 199)"
        self.range = string
        
    }
    
    func convertRange() -> [Int] {
        
        if range == "" {
            
            range = "0 to 199"
            
        }
        
        var arrayToReturn = [Int]()
        let newrange = range.replacingOccurrences(of: " ", with: "")
        let rangeArray = newrange.components(separatedBy: "to")
        let zero = Int(rangeArray[0])!
        let one = Int(rangeArray[1])!
        arrayToReturn = [zero,one]
        dict["convertedRange"] = arrayToReturn
        return arrayToReturn
        
    }
    
    func getHDMusigAddresses() {
        
        let reducer = Reducer()
        
        connectingView.addConnectingView(vc: self,
                                         description: "deriving HD multisig addresses")
        
        let convertedRange = convertRange()
        
        func importDescriptor() {
            
            let result = reducer.dictToReturn
            
            if reducer.errorBool {
                
                connectingView.removeConnectingView()
                
                displayAlert(viewController: self,
                             isError: true,
                             message: reducer.errorDescription)
                
            } else {
                
                let descriptor = "\"\(result["descriptor"] as! String)\""
                
                self.executeNodeCommandSsh(method: BTC_CLI_COMMAND.deriveaddresses,
                                           param: "\(descriptor), ''\(convertedRange)''")
                
            }
            
        }
        
        let descriptor = dict["descriptor"] as! String
        
        reducer.makeCommand(command: BTC_CLI_COMMAND.getdescriptorinfo,
                            param: "\(descriptor)",
                            completion: importDescriptor)
        
    }
    
    func executeNodeCommandSsh(method: BTC_CLI_COMMAND, param: String) {
        
        let reducer = Reducer()
        
        func getResult() {
            
            if !reducer.errorBool {
                
                switch method {
                    
                case BTC_CLI_COMMAND.deriveaddresses:
                    
                    DispatchQueue.main.async {
                        
                        self.keyArray = reducer.arrayToReturn
                        self.connectingView.removeConnectingView()
                        
                        self.performSegue(withIdentifier: "goDisplayHDMusig",
                                          sender: self)
                        
                    }
                    
                default:
                    
                    break
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    
                    self.connectingView.removeConnectingView()
                    
                    displayAlert(viewController: self,
                                 isError: true,
                                 message: reducer.errorDescription)
                    
                }
                
            }
            
        }
        
        reducer.makeCommand(command: method,
                            param: param,
                            completion: getResult)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if range == "" {
            
            range = "0 to 199"
            
        }
        
        dict["range"] = range
        
        switch segue.identifier {
            
        case "addToKeypool":
            
            if let vc = segue.destination as? AddToKeypoolViewController  {
            
                vc.dict = dict
                vc.isDescriptor = isDescriptor
                
            }
            
        case "goDisplayHDMusig":
            
            if let vc = segue.destination as? ImportExtendedKeysViewController {
                
                vc.keyArray = keyArray
                vc.dict = dict
                vc.isHDMusig = true
                
            }
            
        default:
            
            break
            
        }
    }

}
