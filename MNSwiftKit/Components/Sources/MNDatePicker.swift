//
//  MNDatePicker.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/9/16.
//  日期选择器

import UIKit

// MARK: - MNDatePicker
public class MNDatePicker: UIView {
    
    /// 语言
    public enum Language: Int {
        /// 阿拉伯语
        case arabic
        /// 中文
        case chinese
        /// 英文
        case english
    }
    
    /// 日期组件
    public enum Module {
        /// 年（分隔符 是否简写）
        case year(separator: String, abbr: Bool)
        /// 月（分隔符 语言 是否简写）
        case month(separator: String, lang: MNDatePicker.Language, abbr: Bool)
        /// 日（分隔符 是否简写）
        case day(separator: String, abbr: Bool)
        /// 时（分隔符 是否12时制 语言<仅对12时制有效> 是否简写）
        case hour(separator: String, clock: MNDatePicker.Formater.Clock, lang: MNDatePicker.Language, abbr: Bool)
        /// 分（分隔符 是否简写）
        case minute(separator: String, abbr: Bool)
        /// 秒（分隔符 是否简写）
        case second(separator: String, abbr: Bool)
    }
    
    /// 格式化风格
    public class Formater {
        
        /// 分割符
        public enum Separator {
            case none, dash, colon, slash, space
            case custom(_ separator: String)
            
            /// 符号=>字符串
            public var rawString: String {
                switch self {
                case .none: return ""
                case .dash: return "-"
                case .colon: return ":"
                case .slash: return "/"
                case .space: return " "
                case .custom(let separator): return separator
                }
            }
        }
        
        /// 时制
        public enum Clock: Int {
            case iso12, iso24
        }
        
        /// 支持的时制
        fileprivate var clock: Clock = .iso24
        
        /// 支持的语言
        fileprivate var lang: Language = .arabic
        
        /// 日期选择器模块集合
        fileprivate var modules: [MNDatePicker.Module] = [MNDatePicker.Module]()
        
        /// 以小时制构造初始化器
        /// - Parameter clock: 小时制
        public init(clock: Clock) {
            self.clock = clock
        }
        
        /// 以语言类型构造初始化器
        /// - Parameter lang: 语言
        public init(lang: Language) {
            self.lang = lang
        }
        
        /// 以日期选择器组件构造初始化器
        /// - Parameter modules: 日期选择器组件集合
        fileprivate init(modules: [MNDatePicker.Module]) {
            self.modules.append(contentsOf: modules)
            if let clock = modules.hour?.clock {
                self.clock = clock
            }
            if let lang = modules.month?.lang {
                self.lang = lang
            } else if let lang = modules.hour?.lang {
                self.lang = lang
            }
        }
    }
    
    /// 日期配件模型
    fileprivate class Component {
        
        /// 配件类型
        enum Style {
            case year, month, day, hour, minute, second, stage, suffix
        }
        
        /// 配件宽度
        var width: CGFloat = 0.0
        /// 行数
        var rows: [String] = [String]()
        /// 配件类型
        let style: MNDatePicker.Component.Style
        
        /// 类型构造器
        /// - Parameter style: 指定类型
        init(style: Style) {
            self.style = style
        }
        
        /// 设置配件宽度
        /// - Parameters:
        ///   - font: 字体
        ///   - padding: 追加宽度
        func widthToFit(font: UIFont, padding: CGFloat) {
            let width = rows.reduce(0.0, { partialResult, string in
                let w = (string as NSString).size(withAttributes: [.font:font]).width
                return max(w, partialResult)
            })
            self.width = ceil(width) + padding
        }
    }
    
    /// 字体
    public var font: UIFont = .systemFont(ofSize: 16.0, weight: .medium)
    /// 字体颜色
    public var textColor: UIColor?
    /// 起始日期 (用来确定年配件起始值)
    public var minimumDate: Date = Date(timeIntervalSince1970: 0.0)
    /// 结束日期 (用来确定年配件结束值)
    public var maximumDate: Date = Date()
    /// 配件行高
    public var rowHeight: CGFloat = 40.0
    /// 配件间隔
    public var spacing: CGFloat = 13.0
    /// 配件集合
    private var components: [Component] = [Component]()
    /// 组件集合
    private var modules: [Module] = [.year(separator: "-", abbr: false), .month(separator: "-", lang: .arabic, abbr: false), .day(separator: " ", abbr: false), .hour(separator: ":", clock: .iso24, lang: .arabic, abbr: false), .minute(separator: ":", abbr: false), .second(separator: "", abbr: false)]
    /// 选择器着色
    public override var tintColor: UIColor! {
        get { picker.tintColor }
        set { picker.tintColor = newValue }
    }
    /// 格式化样式
    public var dateFormat: Formater {
        get { .init(modules: modules) }
        set {
            let date = modules.isEmpty ? nil : date
            modules.removeAll()
            modules.append(contentsOf: newValue.modules)
            reloadComponents()
            if let date = date {
                setDate(date, animated: false)
            }
        }
    }
    /// 选择器
    private lazy var picker: UIPickerView = {
        let picker = UIPickerView(frame: bounds)
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .clear
        picker.tintColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    /// 日历
    private lazy var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = .current
        return calendar
    }()
    /// 显示日期
    private var rowLabel: UILabel {
        let label = UILabel()
        label.font = font
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = textColor ?? .black
        return label
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(picker)
        addConstraints([
            NSLayoutConstraint(item: picker, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: picker, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: picker, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: picker, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func sizeToFit() {
        let contentSize = contentSize
        let autoresizingMask = autoresizingMask
        self.autoresizingMask = []
        var rect: CGRect = frame
        rect.size = contentSize
        frame = rect
        self.autoresizingMask = autoresizingMask
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if let _ = newSuperview, components.isEmpty {
            setDate(maximumDate, animated: false)
        }
        super.willMove(toSuperview: newSuperview)
    }
}

// MARK: - Setter
extension MNDatePicker {
    
    /// 指定选择日期
    /// - Parameters:
    ///   - date: 日期
    ///   - animated: 是否使用动画
    public func setDate(_ date: Date, animated: Bool) {
        
        // 刷新配件
        if components.isEmpty {
            reloadComponents()
        }
        
        // 时间配件
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        for (index, component) in components.enumerated() {
            switch component.style {
            case .year:
                // 年
                guard let module = modules.year else { continue }
                var string = NSNumber(value: dateComponents.year!).stringValue
                if module.isAbbr {
                    let begin = string.startIndex
                    let end = string.index(string.startIndex, offsetBy: 1)
                    string.removeSubrange(begin...end)
                }
                if let idx = component.rows.firstIndex(of: string) {
                    picker.selectRow(idx, inComponent: index, animated: animated)
                }
            case .month:
                // 月
                let month = dateComponents.month!
                if component.rows.count >= month {
                    picker.selectRow(month - 1, inComponent: index, animated: animated)
                }
            case .day:
                // 日 先刷新日配件
                reloadDayComponent()
                let day = dateComponents.day!
                if component.rows.count >= day {
                    picker.selectRow(day - 1, inComponent: index, animated: animated)
                }
            case .stage:
                // 时段 说明是12小时制
                let hour = dateComponents.hour!
                picker.selectRow(hour < 12 ? 0 : 1, inComponent: index, animated: animated)
            case .hour:
                // 时
                guard let module = modules.hour else { continue }
                var hour = dateComponents.hour!
                if module.clock == .iso12 {
                    // 先刷新时配件
                    reloadHourComponent()
                    if hour > 12 {
                        hour -= 12
                    }
                    if let row = component.rows.firstIndex(where: { NSDecimalNumber(string: $0).intValue == hour }) {
                        picker.selectRow(row, inComponent: index, animated: animated)
                    }
                } else if component.rows.count > hour {
                    picker.selectRow(hour, inComponent: index, animated: animated)
                }
            case .minute:
                // 分
                let minute = dateComponents.minute!
                if component.rows.count > minute {
                    picker.selectRow(minute, inComponent: index, animated: animated)
                }
            case .second:
                // 秒
                let second = dateComponents.second!
                if component.rows.count > second {
                    picker.selectRow(second, inComponent: index, animated: animated)
                }
            default: break
            }
        }
    }
}

// MARK: - Getter
extension MNDatePicker {
    
    /// 获取当前选择的日期
    public var date: Date {
        
        // 构造时间配件
        var dateComponents = DateComponents()
        
        // 年
        dateComponents.year = 1970
        if let index = components.firstIndex(where: { $0.style == .year }) {
            let component = components[index]
            let row = picker.selectedRow(inComponent: index)
            let string = year(for: component.rows[row])
            dateComponents.year = NSDecimalNumber(string: string).intValue
        }
        // 月
        dateComponents.month = 1
        if let index = components.firstIndex(where: { $0.style == .month }) {
            let row = picker.selectedRow(inComponent: index)
            dateComponents.month = row + 1
        }
        // 日
        dateComponents.day = 1
        if let index = components.firstIndex(where: { $0.style == .day }) {
            let row = picker.selectedRow(inComponent: index)
            dateComponents.day = row + 1
        }
        // 时
        dateComponents.hour = 0
        if let index = components.firstIndex(where: { $0.style == .hour }), let module = modules.hour {
            let row = picker.selectedRow(inComponent: index)
            var hour = NSDecimalNumber(string: components[index].rows[row]).intValue
            if module.clock == .iso12, let section = components.firstIndex(where: { $0.style == .stage }), picker.selectedRow(inComponent: section) == 1, hour < 12  {
                // 需要转换为24时制
                hour += 12
            }
            dateComponents.hour = hour
        }
        // 分
        dateComponents.minute = 0
        if let index = components.firstIndex(where: { $0.style == .minute }) {
            let row = picker.selectedRow(inComponent: index)
            dateComponents.minute = row
        }
        // 秒
        dateComponents.second = 0
        if let index = components.firstIndex(where: { $0.style == .second }) {
            let row = picker.selectedRow(inComponent: index)
            dateComponents.second = row
        }
        // 生成时间
        return calendar.date(from: dateComponents) ?? Date()
    }
    
    /// 获取选择器最佳尺寸
    private var contentSize: CGSize {
        if components.isEmpty {
            reloadComponents()
        }
        let width = components.reduce(0.0, { $0 + $1.width }) + 100.0
        return CGSize(width: width, height: max(frame.height, 245.0))
    }
    
    /// 获取分割符配件
    /// - Parameter separator: 分割符
    /// - Returns: 分割符配件
    private func component(separator: String) -> Component {
        let component = Component(style: .suffix)
        component.rows.append(separator)
        component.widthToFit(font: font, padding: 0.0)
        return component
    }
    
    /// 依据条件获取午段配件数据
    /// - Parameters:
    ///   - lang: 语言
    ///   - abbr: 使用简写形式
    /// - Returns: 午段集合
    private func stages(for lang: MNDatePicker.Language, abbr: Bool) -> [String] {
        switch lang {
        case .chinese: return ["上午", "下午"]
        default: return abbr ? ["A", "P"] : ["AM", "PM"]
        }
    }
    
    /// 依据条件获取月配件数据
    /// - Parameters:
    ///   - lang: 语言
    ///   - abbr: 使用简写形式
    /// - Returns: 月份集合
    private func months(for lang: MNDatePicker.Language, abbr: Bool) -> [String] {
        switch lang {
        case .arabic:
            return abbr ? ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"] : ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        case .english:
            return abbr ? ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"] : ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        case .chinese: return ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
        }
    }
    
    /// 获取年份全写
    /// - Parameter string: 年份
    /// - Returns: 年份全写
    private func year(for string: String) -> String {
        let year: Int = NSDecimalNumber(string: string).intValue
        guard year < 100 else { return string }
        let century: String = year >= 70 ? "19" : "20"
        return century + string
    }
}

// MARK: - Reload
extension MNDatePicker {
    
    /// 重载配件
    public func reloadComponents() {
        
        components.removeAll()
        
        // 年
        if let module = modules.year {
            
            var minimumYear: Int = calendar.dateComponents([.year], from: minimumDate).year!
            var maximumYear: Int = calendar.dateComponents([.year], from: maximumDate).year!
            if maximumYear < minimumYear {
                minimumYear = 1970
            }
            maximumYear = max(maximumYear, 1970)
            
            let isAbbr: Bool = module.isAbbr
            let range = minimumYear...maximumYear
            let years = range.compactMap { year in
                var string = "\(year)"
                if isAbbr {
                    let begin = string.startIndex
                    let end = string.index(string.startIndex, offsetBy: 1)
                    string.removeSubrange(begin...end)
                }
                return string
            }
            let component = Component(style: .year)
            component.rows.append(contentsOf: years)
            component.widthToFit(font: font, padding: spacing)
            components.append(component)
            if module.separator.isEmpty == false {
                components.append(self.component(separator: module.separator))
            }
        }
        
        // 月
        if let module = modules.month {
            let component = Component(style: .month)
            component.rows = months(for: module.lang, abbr: module.isAbbr)
            component.widthToFit(font: font, padding: spacing)
            components.append(component)
            if module.separator.isEmpty == false {
                components.append(self.component(separator: module.separator))
            }
        }
        
        // 日
        if let module = modules.day {
            let isAbbr: Bool = module.isAbbr
            let range = 1...31
            let days = range.compactMap { day in
                var string: String = "\(day)"
                if isAbbr == false, string.count == 1 {
                    string.insert("0", at: string.startIndex)
                }
                return string
            }
            let component = Component(style: .day)
            component.rows.append(contentsOf: days)
            component.width = ceil(("00" as NSString).size(withAttributes: [.font:font]).width) + spacing
            //component.widthToFit(font: font, padding: spacing)
            components.append(component)
            if module.separator.isEmpty == false {
                components.append(self.component(separator: module.separator))
            }
        }
        
        // 时
        if let module = modules.hour {
            let clock = module.clock
            let isAbbr = module.isAbbr
            if clock == .iso12 {
                // 时段
                let component = Component(style: .stage)
                component.rows = stages(for: module.lang, abbr: isAbbr)
                component.widthToFit(font: font, padding: 10.0)
                components.append(component)
            }
            let range = clock == .iso12 ? 0...12 : 0...23
            let hours = range.compactMap { hour in
                var string = "\(hour)"
                if isAbbr == false, string.count == 1 {
                    string.insert("0", at: string.startIndex)
                }
                return string
            }
            let component = Component(style: .hour)
            component.rows.append(contentsOf: hours)
            component.width = ceil(("00" as NSString).size(withAttributes: [.font:font]).width) + max(10.0, spacing - 3.0)
            components.append(component)
            if module.separator.isEmpty == false {
                components.append(self.component(separator: module.separator))
            }
        }
        
        // 分
        if let module = modules.minute {
            let isAbbr = module.isAbbr
            let range = 0...59
            let minutes = range.compactMap { minute in
                var string = "\(minute)"
                if isAbbr == false, string.count == 1 {
                    string.insert("0", at: string.startIndex)
                }
                return string
            }
            let component = Component(style: .minute)
            component.rows.append(contentsOf: minutes)
            component.width = ceil(("00" as NSString).size(withAttributes: [.font:font]).width) + max(10.0, spacing - 3.0)
            components.append(component)
            if module.separator.isEmpty == false {
                components.append(self.component(separator: module.separator))
            }
        }
        
        // 秒
        if let module = modules.second {
            let isAbbr = module.isAbbr
            let range = 0...59
            let seconds = range.compactMap { second in
                var string = "\(second)"
                if isAbbr == false, string.count == 1 {
                    string.insert("0", at: string.startIndex)
                }
                return string
            }
            let component = Component(style: .second)
            component.rows.append(contentsOf: seconds)
            component.width = ceil(("00" as NSString).size(withAttributes: [.font:font]).width) + max(10.0, spacing - 3.0)
            components.append(component)
            if module.separator.isEmpty == false {
                components.append(self.component(separator: module.separator))
            }
        }
        
        // 刷新选择器
        picker.reloadAllComponents()
        // 刷新日配件
        reloadDayComponent()
        // 刷新时配件
        reloadHourComponent()
    }
    
    /// 刷新日配件
    private func reloadDayComponent() {
        
        var dateComponents = DateComponents()
        
        guard let yearComponentIndex = components.firstIndex(where: { $0.style == .year }) else { return }
        
        guard let monthComponentIndex = components.firstIndex(where: { $0.style == .month }) else { return }
        
        guard let dayComponentIndex = components.firstIndex(where: { $0.style == .day }) else { return }
        
        let yearRowIndex = picker.selectedRow(inComponent: yearComponentIndex)
        let yearString = year(for: components[yearComponentIndex].rows[yearRowIndex])
        dateComponents.year = NSDecimalNumber(string: yearString).intValue
        
        let monthRowIndex = picker.selectedRow(inComponent: monthComponentIndex)
        dateComponents.month = monthRowIndex + 1
        
        dateComponents.day = 1
        
        // 日期
        guard let date = calendar.date(from: dateComponents) else { return }
        
        // 天数
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return }
        let numberOfDays = range.count
        
        // 日配件
        let dayComponent = components[dayComponentIndex]
        
        // 计算天数是否对应
        if dayComponent.rows.count == numberOfDays { return }
        if dayComponent.rows.count > numberOfDays {
            dayComponent.rows.removeSubrange(numberOfDays..<dayComponent.rows.count)
        } else {
            for day in dayComponent.rows.count..<numberOfDays {
                dayComponent.rows.append("\(day + 1)")
            }
        }
        picker.reloadComponent(dayComponentIndex)
    }
    
    /// 重载小时配件
    private func reloadHourComponent() {
        
        guard let stageComponentIndex = components.firstIndex(where: { $0.style == .stage }) else { return }
        let row = picker.selectedRow(inComponent: stageComponentIndex)
        
        guard let hourComponentIndex = components.firstIndex(where: { $0.style == .hour }) else { return }
        let hourComponent = components[hourComponentIndex]
        
        if row == 0 {
            // 上午 需要添加 0, 删除十二
            let first = hourComponent.rows.first!
            if NSDecimalNumber(string: first).intValue > 0 {
                hourComponent.rows.insert(first.count == 1 ? "0" : "00", at: 0)
            }
            hourComponent.rows.removeAll { NSDecimalNumber(string: $0).intValue == 12 }
        } else {
            // 下午 需要删除 0 添加12
            let last = hourComponent.rows.last!
            if NSDecimalNumber(string: last).intValue < 12 {
                hourComponent.rows.append("12")
            }
            hourComponent.rows.removeAll { NSDecimalNumber(string: $0).intValue == 0 }
        }
    
        picker.reloadComponent(hourComponentIndex)
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension MNDatePicker: UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        components.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        components[component].rows.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        components[component].width
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        rowHeight
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label: UILabel = (view as? UILabel) ?? rowLabel
        label.text = components[component].rows[row]
        label.sizeToFit()
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch components[component].style {
        case .year, .month:
            reloadDayComponent()
        case .stage:
            reloadHourComponent()
        default: break
        }
    }
}

// MARK: - MNDatePicker.Module
fileprivate extension MNDatePicker.Module {
    
    /// 是否是简写形式
    var isAbbr: Bool {
        switch self {
        case .year(_, let abbr): return abbr
        case .month(_, _, let abbr): return abbr
        case .day(_, let abbr): return abbr
        case .hour(_, _, _, let abbr): return abbr
        case .minute(_, let abbr): return abbr
        case .second(_, let abbr): return abbr
        }
    }
    
    /// 后缀
    var separator: String {
        switch self {
        case .year(let separator, _): return separator
        case .month(let separator, _, _): return separator
        case .day(let separator, _): return separator
        case .hour(let separator, _, _, _): return separator
        case .minute(let separator, _): return separator
        case .second(let separator, _): return separator
        }
    }
    
    /// 语言
    var lang: MNDatePicker.Language {
        switch self {
        case .month(_, let lang, _): return lang
        case .hour(_, _, let lang, _): return lang
        default: return .arabic
        }
    }
    
    /// 是否使用12小时制
    var clock: MNDatePicker.Formater.Clock {
        switch self {
        case .hour(_, let clock, _, _): return clock
        default: return .iso24
        }
    }
}

// MARK: - MNDatePicker.Module
fileprivate extension Array where Element == MNDatePicker.Module {
    
    /// 年配件
    var year: MNDatePicker.Module? {
        for element in self {
            switch element {
            case .year(_, _): return element
            default: break
            }
        }
        return nil
    }
    
    /// 月配件
    var month: MNDatePicker.Module? {
        for element in self {
            switch element {
            case .month(_, _, _): return element
            default: break
            }
        }
        return nil
    }
    
    /// 日配件
    var day: MNDatePicker.Module? {
        for element in self {
            switch element {
            case .day(_, _): return element
            default: break
            }
        }
        return nil
    }
    
    /// 时配件
    var hour: MNDatePicker.Module? {
        for element in self {
            switch element {
            case .hour(_, _, _, _): return element
            default: break
            }
        }
        return nil
    }
    
    /// 分配件
    var minute: MNDatePicker.Module? {
        for element in self {
            switch element {
            case .minute(_, _): return element
            default: break
            }
        }
        return nil
    }
    
    /// 秒配件
    var second: MNDatePicker.Module? {
        for element in self {
            switch element {
            case .second(_, _): return element
            default: break
            }
        }
        return nil
    }
}

// MARK: - 设置格式化器
extension MNDatePicker.Formater {
    
    /// 12时制格式
    public static var iso12: MNDatePicker.Formater { MNDatePicker.Formater(clock: .iso12) }
    
    /// 24时制格式
    public static var iso24: MNDatePicker.Formater { MNDatePicker.Formater(clock: .iso24) }
    
    /// 阿拉伯数字格式化器
    public static var arabic: MNDatePicker.Formater { MNDatePicker.Formater(lang: .arabic) }
    
    /// 中文格式化器
    public static var chinese: MNDatePicker.Formater { MNDatePicker.Formater(lang: .chinese) }
    
    /// 英语格式化器
    public static var english: MNDatePicker.Formater { MNDatePicker.Formater(lang: .english) }
    
    
    /// 增加年配件
    /// - Returns: 格式化器
    public func year() -> MNDatePicker.Formater {
        modules.append(.year(separator: "", abbr: false))
        return self
    }
    
    /// 增加月配件
    /// - Returns: 格式化器
    public func month() -> MNDatePicker.Formater {
        modules.append(.month(separator: "", lang: lang, abbr: false))
        return self
    }
    
    /// 增加日配件
    /// - Returns: 格式化器
    public func day() -> MNDatePicker.Formater {
        modules.append(.day(separator: "", abbr: false))
        return self
    }
    
    /// 增加时配件
    /// - Returns: 格式化器
    public func hour() -> MNDatePicker.Formater {
        modules.append(.hour(separator: "", clock: clock, lang: lang, abbr: false))
        return self
    }
    
    /// 增加分配件
    /// - Returns: 格式化器
    public func minute() -> MNDatePicker.Formater {
        modules.append(.minute(separator: "", abbr: false))
        return self
    }
    
    /// 增加秒配件
    /// - Returns: 格式化器
    public func second() -> MNDatePicker.Formater {
        modules.append(.second(separator: "", abbr: false))
        return self
    }
    
    /// 设置分隔符
    /// - Parameter separator: 分隔符
    /// - Returns: 格式化器
    public func separator(_ separator: MNDatePicker.Formater.Separator) -> MNDatePicker.Formater {
        if let last = modules.last {
            modules.removeLast()
            switch last {
            case .year(_, let abbr):
                modules.append(.year(separator: separator.rawString, abbr: abbr))
            case .month(_, let lang, let abbr):
                modules.append(.month(separator: separator.rawString, lang: lang, abbr: abbr))
            case .day(_, let abbr):
                modules.append(.day(separator: separator.rawString, abbr: abbr))
            case .hour(_, let clock, let lang, let abbr):
                modules.append(.hour(separator: separator.rawString, clock: clock, lang: lang, abbr: abbr))
            case .minute(_, let abbr):
                modules.append(.minute(separator: separator.rawString, abbr: abbr))
            case .second(_, let abbr):
                modules.append(.second(separator: separator.rawString, abbr: abbr))
            }
        }
        return self
    }
    
    /// 设置是否简写
    /// - Parameter isAbbr: 是否简写
    /// - Returns: 格式化器
    public func abbr(_ isAbbr: Bool) -> MNDatePicker.Formater {
        if let last = modules.last {
            modules.removeLast()
            switch last {
            case .year(let separator, _):
                modules.append(.year(separator: separator, abbr: isAbbr))
            case .month(let separator, let lang, _):
                modules.append(.month(separator: separator, lang: lang, abbr: isAbbr))
            case .day(let separator, _):
                modules.append(.day(separator: separator, abbr: isAbbr))
            case .hour(let separator, let clock, let lang, _):
                modules.append(.hour(separator: separator, clock: clock, lang: lang, abbr: isAbbr))
            case .minute(let separator, _):
                modules.append(.minute(separator: separator, abbr: isAbbr))
            case .second(let separator, _):
                modules.append(.second(separator: separator, abbr: isAbbr))
            }
        }
        return self
    }
    
    /// 设置小时制, 全局设置, 设置后会更改已有组件且往后添加组件都会采用此设置
    /// - Parameter clock: 小时制
    /// - Returns: 格式化器
    public func clock(_ clock: Clock) -> MNDatePicker.Formater {
        self.clock = clock
        let modules: [MNDatePicker.Module] = modules.compactMap { module in
            switch module {
            case .hour(let separator, _, let lang, let abbr):
                return .hour(separator: separator, clock: clock, lang: lang, abbr: abbr)
            default: return module
            }
        }
        self.modules.removeAll()
        self.modules.append(contentsOf: modules)
        return self
    }
    
    /// 设置语言, 全局设置, 设置后会更改已有组件且往后添加组件都会采用此设置
    /// - Parameter lang: 语言
    /// - Returns: 格式化器
    public func lang(_ lang: MNDatePicker.Language) -> MNDatePicker.Formater {
        self.lang = lang
        let modules: [MNDatePicker.Module] = modules.compactMap { module in
            switch module {
            case .month(let separator, _, let abbr):
                return .month(separator: separator, lang: lang, abbr: abbr)
            case .hour(let separator, let clock, _, let abbr):
                return .hour(separator: separator, clock: clock, lang: lang, abbr: abbr)
            default: return module
            }
        }
        self.modules.removeAll()
        self.modules.append(contentsOf: modules)
        return self
    }
}

// MARK: - 字符串做字面量构造分隔符
extension MNDatePicker.Formater.Separator: ExpressibleByStringLiteral {

    public init(stringLiteral value: StringLiteralType) {
        self = .custom(value)
    }
}
