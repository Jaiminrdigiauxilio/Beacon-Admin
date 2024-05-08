//
//  OldVC.swift
//  Beacon-Admin
//
//  Created by Jaimin Raval on 24/04/24.
//

import UIKit
import kbeaconlib

class OldVC: UIViewController, ConnStateDelegate, KBeaconMgrDelegate {
    
    @IBOutlet weak var beaconTableview: UITableView!
    @IBOutlet weak var scanBtn: UIBarButtonItem!
    
    var loadingView: UIView!
    var loadingLabel: UILabel!
    var loadingIndicator: UIActivityIndicatorView!
    
    var mBeaconsMgr: KBeaconsMgr!
    var beaconsArr = [KBeacon]()
    var ibeaconsArr = [[String: Any]]()
    
    var newCommonCfg = KBCfgCommon()
    var iBeaconPara = KBCfgIBeacon()
    
    var modifyingBeacon: KBeacon!
    
    var beaconConnStatus: Bool = false
    var isBeaconAlreadyAdded: Bool = false
    var isBeaconConnected: Bool = false
    var isPassWrong: Bool = false
    
    let cellId = "BeaconCell"
    let call = ApiManager()
    let passwd: String = "0000000000"
    var currentMajorID: Int = 55100
    var currentMinorID:Int = 55001
    var currentIndex = 0

    let passwdArr = ["0000000000", "0000000000000000", "123456789", "1234567890"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  initializing kbeaconManager
        mBeaconsMgr = KBeaconsMgr.sharedBeaconManager()
        mBeaconsMgr.delegate = self
        initializeLoadingView()
        call.fetchAllBeaconsInCard(a: "2XEzmg", c: "2Xn3tg") // &a=2XEzmg&c=2Xn3tg
    }
    
    // MARK: - beacon delegate methods
    func onConnStateChange(_ beacon: KBeacon, state: KBConnState, evt: KBConnEvtReason) {
        
        if (beacon.state == .stateConnecting)
            {
            debugPrint("-/-/-/-/-Connecting")
        }
        else if (beacon.state == .stateConnected)
            {
            DispatchQueue.main.async {
                self.isBeaconConnected = true
                self.stopLoadingView()
                self.showToast(message: "Connected Successfully", font: .systemFont(ofSize: 12.0))
                self.startLoadingView(msg: "Modifying")
                self.modifyBeacon(atIndex: self.currentIndex)
            }
            
            debugPrint("-/-/-/-/-Connected")
            }
        
        else if (beacon.state == .stateDisconnected)
            {
            debugPrint("-/-/-/-/-can't Connect")
            DispatchQueue.main.async {
                self.isBeaconConnected = false
                self.stopLoadingView()
//                self.showToast(message: "Can't Connect to beacon", font: .systemFont(ofSize: 12.0))
            }
            if (evt == .evtConnAuthFail)
                {
                isBeaconConnected = false
                isPassWrong = true
                }
            }
    }
    
    func onBeaconDiscovered(_ beacons: [KBeacon]) {
        
        beaconsArr =  beacons
        var jsonArray = [[String: Any]]()
        if beacons.count>0{
            
            for beacon in beacons {
                for advPacket in beacon.allAdvPackets! {
                    let base = advPacket as? KBAdvPacketBase
                    if  base?.advType == .iBeacon
                    {
                        if let advIBeacon = advPacket as? KBAdvPacketIBeacon {
                            var jsonObject = [String: Any]()
                            jsonObject["mac"] = beacon.mac
                            jsonObject["name"] = beacon.name
                            jsonObject["uuid"] = beacon.uuidString
                            jsonObject["major"] = advIBeacon.majorID
                            jsonObject["minor"] = advIBeacon.minorID
                            jsonArray.append(jsonObject)
                        }
                    }
                }
            }
            if(jsonArray.count > 0){
                ibeaconsArr = jsonArray
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            self.beaconTableview.reloadData()
        }
    }
    
    func onCentralBleStateChange(_ newState: BLECentralMgrState) {
        
        if (newState == BLECentralMgrState.statePowerOn)
            {
            debugPrint("Power ON")
                //the app can start scan in this case
            
            }
        
    }
    
    // MARK: -  All Beacon Operations
    func scanBeacon() {
        
        if(mBeaconsMgr.isScanning() == true) {
            DispatchQueue.main.async {
                self.scanBtn.title = "Start"
                self.mBeaconsMgr.stopScanning()
                self.disconnectBeacon()
                self.mBeaconsMgr.clearBeacons()
                
            }
        } else if(mBeaconsMgr.isScanning() == false) {
            DispatchQueue.main.async {
                self.mBeaconsMgr.clearBeacons()
                self.scanBtn.title = "Stop"
                self.mBeaconsMgr.startScanning()
                self.showToast(message: "Scan started Successfully", font: .systemFont(ofSize: 12.0))
                
            }
        }
    }
    
    func stopScan() {
        if(mBeaconsMgr.isScanning() == false) {
            DispatchQueue.main.async {
                self.scanBtn.title = "Start"
                self.mBeaconsMgr.stopScanning()
                self.disconnectBeacon()
                
            }
        }
    }
    
    func connectBeacon(atIndex: Int) {
//        stopScan()
        var i = 0;
        modifyingBeacon = beaconsArr[atIndex]
        modifyingBeacon.delegate = self;
        modifyingBeacon.connect(passwdArr[i],
                       timeout: 20000)
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0){
            if self.isBeaconConnected {
                return
            } else {
                self.showToast(message: "Trying", font: <#T##UIFont#>)
                if(i < 3){
                    i += 1
                    self.modifyingBeacon.connect(self.passwdArr[i], timeout: 20000)
                }
            }
        }
    }
    
    func disconnectBeacon() {
        if(modifyingBeacon != nil){
            if(modifyingBeacon.state == .stateConnected){
                modifyingBeacon.disconnect()
            }
        }
    }
    
    func modifyBeacon(atIndex: Int) {
//        incrementMajorMinor(index: atIndex)
        newCommonCfg = KBCfgCommon()
        iBeaconPara = KBCfgIBeacon()
        self.newCommonCfg.name = modifyingBeacon.name
        self.iBeaconPara.majorID = NSNumber(value: currentMajorID)
        self.iBeaconPara.minorID = NSNumber(value: currentMinorID)
        self.iBeaconPara.uuid = modifyingBeacon.uuidString
        newCommonCfg.password = passwd
        
        if(modifyingBeacon.state == .stateConnected){
//            let filteredKBeacons = self.beaconsArr.filter {
//                $0.mac == modifyingBeacon.mac
//            }
//            if let currBeacon = filteredKBeacons.first {
//                self.modifyingBeacon = currBeacon
//                self.modifyingBeacon.delegate = self
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    self.modfy()
                }
//            }
        }
    }
    
    func modfy() {
        var cfgList = [KBCfgBase]()
        cfgList.append(self.newCommonCfg)
        cfgList.append(self.iBeaconPara)
        
        self.modifyingBeacon.delegate = self
        self.modifyingBeacon.modifyConfig(cfgList) { [self] succes, error in

            if succes{
                DispatchQueue.main.async {
                    self.modifyingBeacon.disconnect()
                    self.stopLoadingView()
                    self.showToast(message: "Modification Successfull", font: .systemFont(ofSize: 10))
                    debugPrint("Modification Successfull")
                }
                
            }else{
                DispatchQueue.main.async {
                    self.modifyingBeacon.disconnect()
                    self.stopLoadingView()
                    self.showToast(message: "Modification Fail", font: .systemFont(ofSize: 10))
                    debugPrint("Modification Fail")
                }
            }
            
        }
    }
   
    func addBeaconToCard() {
        
    }
    
    
    
    func checkMajorMinor(major: Int, minor: Int) -> Bool {
        if major >= 55000 && major <= 55999 &&  minor >= 55000 && minor <= 55999 {
            return true
        } else {
            return false
        }
    }
    
    func incrementMajorMinor(index: Int) {
        if (checkMajorMinor(major: ibeaconsArr[index]["major"] as! Int, minor: ibeaconsArr[index]["major"] as! Int)) {
            
        } else {
            //  increment majorminor here
            
        }
    }
    
//    func isBeaconAlreadyInCard() -> Bool {
//
//    }
    
    //  UIButton actions
    @IBAction func scanBtnTapped(_ sender: Any) {
        scanBeacon()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
//            self.stopScan()
//        }
        
    }
    
    // MARK: - UI components
    func initializeLoadingView() {
        // Create the loading view
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 180))
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        loadingView.layer.cornerRadius = 20
        // Create the loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingIndicator.startAnimating()
        // Create the loading label
        loadingLabel = UILabel(frame: CGRect(x: 0, y: loadingView.frame.size.height - 30, width: loadingView.frame.size.width, height: 20))
        loadingLabel.textColor = .white
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        
        // Add subviews
        loadingView.addSubview(loadingIndicator)
        loadingView.addSubview(loadingLabel)
        self.view.addSubview(loadingView)
        // Hide initially
        loadingView.isHidden = true
    }
    
    func startLoadingView(msg: String){
        DispatchQueue.main.async {
            self.loadingLabel.text = msg
            self.loadingView.isHidden = false
        }
    }
    
    func stopLoadingView(){
        DispatchQueue.main.async {
            self.loadingView.isHidden = true
        }
    }
    
}

// MARK: - tableView delegate methods
extension OldVC: UITableViewDelegate, UITableViewDataSource, BeaconCellDelegate {
    func addMethod(index: Int) {
        currentIndex = index
        startLoadingView(msg: "Connecting...")
//        debugPrint("index: \(index)")
        connectBeacon(atIndex: index)
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconsArr.count
//        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let beaconCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BeaconCell
        beaconCell.myDelegate = self
        beaconCell.nameLbl.text = "\(beaconsArr[indexPath.row].name)"
        beaconCell.macLbl.text = "\(beaconsArr[indexPath.row].mac)"
        beaconCell.uuidLbl.text = "\(beaconsArr[indexPath.row].uuidString)"
        beaconCell.majorLbl.text = "\(ibeaconsArr[indexPath.row]["major"]!)"
        beaconCell.minorLbl.text = "\(ibeaconsArr[indexPath.row]["minor"]!)"
        beaconCell.addBtn.setTitle(isBeaconAlreadyAdded ? "Already Added": "Add", for: .normal)
        beaconCell.addBtn.tintColor = isBeaconAlreadyAdded ? .systemRed : .systemBlue
        beaconCell.addBtn.isEnabled = isBeaconAlreadyAdded ? false : true
        beaconCell.addBtn.tag = indexPath.row
        
        return beaconCell
    }
    
    
}


// MARK: - extensions
extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 175, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 12;
        toastLabel.clipsToBounds  =  true
        
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
