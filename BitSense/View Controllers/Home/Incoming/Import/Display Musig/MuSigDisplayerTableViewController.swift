//
//  MuSigDisplayerTableViewController.swift
//  BitSense
//
//  Created by Peter on 18/07/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import UIKit

class MuSigDisplayerTableViewController: UITableViewController {
    
    var p2sh = Bool()
    var p2shP2wsh = Bool()
    var p2wsh = Bool()
    var isHD = Bool()
    var sigsRequired = ""
    var pubkeyArray = [String]()
    let qrGenerator = QRGenerator()
    let connectingView = ConnectingView()
    var shareRedScriptQR = UITapGestureRecognizer()
    var shareAddressQR = UITapGestureRecognizer()
    var shareRedScriptText = UITapGestureRecognizer()
    var shareAddressText = UITapGestureRecognizer()
    var address = ""
    var script = ""
    
    var dict = [String:Any]()
    
    @IBAction func back(_ sender: Any) {
        
        DispatchQueue.main.async {
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareRedScriptQR = UITapGestureRecognizer(target: self, action: #selector(self.shareRedQR(_:)))
        shareAddressQR = UITapGestureRecognizer(target: self, action: #selector(self.shareAddressQR(_:)))
        shareRedScriptText = UITapGestureRecognizer(target: self, action: #selector(self.shareRedTxt(_:)))
        shareAddressText = UITapGestureRecognizer(target: self, action: #selector(self.shareAddressTxt(_:)))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if isHD {
            
            importMulti()
            
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "importCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "address", for: indexPath)
            let imageView = cell.viewWithTag(1) as! UIImageView
            let textView = cell.viewWithTag(2) as! UITextView
            self.qrGenerator.textInput = address
            imageView.image = self.qrGenerator.getQRCode()
            imageView.addGestureRecognizer(shareAddressQR)
            textView.addGestureRecognizer(shareAddressText)
            textView.textColor = UIColor.green
            textView.text = address
            cell.selectionStyle = .none
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "redemptionScript", for: indexPath)
            let imageView = cell.viewWithTag(1) as! UIImageView
            let textView = cell.viewWithTag(2) as! UITextView
            self.qrGenerator.textInput = script
            imageView.image = self.qrGenerator.getQRCode()
            imageView.addGestureRecognizer(shareRedScriptQR)
            textView.text = script
            textView.textColor = UIColor.green
            textView.addGestureRecognizer(shareRedScriptText)
            cell.selectionStyle = .none
            return cell
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return 84
            
        } else {
            
            return 292
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        let impact = UIImpactFeedbackGenerator()
        
        DispatchQueue.main.async {
            
            impact.impactOccurred()
            
            UIView.animate(withDuration: 0.2, animations: {
                
                cell.alpha = 0
                
            }, completion: { _ in
                
                if indexPath.row == 0 {
                    
                    self.importMulti()
                    
                }
                
            })
            
        }
        
    }
    
    @objc func shareRedQR(_ sender: UITapGestureRecognizer) {
        print("share")
        
        DispatchQueue.main.async {
            
            self.qrGenerator.textInput = self.script
            let qrImage = self.qrGenerator.getQRCode()
            let objectsToShare = [qrImage]
            
            let activityController = UIActivityViewController(activityItems: objectsToShare,
                                                              applicationActivities: nil)
            
            activityController.popoverPresentationController?.sourceView = self.view
            self.present(activityController, animated: true) {}
            
        }
        
    }
    
    @objc func shareAddressQR(_ sender: UITapGestureRecognizer) {
        print("share")
        
        DispatchQueue.main.async {
            
            self.qrGenerator.textInput = self.address
            let qrImage = self.qrGenerator.getQRCode()
            let objectsToShare = [qrImage]
            
            let activityController = UIActivityViewController(activityItems: objectsToShare,
                                                              applicationActivities: nil)
            
            activityController.popoverPresentationController?.sourceView = self.view
            self.present(activityController, animated: true) {}
            
        }
        
    }
    
    @objc func shareRedTxt(_ sender: UITapGestureRecognizer) {
        print("share")
        
        DispatchQueue.main.async {
            
            let objectsToShare = [self.script]
            
            let activityController = UIActivityViewController(activityItems: objectsToShare,
                                                              applicationActivities: nil)
            
            activityController.popoverPresentationController?.sourceView = self.view
            self.present(activityController, animated: true) {}
            
        }
        
    }
    
    @objc func shareAddressTxt(_ sender: UITapGestureRecognizer) {
        print("share")
        
        DispatchQueue.main.async {
            
            let objectsToShare = [self.address]
            
            let activityController = UIActivityViewController(activityItems: objectsToShare,
                                                              applicationActivities: nil)
            
            activityController.popoverPresentationController?.sourceView = self.view
            self.present(activityController, animated: true) {}
            
        }
        
    }
    
    func importMulti() {
        
        let reducer = Reducer()
        
        connectingView.addConnectingView(vc: self,
                                         description: "Importing MultiSig")
        
        let timestamp = dict["rescanDate"] as! Int
        let label = dict["label"] as! String
        
        func importDescriptor() {
            
            let result = reducer.dictToReturn
            
            if reducer.errorBool {
                
                connectingView.removeConnectingView()
                
                displayAlert(viewController: self,
                             isError: true,
                             message: reducer.errorDescription)
                
            } else {
                
                let descriptor = "\"\(result["descriptor"] as! String)\""
                
                let params = "[{ \"desc\": \(descriptor), \"timestamp\": \(timestamp), \"watchonly\": true, \"label\": \"\(label)\" }], ''{\"rescan\": true}''"
                
                //if !isHD {
                
                let aes = AESService()
                let cd = CoreDataService()
                let encDesc = aes.encryptKey(keyToEncrypt: descriptor)
                let encLabel = aes.encryptKey(keyToEncrypt: label)
                let encRange = aes.encryptKey(keyToEncrypt: "no range")
                let id = randomString(length: 10)
                let nodes = cd.retrieveEntity(entityName: ENTITY.nodes)
                let isActive = isAnyNodeActive(nodes: nodes)
                var nodeID = ""
                
                if isActive {
                    
                    for node in nodes {
                        
                        let active = node["isActive"] as! Bool
                        
                        if active {
                            
                            nodeID = node["id"] as! String
                            
                        }
                        
                    }
                    
                }
                
                let descDict = ["descriptor":encDesc,
                                "label":encLabel,
                                "range":encRange,
                                "id":id,
                                "nodeID":nodeID]
                
                let descriptorSaved = cd.saveEntity(vc: self,
                                                    dict: descDict,
                                                    entityName: ENTITY.descriptors)
                
                if descriptorSaved {
                    
                    self.executeNodeCommand(method: BTC_CLI_COMMAND.importmulti,
                                            param: params)
                    
                } else {
                    
                    connectingView.removeConnectingView()
                    
                    displayAlert(viewController: self,
                                 isError: true,
                                 message: "error saving descriptor")
                }
                
                /*} else {
                 
                 self.executeNodeCommand(method: BTC_CLI_COMMAND.deriveaddresses,
                 param: descriptor + ", [0,100]")
                 
                 }*/
                
            }
            
        }
        
        var descriptor = ""
        
        
        if isHD {
            
            //descriptor = sh(multi(2,XPUB/*,XPUB/*))
            //process pubkeys
            var pubkeys = (pubkeyArray.description).replacingOccurrences(of: "[", with: "")
            pubkeys = pubkeys.replacingOccurrences(of: ",", with: "/*,")
            pubkeys = pubkeys.replacingOccurrences(of: "]", with: "/*]")
            pubkeys = pubkeys.replacingOccurrences(of: "]", with: "")
            
            if p2sh {
                
                descriptor = "sh(multi(\(sigsRequired),\(pubkeys)))"
                
            }
            
            if p2wsh {
                
                descriptor = "wsh(multi(\(sigsRequired),\(pubkeys)))"
                
                
            }
            
            if p2shP2wsh {
                
                descriptor = "sh(wsh(multi(\(sigsRequired),\(pubkeys))))"
                
            }
            
        } else {
            
            var pubkeys = (pubkeyArray.description).replacingOccurrences(of: "[", with: "")
            pubkeys = pubkeys.replacingOccurrences(of: "]", with: "")
            
            if p2sh {
                
                descriptor = "sh(multi(\(sigsRequired),\(pubkeys)))"
                
            }
            
            if p2wsh {
                
                descriptor = "wsh(multi(\(sigsRequired),\(pubkeys)))"
                
                
            }
            
            if p2shP2wsh {
                
                descriptor = "sh(wsh(multi(\(sigsRequired),\(pubkeys))))"
                
            }
            
        }
        
        descriptor = descriptor.replacingOccurrences(of: "\"", with: "")
        descriptor = descriptor.replacingOccurrences(of: " ", with: "")
        
        let method = BTC_CLI_COMMAND.getdescriptorinfo
        let param = "\"\(descriptor)\""
        
        reducer.makeCommand(command: method,
                            param: param,
                            completion: importDescriptor)
        
    }
    
    func isAnyNodeActive(nodes: [[String:Any]]) -> Bool {
        
        var boolToReturn = false
        
        for node in nodes {
            
            let isActive = node["isActive"] as! Bool
            
            if isActive {
                
                boolToReturn = true
                
            }
            
        }
        
        return boolToReturn
        
    }
    
    func executeNodeCommand(method: BTC_CLI_COMMAND, param: String) {
        
        let reducer = Reducer()
        
        func getResult() {
            
            if !reducer.errorBool {
                
                switch method {
                    
                    /*case BTC_CLI_COMMAND.deriveaddresses:
                     
                     let result = reducer.arrayToReturn*/
                    
                case .importmulti:
                    
                    self.connectingView.removeConnectingView()
                    
                    let result = reducer.arrayToReturn
                    let success = (result[0] as! NSDictionary)["success"] as! Bool
                    
                    if success {
                        
                        connectingView.removeConnectingView()
                        
                        displayAlert(viewController: self,
                                     isError: false,
                                     message: "MultiSig imported!")
                        
                    } else {
                        
                        let error = ((result[0] as! NSDictionary)["error"] as! NSDictionary)["message"] as! String
                        connectingView.removeConnectingView()
                        
                        displayAlert(viewController: self,
                                     isError: true,
                                     message: error)
                        
                    }
                    
                    if let warnings = (result[0] as! NSDictionary)["warnings"] as? NSArray {
                        
                        if warnings.count > 0 {
                            
                            for warning in warnings {
                                
                                let warn = warning as! String
                                
                                DispatchQueue.main.async {
                                    
                                    let alert = UIAlertController(title: "Warning", message: warn, preferredStyle: UIAlertController.Style.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }
                                
                            }
                            
                        }
                        
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
    
}
