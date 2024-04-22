//
//  ViewController.swift
//  Beacon-Admin
//
//  Created by Jaimin Raval on 11/04/24.
//

import UIKit
import kbeaconlib2

class ViewController: UIViewController, KBeaconMgrDelegate, ConnStateDelegate {
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var disconnectBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    
    var beaconArr:[KBeacon] = []
    weak var beacon: KBeacon?
    var mBeaconsMgr: KBeaconsMgr?
    let beaconPwd = "000000"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectBtn.isEnabled = false;
        updateBtn.isEnabled = false;
        disconnectBtn.isEnabled = false;
        uploadBtn.isEnabled = false;
        mBeaconsMgr = KBeaconsMgr.sharedBeaconManager
        mBeaconsMgr!.delegate = self
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        
        let scanResult = mBeaconsMgr!.startScanning()
          if (scanResult)
          {
//              NSLog("start scan success");
              debugPrint("Scan started succesfully")
          }
          else
          {
//              NSLog("start scan failed");
              debugPrint("Scan failed")
          }
        
    }
    
    @IBAction func connectTapple(_ sender: Any) {
        //  this line of code STOPS SCANNING
//        mBeaconsMgr!.stopScanning()
        beacon = beaconArr[0]
//        self.beacon!.connect(beaconPwd, timeout: 15.0, delegate: self)
        beacon?.connect(beaconPwd, timeout: 150.0, delegate: self)
        debugPrint("-/-/-/-/-/-/-/Connected to \(String(describing: beacon?.name))")
        disconnectBtn.isEnabled = true

    }
    
    @IBAction func updateTapped(_ sender: Any) {
        updateIBeacon()
    }
    
    
    @IBAction func disconnetTapped(_ sender: Any) {
        debugPrint("Disconnecting Beacon")
        beacon?.disconnect()
        
    }
    
    
    @IBAction func uploadTapped(_ sender: Any) {
        
        
    }
    
    
    
    func onBeaconDiscovered(beacons: [kbeaconlib2.KBeacon]) {
        for beacon in beacons {
            printScanPacket(beacon)
            beaconArr.append(beacon)
            debugPrint("Beacon Found!-/-/\(String(describing: beacon.uuidString))")
        }
        connectBtn.isEnabled = true
    }
    
    func onCentralBleStateChange(newState: kbeaconlib2.BLECentralMgrState) {
        if (newState == BLECentralMgrState.PowerOn)
            {
                NSLog("central ble state power on")
            }
    }
    
    func onConnStateChange(_ beacon: kbeaconlib2.KBeacon, state: kbeaconlib2.KBConnState, evt: kbeaconlib2.KBConnEvtReason) {
        
        if (state == KBConnState.Connecting)
            {
                updateBtn.isEnabled = true
                debugPrint("-/-/-/-/-/Connecting to device");
           }
           else if (state == KBConnState.Connected)
           {
                debugPrint("-/-/-/-/-/Device connected");
//                updateBtn.isEnabled = true

           }
           else if (state == KBConnState.Disconnected)
           {
               debugPrint("-/-/-/-/-/Device disconnected");
               if (evt == KBConnEvtReason.ConnAuthFail)
               {
//                   NSLog("auth failed");
//                   self.showPasswordInputDlg(self.beacon!)
               }
           }
    }
    
    func updateIBeacon(){
//        if (self.beacon!.state != KBConnState.Connected)
//            {
//                print("beacon not connected")
//                return;
//            }
        let iBeaconCfg = KBCfgAdvIBeacon()
        iBeaconCfg.setSlotIndex(0)
        //  modify ibeacon UUID using this code
//            if let uuid = txtBeaconUUID.text,
//               uuid.isUUIDString()
//            {
//                iBeaconCfg.setUuid(uuid)
//            }
//            else
//            {
//                self.showDialogMsg("error", message:"uuid format is invalid")
//                return
//            }

        iBeaconCfg.setUuid(beacon?.uuidString ?? "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")
        //  old major & minor are : 10064 & 26049
        //  modify ibeacon major id
        iBeaconCfg.setMajorID(00000)
        //  modify ibeacon major id
        iBeaconCfg.setMinorID(12121)
        iBeaconCfg.setAdvTriggerOnly(false)
        iBeaconCfg.setAdvConnectable(true)
        
        beacon!.modifyConfig(obj: iBeaconCfg, callback: { (result, exception) in
                if (result)
                {
                    debugPrint("config success")
                }
                else if (exception != nil)
                {
                    if (exception!.errorCode == KBErrorCode.CfgBusy)
                    {
                        debugPrint("Config busy, please make sure other configruation complete")
                    }
                    else if (exception!.errorCode == KBErrorCode.CfgTimeout)
                    {
                        debugPrint("Config timeout")
                    }

                    debugPrint("config other error:\(exception!.errorCode)")
                }
            })
    }
    

    func printScanPacket(_ advBeacon: KBeacon)
    {
        //check if has packet
        guard let allAdvPackets = advBeacon.allAdvPackets else{
            return
        }

        print("--------scan device advertisment packet---------")


        for advPacket in allAdvPackets
        {
            switch advPacket.getAdvType()
            {
            case KBAdvType.IBeacon:
                //get majorID and minorID from advertisement packet
                //notify: this is not standard iBeacon protocol, we get minor ID from KKM private
                //scan response message
                if let iBeaconAdv = advPacket as? KBAdvPacketIBeacon
                {
                    print("-----iBeacon----")
                    print("major:\(iBeaconAdv.uuid!)")
                    print("major:\(iBeaconAdv.majorID)")
                    print("minor:\(iBeaconAdv.minorID)")
                }
            case KBAdvType.EddyURL:
                if let urlAdv = advPacket as? KBAdvPacketEddyURL
                {
//                    print("-----URL----")
//                    print("url:\(urlAdv.url)")
                }

            case KBAdvType.EddyUID:
                if let uidAdv = advPacket as? KBAdvPacketEddyUID
                {
//                    print("-----UID----")
//                    print("nid:\(uidAdv.nid ?? "")")
//                    print("nid:\(uidAdv.sid ?? "")")
                }

            case KBAdvType.EddyTLM:
                if let tlmAdv = advPacket as? KBAdvPacketEddyTLM
                {
//                    print("-----TLM----")
//                    print("secondCount:\(tlmAdv.secCount/10)")
//                    print("batt:\(tlmAdv.batteryLevel)")
//                    print("temp:\(tlmAdv.temperature)")
//                    print("temp:\(tlmAdv.temperature)")
                }

            case KBAdvType.Sensor:
                if let sensorAdv = advPacket as? KBAdvPacketSensor
                {
//                    print("-----Sensor----")
//                    //check if has battery level
//                    if (sensorAdv.batteryLevel != KBCfgBase.INVALID_UINT16)
//                    {
//                        print("batt:\(sensorAdv.batteryLevel)")
//                    }

//                    //check if has temperature
//                    if (sensorAdv.temperature != KBCfgBase.INVALID_FLOAT)
//                    {
//                        print("temp:\(sensorAdv.temperature)")
//                    }

//                    //check if has humidity
//                    if (sensorAdv.humidity != KBCfgBase.INVALID_FLOAT)
//                    {
//                        print("humidity:\(sensorAdv.humidity)")
//                    }

//                    //check if has acc sensor
//                    if let axisValue = sensorAdv.accSensor
//                    {
//                        print("  xAis:\(axisValue.xAis)")
//                        print("  yAis:\(axisValue.yAis)")
//                        print("  zAis:\(axisValue.zAis)")
//                    }

//                    //check if has pir indication
//                    if (KBCfgBase.INVALID_UINT8 != sensorAdv.pirIndication)
//                    {
//                        print("PIR indication:\(sensorAdv.pirIndication)")
//                    }
//
//                    //check if has light level
//                    if (KBCfgBase.INVALID_UINT16 != sensorAdv.luxLevel)
//                    {
//                        print("Light level:\(sensorAdv.luxLevel)")
//                    }
                }

            case KBAdvType.System:
                if let systemAdv = advPacket as? KBAdvPacketSystem
                {
//                    print("-----System----")
//                    print("mac:\(systemAdv.macAddress!)")
//                    print("batt:\(systemAdv.batteryPercent)")
//                    print("modelNo:\(systemAdv.model)")
//                    print("ver:\(systemAdv.firmwareVersion)")
                }
            default:
                print("unknown packet")
            }
        }

        //remove buffered packet
//        advBeacon.removeAdvPacket()
    }
}

