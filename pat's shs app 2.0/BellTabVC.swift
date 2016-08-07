//
//  BellTabVC.swift
//  Pat'sshsapp
//
//  Created by Patrick Li on 10/11/15.
//


import UIKit

class BellTabVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var segmentBarRedOrBlue: UISegmentedControl!
    @IBOutlet weak var segmentBarDays: UISegmentedControl!
    @IBOutlet weak var timeBar: UILabel!
    @IBOutlet weak var timeBarLabel: UILabel!
    @IBOutlet weak var segmentBar: UILabel!
    @IBOutlet weak var tableView1: UITableView!
    
    var cell: PeriodTimesCell!
    var timesArray: [String]! = []
    var actualTimes: [String]! = []
    var inPeriod = false
    var periodArray: [String]! = []
    var currTime = 0
    var currDate = 0
    var hour = 0
    var tempHour = 0
    var amOrPm = ""
    var minutes = 0
    var totalCurrMinutes = 0
    var second = 0
    var date = NSDate()
    var calendar = NSCalendar.currentCalendar()
    var currPeriod = 20
    var startMin = 0
    var endMin = 0
    var currTableView = 2
    var dayOfWeek = 0

    var BlueMinutesTotal : [Int] = []
    var BlueHoursTotal : [Int] = []
    var RedMinutesTotal : [Int] = []
    var RedHoursTotal : [Int] = []

    var counter: Float = 0

    var redDay: Bool = true
    var redWeek: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView1.delegate = self
        tableView1.dataSource = self

        if (self.segmentBarRedOrBlue.selectedSegmentIndex == 0) {
            redDay = true
            self.segmentBar.backgroundColor = UIColor(red: 225/255, green: 0, blue: 0, alpha: 1)
            self.timeBar.backgroundColor = UIColor(red: 222/255, green: 127/255, blue: 129/255, alpha: 1)
        }
        else{
            redDay = false
            self.segmentBar.backgroundColor = UIColor(red: 0, green: 122/255, blue: 224/255, alpha: 1)
            self.timeBar.backgroundColor = UIColor(red: 0, green: 122/255, blue: 224/255, alpha: 0.7)
        }


        inPeriod = false
        date = NSDate()
        calendar = NSCalendar.currentCalendar()
        var components = calendar.components(NSCalendarUnit.Year.union(NSCalendarUnit.Minute).union(NSCalendarUnit.Hour).union(NSCalendarUnit.Month).union(NSCalendarUnit.Day).union(NSCalendarUnit.Second), fromDate: date)
        self.hour = components.hour
        self.minutes = components.minute
        self.second = components.second
        var month = components.month
        var year = components.year
        var day = components.day
        
        let currDate = "\(year)-\(month)-\(day)"
        dayOfWeek = getDayOfWeek(currDate)
        currTableView = dayOfWeek

        if(dayOfWeek == 2){
            segmentBarDays.selectedSegmentIndex = 0
        }
        else if(dayOfWeek == 3){
            segmentBarDays.selectedSegmentIndex = 1
        }
        else if(dayOfWeek == 4){
            segmentBarDays.selectedSegmentIndex = 2
        }
        else if(dayOfWeek == 5){
            segmentBarDays.selectedSegmentIndex = 3
        }
        else if(dayOfWeek == 6){
            segmentBarDays.selectedSegmentIndex = 4
        }
        else {
            segmentBarDays.selectedSegmentIndex = 0
        }

        if(segmentBarDays.selectedSegmentIndex+1 % 2 == 0){
            if(self.segmentBarRedOrBlue.selectedSegmentIndex == 0){
                self.redWeek = false
            }
            else{
                self.redWeek = true
            }
        }else{
            if(self.segmentBarRedOrBlue.selectedSegmentIndex == 0){
                self.redWeek = true
            }
            else{
                self.redWeek = false
            }
        }

        if(dayOfWeek > 6){
            if(redDay){
                setTableView("R")
            }
            else{
                setTableView("B")
            }
        }
        else{
            if((dayOfWeek-1) % 2 == 0){
                if(redWeek){
                    actualTimes = ["8:15 - 9:45", "9:45 - 10:20", "10:25 - 12:00",
                        "12:00 - 12:35", "12:40 - 2:10"]
                    setTableView("B")
                    self.redDay = false
                }
                else{
                    actualTimes = ["8:15 - 9:45", "9:45 - 10:20", "10:25 - 12:00",
                        "12:00 - 12:35", "12:40 - 2:10", "2:15 - 3:45"]
                    setTableView("R")
                    self.redDay = true
                }
            }
            else{
                if(redWeek){
                    actualTimes = ["8:15 - 9:45", "9:45 - 10:20", "10:25 - 12:00",
                        "12:00 - 12:35", "12:40 - 2:10", "2:15 - 3:45"]
                    setTableView("R")
                    self.redDay = true
                }
                else{
                    actualTimes = ["8:15 - 9:45", "9:45 - 10:20", "10:25 - 12:00",
                        "12:00 - 12:35", "12:40 - 2:10"]
                    setTableView("B")
                    self.redDay = false
                }
            }
        }

        
        tempHour = components.hour
        if(hour > 12){
            tempHour = hour - 12
            amOrPm = "P.M."
        }
        else{
            amOrPm = "A.M."
        }
        timeBarLabel.textAlignment = .Center
        scheduledTimerWithTimeInterval()
    }
    
    func scheduledTimerWithTimeInterval(){
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    func timeLeft(startMin: Int, endMin: Int) -> Float{
        let totalTime = endMin - startMin
        let currMinIntoPeriod = totalCurrMinutes - startMin
        let fraction: Float = Float(currMinIntoPeriod) / Float(totalTime)
        
        return fraction
    }

    func update() {
        date = NSDate()
        calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Year.union(NSCalendarUnit.Minute)
            .union(NSCalendarUnit.Hour).union(NSCalendarUnit.Month).union(NSCalendarUnit.Day).union(NSCalendarUnit.Second).union(NSCalendarUnit.Weekday), fromDate: date)
        second = components.second
        hour = components.hour
        minutes = components.minute
        totalCurrMinutes = hour*60 + minutes
        
        var timeLeftInPeriod: Int
        if(actualTimes.count == 0){
            timeBarLabel.text = "School's Out!"
        }

        else if(self.redDay){
            for(var i=0; i<actualTimes.count*2; i=i+2){
                if(totalCurrMinutes >= RedMinutesTotal[i] && totalCurrMinutes < RedMinutesTotal[i+1]){
                    inPeriod = true
                    if(i<=1){
                        timeLeftInPeriod = RedMinutesTotal[i+1] - totalCurrMinutes
                        timeBarLabel.text = String(timeLeftInPeriod) + " minutes remaining"
                        currPeriod = 0
                        startMin = RedMinutesTotal[i]
                        endMin = RedMinutesTotal[i+1]
                    }
                    else if(i<=3){
                        timeLeftInPeriod = RedMinutesTotal[i+1] - totalCurrMinutes
                        timeBarLabel.text = String(timeLeftInPeriod) + " minutes remaining"
                        currPeriod = 1
                        startMin = RedMinutesTotal[i]
                        endMin = RedMinutesTotal[i+1]
                    }
                    else if(i<=5){
                        timeLeftInPeriod = RedMinutesTotal[i+1] - totalCurrMinutes
                        timeBarLabel.text = String(timeLeftInPeriod) + " minutes remaining"
                        currPeriod = 2
                        startMin = RedMinutesTotal[i]
                        endMin = RedMinutesTotal[i+1]
                    }
                    else if(i<=7){
                        timeLeftInPeriod = RedMinutesTotal[i+1] - totalCurrMinutes
                        timeBarLabel.text = String(timeLeftInPeriod) + " minutes remaining"
                        currPeriod = 3
                        startMin = RedMinutesTotal[i]
                        endMin = RedMinutesTotal[i+1]
                    }
                    else if(i<=9){
                        timeLeftInPeriod = RedMinutesTotal[i+1] - totalCurrMinutes
                        timeBarLabel.text = String(timeLeftInPeriod) + " minutes remaining"
                        currPeriod = 4
                        startMin = RedMinutesTotal[i]
                        endMin = RedMinutesTotal[i+1]
                    }
                    else if(i<=11){
                        timeLeftInPeriod = RedMinutesTotal[i+1] - totalCurrMinutes
                        timeBarLabel.text = String(timeLeftInPeriod) + " minutes remaining"
                        currPeriod = 5
                        startMin = RedMinutesTotal[i]
                        endMin = RedMinutesTotal[i+1]
                    }
                }

                else if (totalCurrMinutes < RedMinutesTotal[0] || totalCurrMinutes >= RedMinutesTotal[RedMinutesTotal.count-1]){
                    timeBarLabel.text = "School's Out!"
                }
            }
        }
        else if(self.redDay == false){
            for(var i=0; i<actualTimes.count*2; i=i+2){
                if(totalCurrMinutes >= BlueMinutesTotal[i] && totalCurrMinutes < BlueMinutesTotal[i+1]){
                    inPeriod = true
                    if(i<=1){
                        timeLeftInPeriod = BlueMinutesTotal[i+1] - totalCurrMinutes
                        timeBarLabel.text = String(timeLeftInPeriod) + " minutes remaining"
                        currPeriod = 0
                        startMin = BlueMinutesTotal[i]
                        endMin = BlueMinutesTotal[i+1]
                    }
                    else if(i<=3){
                        timeLeftInPeriod = BlueMinutesTotal[i+1] - totalCurrMinutes
                        timeBarLabel.text = String(timeLeftInPeriod) + " minutes remaining"
                        currPeriod = 1
                        startMin = BlueMinutesTotal[i]
                        endMin = BlueMinutesTotal[i+1]
                    }
                    else if(i<=5){
                        timeLeftInPeriod = BlueMinutesTotal[i+1] - totalCurrMinutes
                        timeBarLabel.text = String(timeLeftInPeriod) + " minutes remaining"
                        currPeriod = 2
                        startMin = BlueMinutesTotal[i]
                        endMin = BlueMinutesTotal[i+1]
                    }
                    else if(i<=7){
                        timeLeftInPeriod = BlueMinutesTotal[i+1] - totalCurrMinutes
                        timeBarLabel.text = String(timeLeftInPeriod) + " minutes remaining"
                        currPeriod = 3
                        startMin = BlueMinutesTotal[i]
                        endMin = BlueMinutesTotal[i+1]
                    }
                    else if(i<=9){
                        timeLeftInPeriod = BlueMinutesTotal[i+1] - totalCurrMinutes
                        timeBarLabel.text = String(timeLeftInPeriod) + " minutes remaining"
                        currPeriod = 4
                        startMin = BlueMinutesTotal[i]
                        endMin = BlueMinutesTotal[i+1]
                    }
                }
                else if (totalCurrMinutes < BlueMinutesTotal[0] || totalCurrMinutes >= BlueMinutesTotal[BlueMinutesTotal.count-1]){
                    timeBarLabel.text = "School's Out!"
                }
            }
        }

        else{
            timeBarLabel.text = "School's Out!"
        }

        tableView1.reloadData()

    }
    func getDayOfWeek(today:String)->Int {
        
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = formatter.dateFromString(today)!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
        let weekDay = myComponents.weekday
        return weekDay
    }
    
    @IBAction func daySelected(sender: AnyObject) {
        self.findTypeDay(sender.selectedSegmentIndex+1)
    }

    func findTypeDay(selection: Int){
        if(selection % 2 == 0){
            if(redWeek){
                setTableView("B")
            }
            else{
                setTableView("R")
            }
        }
        else{
            if(redWeek){
                print("red")
                setTableView("R")
            }
            else{
                print("blue")
                setTableView("B")
            }
        }
    }

    @IBAction func colorSelected(sender: AnyObject) {
        if(redWeek == true){
            redWeek = false
            print("blue")
            self.findTypeDay(self.segmentBarDays.selectedSegmentIndex+1)
        }
        else{
            print("red")
            print(segmentBarRedOrBlue.selectedSegmentIndex)
            redWeek = true
            self.findTypeDay(self.segmentBarDays.selectedSegmentIndex+1)
        }

        switch sender.selectedSegmentIndex {
        case 0:
            self.redDay = true
            self.segmentBar.backgroundColor = UIColor(red: 225/255, green: 0, blue: 0, alpha: 1)
            self.timeBar.backgroundColor = UIColor(red: 222/255, green: 127/255, blue: 129/255, alpha: 1)
        case 1:
            self.redDay = false
            self.segmentBar.backgroundColor = UIColor(red: 0, green: 122/255, blue: 224/255, alpha: 1)
            self.timeBar.backgroundColor = UIColor(red: 0, green: 122/255, blue: 224/255, alpha: 0.7)
        default:
            self.segmentBar.backgroundColor = UIColor(red: 225/255, green: 0, blue: 0, alpha: 1)


        }
    }

    
    func setHoursAndMinutes(day: String, time: String){
        var originalString = time
        let dashIndex = originalString.lowercaseString.characters.indexOf("-")
        let dashIndexString = "\(dashIndex!)"
        let DashIndexInt = Int(dashIndexString)!
        
        //---------------------------------------
        
        //left of dash
        let leftOfDashRange = originalString.startIndex.advancedBy(0)..<originalString.startIndex.advancedBy(DashIndexInt-1)
        //let leftOfDashRange = advance(originalString.startIndex, 0)..<advance(originalString.startIndex, DashIndexInt-1)
        let leftOfDashString = originalString[leftOfDashRange]
        
        let colonIndex = leftOfDashString.lowercaseString.characters.indexOf(":")
        let colonIndexString = "\(colonIndex!)"
        let colonIndexInt = Int(colonIndexString)!
        
        //left of colon
        let leftOfColonRange = leftOfDashString.startIndex.advancedBy(0)..<leftOfDashString.startIndex.advancedBy(colonIndexInt)
        //let leftOfColonRange = advance(leftOfDashString.startIndex, 0)..<advance(leftOfDashString.startIndex, colonIndexInt)
        let leftOfColonString = leftOfDashString[leftOfColonRange]
        var leftOfColonInt = Int(leftOfColonString)!
        
        //right of colon
        let rightOfColonRange = leftOfDashString.startIndex.advancedBy(colonIndexInt+1)..<leftOfDashString.endIndex.advancedBy(0)
        //let rightOfColonRange = advance(leftOfDashString.startIndex, colonIndexInt+1)..<advance(leftOfDashString.endIndex, 0)
        let rightOfColonString = leftOfDashString[rightOfColonRange]
        var rightOfColonInt = Int(rightOfColonString)!
        
        //------------------------------------------
        
        //right of dash
        let rightOfDashRange = originalString.startIndex.advancedBy(DashIndexInt+2)..<originalString.endIndex.advancedBy(0)
        //let rightOfDashRange = advance(originalString.startIndex, DashIndexInt+2)..<advance(originalString.endIndex, 0)
        let rightOfDashString = originalString[rightOfDashRange]
        let colonIndex2 = rightOfDashString.lowercaseString.characters.indexOf(":")
        let colonIndexString2 = "\(colonIndex2!)"
        var colonIndexInt2 = Int(colonIndexString2)!
        
        //left of colon
        let leftOfColonRange2 = rightOfDashString.startIndex.advancedBy(0)..<rightOfDashString.startIndex.advancedBy(colonIndexInt2)
        //let leftOfColonRange2 = advance(rightOfDashString.startIndex, 0)..<advance(rightOfDashString.startIndex, colonIndexInt2)
        let leftOfColonString2 = rightOfDashString[leftOfColonRange2]
        var leftOfColonInt2 = Int(leftOfColonString2)!
        
        //right of colon
        let rightOfColonRange2 = rightOfDashString.startIndex.advancedBy(colonIndexInt2+1)..<rightOfDashString.endIndex.advancedBy(0)
        //let rightOfColonRange2 = advance(rightOfDashString.startIndex, colonIndexInt2+1)..<advance(rightOfDashString.endIndex, 0)
        let rightOfColonString2 = rightOfDashString[rightOfColonRange2]
        var rightOfColonInt2 = Int(rightOfColonString2)!
        
        if(leftOfColonInt == 1){
            leftOfColonInt = 13
        }
        if(leftOfColonInt == 2){
            leftOfColonInt = 14
        }
        if(leftOfColonInt == 3){
            leftOfColonInt = 15
        }
        if(leftOfColonInt2 == 1){
            leftOfColonInt2 = 13
        }
        if(leftOfColonInt2 == 2){
            leftOfColonInt2 = 14
        }
        if(leftOfColonInt2 == 3){
            leftOfColonInt2 = 15
        }
        
        if(day == "B"){
            self.BlueHoursTotal.append(leftOfColonInt*60 + rightOfColonInt)
            self.BlueMinutesTotal.append(leftOfColonInt2*60 + rightOfColonInt2)
        }
        else if(day == "R"){
            self.RedHoursTotal.append(leftOfColonInt*60 + rightOfColonInt)
            self.RedMinutesTotal.append(leftOfColonInt2*60 + rightOfColonInt2)
        }

    }
    func setTableView(day: String){
        if(day == "R"){
            timesArray = ["8:15 - 9:45", "9:45 - 10:20", "10:25 - 12:00",
                "12:00 - 12:35", "12:40 - 2:10", "2:15 - 3:45"]
            periodArray = ["1", "T", "3", "L", "5", "7"]
            for(var i=0; i<timesArray.count; i++){
                setHoursAndMinutes("R", time: timesArray[i])
            }
        }
        else if(day == "B"){
            timesArray = ["8:15 - 9:45", "9:45 - 10:20", "10:25 - 12:00",
                "12:00 - 12:35", "12:40 - 2:10"]
            periodArray = ["2", "T", "4", "L", "6"]
            for(var i=0; i<timesArray.count; i++){
                setHoursAndMinutes("B", time: timesArray[i])
            }
        }
        tableView1.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PeriodTimesCell
        cell.timesLabel.text = timesArray[indexPath.row]
        cell.timesLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 22)
        cell.timesLabel?.textAlignment = .Center
        cell.periodLabel.text = periodArray[indexPath.row]
        cell.periodLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22)
        cell.periodLabel.textAlignment = .Left
        cell.userInteractionEnabled = false;
        
        if(currTableView == dayOfWeek)
        {
            if(indexPath.row == currPeriod)
            {
                cell.showProgressBar()
                cell.progressBar.setProgress(timeLeft(startMin, endMin: endMin), animated: true)
            }
            else
            {
                cell.hideProgressBar()
            }
        }
        else
        {
            cell.hideProgressBar()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let screenHeight = UIScreen.mainScreen().bounds.height
        let heightOfTableView = screenHeight - segmentBar.frame.size.height - timeBar.frame.size.height
            - self.tabBarController!.tabBar.frame.height
        
        return heightOfTableView / CGFloat(timesArray.count)
    }
    
    
    
}