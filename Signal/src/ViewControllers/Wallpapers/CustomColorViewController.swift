//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

public class CustomColorViewController: OWSTableViewController2 {

    private let thread: TSThread?

    public enum ValueMode {
        case createNew
        case editExisting(value: ChatColorValue)
    }
    private let valueMode: ValueMode

    private let completion: (ChatColorValue) -> Void

    private let modeControl = UISegmentedControl()

    fileprivate enum EditMode: Int {
        case solidColor
        case gradientColor1
        case gradientColor2
    }

    fileprivate var editMode: EditMode = .solidColor

    fileprivate class ColorSetting {
        // Represents a position within the hueSpectrum.
        var hueAlpha: CGFloat
        // Represents a position within the saturationSpectrum.
        // NOTE: the saturationSpectrum is a function of the hueAlpha.
        var saturationAlpha: CGFloat

        init(hueAlpha: CGFloat, saturationAlpha: CGFloat) {
            self.hueAlpha = hueAlpha
            self.saturationAlpha = saturationAlpha
        }
    }

    private var solidColorSetting = CustomColorViewController.randomColorSetting()
    private var gradientColor1Setting = CustomColorViewController.randomColorSetting()
    private var gradientColor2Setting = CustomColorViewController.randomColorSetting()
    fileprivate var angleRadians: CGFloat = 0

    fileprivate let hueSpectrum: HSLSpectrum
    private let hueSlider: SpectrumSlider

    private var saturationSpectrum: HSLSpectrum
    private let saturationSlider: SpectrumSlider

    public init(thread: TSThread? = nil,
                valueMode: ValueMode,
                completion: @escaping (ChatColorValue) -> Void) {
        self.thread = thread
        self.valueMode = valueMode
        self.completion = completion

        switch valueMode {
        case .createNew:
            editMode = .solidColor
        case .editExisting(let value):
            switch value.appearance {
            case .solidColor(let color):
                editMode = .solidColor
                self.solidColorSetting = color.asColorSetting
            case .gradient(let gradientColor1, let gradientColor2, let angleRadians):
                editMode = .gradientColor1
                self.gradientColor1Setting = gradientColor1.asColorSetting
                self.gradientColor2Setting = gradientColor2.asColorSetting
                self.angleRadians = angleRadians
            }
        }

        self.hueSpectrum = Self.buildHueSpectrum()
        hueSlider = SpectrumSlider(spectrum: hueSpectrum, value: 0)

        let hueAlpha = hueSlider.value.clamp01()
        let hueValue = self.hueSpectrum.value(forAlpha: hueAlpha)
        self.saturationSpectrum = Self.buildSaturationSpectrum(referenceValue: hueValue)
        saturationSlider = SpectrumSlider(spectrum: saturationSpectrum, value: 0)

        super.init()

        topHeader = OWSTableViewController2.buildTopHeader(forView: modeControl,
                                                           vMargin: 10)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableContents),
            name: .ThemeDidChange,
            object: nil
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("CUSTOM_CHAT_COLOR_SETTINGS_TITLE",
                                  comment: "Title for the custom chat color settings view.")

        navigationItem.rightBarButtonItem = .init(title: CommonStrings.setButton,
                                                  style: .done,
                                                  target: self,
                                                  action: #selector(didTapSet))

        createSubviews()

        updateTableContents()
    }

    private func createSubviews() {
        modeControl.insertSegment(withTitle: NSLocalizedString("CUSTOM_CHAT_COLOR_SETTINGS_SOLID_COLOR",
                                                               comment: "Label for the 'solid color' mode in the custom chat color settings view."),
                                  at: EditMode.solidColor.rawValue,
                                  animated: false)
        modeControl.insertSegment(withTitle: NSLocalizedString("CUSTOM_CHAT_COLOR_SETTINGS_GRADIENT",
                                                               comment: "Label for the 'gradient' mode in the custom chat color settings view."),
                                  at: EditMode.gradientColor1.rawValue,
                                  animated: false)
        switch editMode {
        case .solidColor:
            modeControl.selectedSegmentIndex = EditMode.solidColor.rawValue
        case .gradientColor1, .gradientColor2:
            modeControl.selectedSegmentIndex = EditMode.gradientColor1.rawValue
        }
        modeControl.addTarget(self,
                              action: #selector(modeControlDidChange),
                              for: .valueChanged)
    }

    private var previewView: CustomColorPreviewView?

    @objc
    func updateTableContents() {
        let contents = OWSTableContents()

        let previewView = databaseStorage.read { transaction in
            CustomColorPreviewView(thread: self.thread, transaction: transaction, delegate: self)
        }
        self.previewView = previewView

        let previewSection = OWSTableSection()
        previewSection.hasBackground = false
        previewSection.add(OWSTableItem { [weak self] in
            let cell = OWSTableItem.newCell()
            cell.selectionStyle = .none
            guard let self = self else { return cell }

            cell.contentView.addSubview(previewView)
            previewView.autoPinEdge(toSuperviewEdge: .left, withInset: self.cellHOuterLeftMargin)
            previewView.autoPinEdge(toSuperviewEdge: .right, withInset: self.cellHOuterRightMargin)
            previewView.autoPinHeightToSuperview()

            return cell
        } actionBlock: {})
        contents.addSection(previewSection)

        // Sliders

        let hueSlider = self.hueSlider
        let saturationSlider = self.saturationSlider

        updateSliderContent()

        hueSlider.delegate = self
        let hueSection = OWSTableSection()
        hueSection.hasBackground = false
        hueSection.headerTitle = NSLocalizedString("CUSTOM_CHAT_COLOR_SETTINGS_HUE",
                                                   comment: "Title for the 'hue' section in the chat color settings view.")
        hueSection.customHeaderHeight = 14
        hueSection.add(OWSTableItem {
            let cell = OWSTableItem.newCell()
            cell.selectionStyle = .none
            cell.contentView.addSubview(hueSlider)
            hueSlider.autoPinEdgesToSuperviewMargins()
            return cell
        } actionBlock: {})
        contents.addSection(hueSection)

        saturationSlider.delegate = self
        let saturationSection = OWSTableSection()
        saturationSection.hasBackground = false
        saturationSection.headerTitle = NSLocalizedString("CUSTOM_CHAT_COLOR_SETTINGS_SATURATION",
                                                   comment: "Title for the 'Saturation' section in the chat color settings view.")
        saturationSection.customHeaderHeight = 14
        saturationSection.add(OWSTableItem {
            let cell = OWSTableItem.newCell()
            cell.selectionStyle = .none
            cell.contentView.addSubview(saturationSlider)
            saturationSlider.autoPinEdgesToSuperviewMargins()
            return cell
        } actionBlock: {})
        contents.addSection(saturationSection)

        self.contents = contents
    }

    // A custom spectrum that can ensures accessible constrast.
    private static let lightnessSpectrum: LightnessSpectrum = {
        var values: [LightnessValue] = [
            .init(lightness: 0.45, alpha: 0.0 / 360.0),
            .init(lightness: 0.3, alpha: 60.0 / 360.0),
            .init(lightness: 0.3, alpha: 180.0 / 360.0),
            .init(lightness: 0.5, alpha: 240.0 / 360.0),
            .init(lightness: 0.4, alpha: 300.0 / 360.0),
            .init(lightness: 0.45, alpha: 360.0 / 360.0)
        ]
        return LightnessSpectrum(values: values)
    }()

    private static func randomAlphaValue() -> CGFloat {
        let precision: UInt32 = 1024
        return (CGFloat(arc4random_uniform(precision)) / CGFloat(precision)).clamp01()
    }

    private static func randomColorSetting() -> ColorSetting {
        ColorSetting(hueAlpha: randomAlphaValue(), saturationAlpha: randomAlphaValue())
    }

    private static func buildHueSpectrum() -> HSLSpectrum {
        let lightnessSpectrum = CustomColorViewController.lightnessSpectrum
        var values = [HSLValue]()
        let precision: UInt32 = 1024
        for index in 0..<(precision + 1) {
            let alpha = (CGFloat(index) / CGFloat(precision)).clamp01()
            // There's a linear hue progression.
            let hue = alpha
            // Saturation is always 1 in the hue spectrum.
            let saturation: CGFloat = 1
            // Derive lightness.
            let lightness = lightnessSpectrum.value(forAlpha: alpha).lightness
            values.append(HSLValue(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha))
        }

        return HSLSpectrum(values: values)
    }

    private static func buildSaturationSpectrum(referenceValue: HSLValue) -> HSLSpectrum {
        var values = [HSLValue]()
        let precision: UInt32 = 1024
        for index in 0..<(precision + 1) {
            let alpha = (CGFloat(index) / CGFloat(precision)).clamp01()
            let hue = referenceValue.hue
            let saturation = alpha
            let lightness = referenceValue.lightness
            values.append(HSLValue(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha))
        }
        return HSLSpectrum(values: values)
    }

    private func updateSaturationSpectrum() {
        let hueAlpha = hueSlider.value.clamp01()
        let hueValue = self.hueSpectrum.value(forAlpha: hueAlpha)
        self.saturationSpectrum = Self.buildSaturationSpectrum(referenceValue: hueValue)
        self.saturationSlider.spectrum = saturationSpectrum
    }

    private func updateSliderContent() {
        // Update sliders to reflect editMode.
        func apply(colorSetting: ColorSetting) {
            hueSlider.value = colorSetting.hueAlpha
            saturationSlider.value = colorSetting.saturationAlpha

            // Update saturation slider to reflect hue slider state.
            updateSaturationSpectrum()
        }
        switch editMode {
        case .solidColor:
            apply(colorSetting: self.solidColorSetting)
        case .gradientColor1:
            apply(colorSetting: self.gradientColor1Setting)
        case .gradientColor2:
            apply(colorSetting: self.gradientColor2Setting)
        }
    }

    private func updateMockConversation() {
        self.previewView?.updateMockConversation()
    }

    // MARK: - Events

    @objc
    private func modeControlDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case EditMode.solidColor.rawValue:
            self.editMode = .solidColor
        case EditMode.gradientColor1.rawValue, EditMode.gradientColor2.rawValue:
            self.editMode = .gradientColor1
        default:
            owsFailDebug("Couldn't update editMode.")
        }
        updateTableContents()
    }

    fileprivate var solidColorAppearance: ChatColorAppearance {
        let solidColor = self.solidColorSetting.asOWSColor(hueSpectrum: self.hueSpectrum)
        return .solidColor(color: solidColor)
    }

    fileprivate var gradientColor1: OWSColor {
        self.gradientColor1Setting.asOWSColor(hueSpectrum: self.hueSpectrum)
    }

    fileprivate var gradientColor2: OWSColor {
        self.gradientColor2Setting.asOWSColor(hueSpectrum: self.hueSpectrum)
    }

    fileprivate var gradientAppearance: ChatColorAppearance {
        return .gradient(gradientColor1: self.gradientColor1,
                         gradientColor2: self.gradientColor2,
                         angleRadians: self.angleRadians)
    }

    private func currentChatColorAppearance() -> ChatColorAppearance {
        switch editMode {
        case .solidColor:
            return solidColorAppearance
        case .gradientColor1, .gradientColor2:
            return gradientAppearance
        }
    }

    @objc
    func didTapSet() {
        let appearance = self.currentChatColorAppearance()
        let newValue: ChatColorValue
        switch valueMode {
        case .createNew:
            newValue = ChatColorValue(id: ChatColorValue.randomId,
                                      appearance: appearance)
        case .editExisting(let oldValue):
            // Preserve the old id and creationTimestamp.
            newValue = ChatColorValue(id: oldValue.id,
                                      appearance: appearance,
                                      creationTimestamp: oldValue.creationTimestamp)
        }

        Logger.verbose("appearance: \(appearance), ")
        completion(newValue)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: -

extension CustomColorViewController: SpectrumSliderDelegate {
    fileprivate func spectrumSliderDidChange(_ spectrumSlider: SpectrumSlider) {
        let currentColorSetting: ColorSetting
        switch editMode {
        case .solidColor:
            currentColorSetting = self.solidColorSetting
        case .gradientColor1:
            currentColorSetting = self.gradientColor1Setting
        case .gradientColor2:
            currentColorSetting = self.gradientColor2Setting
        }

        if spectrumSlider == self.hueSlider {
            Logger.verbose("hueSlider did change.")
            currentColorSetting.hueAlpha = hueSlider.value.clamp01()
            updateSaturationSpectrum()
        } else if spectrumSlider == self.saturationSlider {
            Logger.verbose("saturationSlider did change.")
            currentColorSetting.saturationAlpha = saturationSlider.value.clamp01()
        } else {
            owsFailDebug("Unknown slider.")
        }

        updateMockConversation()
    }
}

// MARK: -

private protocol SpectrumSliderDelegate: class {
    func spectrumSliderDidChange(_ spectrumSlider: SpectrumSlider)
}

// MARK: -

private class SpectrumSlider: ManualLayoutView {
    fileprivate weak var delegate: SpectrumSliderDelegate?

    var spectrum: HSLSpectrum {
        didSet {
            spectrumImageView.image = nil
            ensureSpectrumImage()
        }
    }

    public var value: CGFloat {
        didSet {
            setNeedsLayout()
        }
    }

    private let knobView = ManualLayoutViewWithLayer(name: "knobView")

    private let spectrumImageView = CVImageView.circleView()

    init(spectrum: HSLSpectrum, value: CGFloat) {
        self.spectrum = spectrum
        self.value = value

        super.init(name: "SpectrumSlider")

        self.shouldDeactivateConstraints = false

        createSubviews()
    }

    @available(swift, obsoleted: 1.0)
    required init(name: String) {
        owsFail("Do not use this initializer.")
    }

    private static let knobDiameter: CGFloat = 28
    private static let knobShadowRadius: CGFloat = 4
    private static let spectrumImageDiameter: CGFloat = 24

    private func createSubviews() {
        let spectrumImageView = self.spectrumImageView
        spectrumImageView.clipsToBounds = true
        addSubview(spectrumImageView)

        let knobView = self.knobView
        knobView.addPillBlock()
        knobView.backgroundColor = .ows_white
        knobView.layer.shadowColor = UIColor.ows_black.cgColor
        knobView.layer.shadowOffset = CGSize(width: 0, height: 2)
        knobView.layer.shadowOpacity = 0.3
        knobView.layer.shadowRadius = Self.knobShadowRadius
        addSubview(knobView) { view in
            guard let view = view as? SpectrumSlider else {
                owsFailDebug("Invalid view.")
                return
            }
            let knobMinX: CGFloat = 0
            let knobMaxX: CGFloat = max(0, view.width - Self.knobDiameter)
            knobView.frame = CGRect(x: view.value.lerp(knobMinX, knobMaxX),
                                    y: 0,
                                    width: Self.knobDiameter,
                                    height: Self.knobDiameter)

            let inset = (Self.knobDiameter - Self.spectrumImageDiameter) * 0.5
            spectrumImageView.frame = view.bounds.inset(by: UIEdgeInsets(margin: inset))

            view.ensureSpectrumImage()
        }

        self.autoSetDimension(.height, toSize: Self.knobDiameter)

        addGestureRecognizer(CustomColorGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        self.isUserInteractionEnabled = true
    }

    @objc
    private func handleGesture(_ sender: CustomColorGestureRecognizer) {
        switch sender.state {
        case .began, .changed, .ended:
            let location = sender.location(in: self)
            self.value = location.x.inverseLerp(0, self.bounds.width).clamp01()
            layoutSubviews()
            self.delegate?.spectrumSliderDidChange(self)
        default:
            break
        }
    }

    private func ensureSpectrumImage() {
        let scale = UIScreen.main.scale
        let spectrumImageSizePoints = spectrumImageView.bounds.size
        let spectrumImageSizePixels = spectrumImageSizePoints * scale
        guard spectrumImageSizePixels.isNonEmpty else {
            spectrumImageView.image = nil
            return
        }
        if let spectrumImage = spectrumImageView.image,
           spectrumImage.pixelSize == spectrumImageSizePixels {
            // Image is already valid.
            return
        }

        spectrumImageView.image = nil

        UIGraphicsBeginImageContextWithOptions(spectrumImageSizePoints, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }

        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: spectrumImageSizePoints))

        // We use point resolution; we could use pixel resolution.
        let xIncrement: CGFloat = 1
        var x: CGFloat = 0
        while x < spectrumImageSizePoints.width {
            let alpha = x / spectrumImageSizePoints.width
            let hslValue = spectrum.value(forAlpha: alpha)
            hslValue.asUIColor.setFill()
            UIRectFill(CGRect(x: x, y: 0, width: xIncrement, height: spectrumImageSizePoints.height))
            x += xIncrement
        }

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            owsFailDebug("Could not build image.")
            return
        }

        owsAssertDebug(image.size == spectrumImageSizePoints)
        owsAssertDebug(image.pixelSize == spectrumImageSizePixels)

        spectrumImageView.image = image
    }
}

// MARK: -

private struct LightnessValue: LerpableValue {
    let lightness: CGFloat
    let alpha: CGFloat

    init(lightness: CGFloat, alpha: CGFloat) {
        self.lightness = lightness.clamp01()
        self.alpha = alpha.clamp01()
    }

    func interpolate(_ other: LightnessValue, interpolationAlpha: CGFloat) -> LightnessValue {
        let interpolationAlpha = interpolationAlpha.clamp01()
        return LightnessValue(lightness: interpolationAlpha.lerp(lightness, other.lightness),
                              alpha: interpolationAlpha.lerp(alpha, other.alpha))
    }
}

// MARK: -

private struct LightnessSpectrum: LerpableSpectrum {
    let values: [LightnessValue]

    func interpolate(left: LightnessValue, right: LightnessValue, interpolationAlpha: CGFloat) -> LightnessValue {
        owsAssertDebug(left.alpha <= right.alpha)

        return left.interpolate(right, interpolationAlpha: interpolationAlpha)
    }
}

// MARK: -

private struct HSLValue: LerpableValue {
    let hue: CGFloat
    let saturation: CGFloat
    let lightness: CGFloat
    // This property is only used in the context of spectrums.
    // It is _NOT_ a transparency/opacity alpha.
    // It represents the values alpha within a spectrum.
    let alpha: CGFloat

    init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 0) {
        self.hue = hue.clamp01()
        self.saturation = saturation.clamp01()
        self.lightness = lightness.clamp01()
        self.alpha = alpha.clamp01()
    }

    func interpolate(_ other: HSLValue, interpolationAlpha: CGFloat) -> HSLValue {
        let interpolationAlpha = interpolationAlpha.clamp01()
        return HSLValue(hue: interpolationAlpha.lerp(hue, other.hue),
                        saturation: interpolationAlpha.lerp(saturation, other.saturation),
                        lightness: interpolationAlpha.lerp(lightness, other.lightness),
                        alpha: interpolationAlpha.lerp(alpha, other.alpha))
    }

    var asUIColor: UIColor {
        UIColor(hue: hue, saturation: saturation, lightness: lightness, alpha: 1)
    }

    var asOWSColor: OWSColor {
        self.asUIColor.asOWSColor
    }

    var description: String {
        "[hue: \(hue), saturation: \(saturation), lightness: \(lightness), alpha: \(alpha)]"
    }
}

// MARK: -

private struct HSLSpectrum: LerpableSpectrum {
    let values: [HSLValue]

    func interpolate(left: HSLValue, right: HSLValue, interpolationAlpha: CGFloat) -> HSLValue {
        owsAssertDebug(left.alpha <= right.alpha)

        return left.interpolate(right, interpolationAlpha: interpolationAlpha)
    }
}

// MARK: -

private protocol LerpableValue {
    var alpha: CGFloat { get }
}

// MARK: -

private protocol LerpableSpectrum {
    associatedtype Value: LerpableValue

    var values: [Value] { get }

    func interpolate(left: Value, right: Value, interpolationAlpha: CGFloat) -> Value
}

// MARK: -

extension LerpableSpectrum {
    func value(forAlpha targetAlpha: CGFloat) -> Value {
        let values = self.values
        guard values.count > 1 else {
            owsFailDebug("Invalid values: \(values.count).")
            return values.first!
        }
        let targetAlpha = targetAlpha.clamp01()

        var leftIndex: Int = 0
        var rightIndex: Int = values.count - 1
        while true {
            guard leftIndex <= rightIndex,
                  let left = values[safe: leftIndex],
                  let right = values[safe: rightIndex] else {
                owsFailDebug("Invalid indices. leftIndex: \(leftIndex), rightIndex: \(rightIndex), values: \(values.count).")
                return values.first!
            }
            guard left.alpha <= right.alpha,
                  left.alpha <= targetAlpha,
                  right.alpha >= targetAlpha else {
                owsFailDebug("Invalid alphas. left.alpha: \(left.alpha), right.alpha: \(right.alpha), targetAlpha: \(targetAlpha).")
                return left
            }
            if leftIndex == rightIndex {
                return left
            }
            if leftIndex + 1 == rightIndex {
                owsAssertDebug(left.alpha < right.alpha)
                owsAssertDebug(left.alpha <= targetAlpha)
                owsAssertDebug(targetAlpha <= right.alpha)

                let interpolationAlpha = targetAlpha.inverseLerp(left.alpha, right.alpha, shouldClamp: true)
                return interpolate(left: left, right: right, interpolationAlpha: interpolationAlpha)
            }
            let midpointIndex = (leftIndex + rightIndex) / 2
            guard let midpoint = values[safe: midpointIndex] else {
                owsFailDebug("Invalid indices. leftIndex: \(leftIndex), rightIndex: \(rightIndex), midpointIndex: \(midpointIndex).")
                return values.first!
            }
            if midpoint.alpha < targetAlpha {
                leftIndex = midpointIndex
            } else if midpoint.alpha > targetAlpha {
                rightIndex = midpointIndex
            } else {
                return midpoint
            }
        }
    }
}

extension UIColor {
    // Convert HSL to HSB.
    convenience init(hue: CGFloat, saturation saturationHSL: CGFloat, lightness: CGFloat, alpha: CGFloat) {
        owsAssertDebug(0 <= hue)
        owsAssertDebug(1 >= hue)
        owsAssertDebug(0 <= saturationHSL)
        owsAssertDebug(1 >= saturationHSL)
        owsAssertDebug(0 <= lightness)
        owsAssertDebug(1 >= lightness)
        owsAssertDebug(0 <= alpha)
        owsAssertDebug(1 >= alpha)

        let hue = hue.clamp01()
        let saturationHSL = saturationHSL.clamp01()
        let lightness = lightness.clamp01()
        let alpha = alpha.clamp01()

        let brightness = (lightness + saturationHSL * min(lightness, 1 - lightness)).clamp01()
        let saturationHSB: CGFloat = {
            if brightness == 0 {
                return 0
            } else {
                return (2 * (1 - lightness / brightness)).clamp01()
            }
        }()

        self.init(hue: hue, saturation: saturationHSB, brightness: brightness, alpha: alpha)
    }
}

// MARK: -

extension OWSColor {
    fileprivate var asColorSetting: CustomColorViewController.ColorSetting {
        let uiColor = self.asUIColor

        var hue: CGFloat = 0
        var saturationHSB: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getHue(&hue, saturation: &saturationHSB, brightness: &brightness, alpha: &alpha)

        hue = hue.clamp01()
        saturationHSB = saturationHSB.clamp01()
        brightness = brightness.clamp01()

        // Convert HSB to HSL.

        let lightness = (2 - saturationHSB) * brightness / 2

        let saturationHSL: CGFloat
        if lightness == 0 {
            saturationHSL = saturationHSB
        } else if lightness == 1 {
            saturationHSL = 0
        } else if lightness < 0.5 {
            saturationHSL = (saturationHSB * brightness / (lightness * 2)).clamp01()
        } else {
            saturationHSL = (saturationHSB * brightness / (2 - lightness * 2)).clamp01()
        }

        return CustomColorViewController.ColorSetting(hueAlpha: hue, saturationAlpha: saturationHSL)
    }
}

// MARK: -

extension CustomColorViewController.ColorSetting {
    func asOWSColor(hueSpectrum: HSLSpectrum) -> OWSColor {
        let hueValue = hueSpectrum.value(forAlpha: self.hueAlpha)
        let saturationSpectrum = CustomColorViewController.buildSaturationSpectrum(referenceValue: hueValue)
        let saturationValue = saturationSpectrum.value(forAlpha: self.saturationAlpha)
        return saturationValue.asOWSColor
    }
}

// MARK: -

extension CustomColorViewController: CustomColorPreviewDelegate {
    fileprivate func switchToEditMode(_ value: CustomColorViewController.EditMode) {
        guard self.editMode != value else {
            return
        }
        self.editMode = value
        updateSliderContent()
    }
}

// MARK: -

private protocol CustomColorPreviewDelegate: class {
    var angleRadians: CGFloat { get set }
    var editMode: CustomColorViewController.EditMode { get }
    var gradientColor1: OWSColor { get }
    var gradientColor2: OWSColor { get }

    func switchToEditMode(_ value: CustomColorViewController.EditMode)
}

// MARK: -

private class CustomColorPreviewView: UIView {
    private let mockConversationView: MockConversationView

    private weak var delegate: CustomColorPreviewDelegate?

    public override var bounds: CGRect {
        didSet {
            if oldValue != bounds {
                updateKnobLayout()
            }
        }
    }

    public override var frame: CGRect {
        didSet {
            if oldValue != frame {
                updateKnobLayout()
            }
        }
    }

    init(thread: TSThread?,
         transaction: SDSAnyReadTransaction,
         delegate: CustomColorPreviewDelegate) {
        self.mockConversationView = MockConversationView(
            mode: CustomColorPreviewView.buildMockConversationMode(),
            hasWallpaper: true
        )
        self.delegate = delegate

        super.init(frame: .zero)

        let wallpaperPreviewView: UIView
        if let wallpaperView = Wallpaper.view(for: thread, transaction: transaction) {
            wallpaperPreviewView = wallpaperView.asPreviewView()
        } else {
            wallpaperPreviewView = UIView()
            wallpaperPreviewView.backgroundColor = Theme.backgroundColor
        }
        wallpaperPreviewView.layer.cornerRadius = OWSTableViewController2.cellRounding
        wallpaperPreviewView.clipsToBounds = true

        self.addSubview(wallpaperPreviewView)
        wallpaperPreviewView.autoPinEdgesToSuperviewEdges()

        self.addSubview(mockConversationView)
        mockConversationView.autoPinWidthToSuperview()
        mockConversationView.autoPinEdge(toSuperviewEdge: .top, withInset: 32)
        mockConversationView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 32)

        ensureControlState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func updateMockConversation() {
        guard let delegate = delegate else { return }
        // TODO: mockConversationView

        if let knobView1 = self.knobView1 {
            knobView1.value = ChatColorValue(id: "knob1",
                                             appearance: .solidColor(color: delegate.gradientColor1))
        }
        if let knobView2 = self.knobView2 {
            knobView2.value = ChatColorValue(id: "knob2",
                                             appearance: .solidColor(color: delegate.gradientColor2))
        }
    }

    private class KnobView: UIView {

        static let swatchSize: CGFloat = 44
        static let selectionBorderThickness: CGFloat = 4
        static var knobSize: CGFloat { swatchSize + selectionBorderThickness * 2 }

        var isSelected: Bool {
            didSet {
                updateSelection()
            }
        }

        var value: ChatColorValue {
            get { swatchView.chatColorValue }
            set { swatchView.chatColorValue = newValue }
        }

        private let wrapper = OWSLayerView.circleView()

        private let swatchView: ChatColorSwatchView

        init(isSelected: Bool, chatColorValue: ChatColorValue) {
            self.isSelected = isSelected
            self.swatchView = ChatColorSwatchView(chatColorValue: chatColorValue, mode: .circle)

            super.init(frame: .zero)

            self.translatesAutoresizingMaskIntoConstraints = false

            swatchView.layer.borderWidth = 1
            swatchView.layer.borderColor = UIColor.ows_white.cgColor
            swatchView.layer.shadowColor = UIColor.ows_black.cgColor
            swatchView.layer.shadowOffset = CGSize(width: 0, height: 2)
            swatchView.layer.shadowOpacity = 0.3
            swatchView.layer.shadowRadius = 4
            swatchView.autoSetDimensions(to: .square(Self.swatchSize))

            wrapper.layoutMargins = UIEdgeInsets(margin: Self.selectionBorderThickness)
            wrapper.addSubview(swatchView)
            swatchView.autoPinEdgesToSuperviewMargins()
            wrapper.autoSetDimensions(to: .square(Self.knobSize))

            self.addSubview(wrapper)
            wrapper.autoPinEdgesToSuperviewEdges()
            self.autoSetDimensions(to: .square(Self.knobSize))

            updateSelection()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func updateSelection() {
            if isSelected {
                wrapper.layer.borderWidth = Self.selectionBorderThickness
                wrapper.layer.borderColor = UIColor(white: 0, alpha: 0.25).cgColor
            } else {
                wrapper.layer.borderWidth = 0
                wrapper.layer.borderColor = nil
            }
        }
    }

    private var knobView1: KnobView?
    private var knobView2: KnobView?
    private var axisShapeView: UIView?
    private var axisShapeLayer: CAShapeLayer?

    private var knobView1ConstraintX: NSLayoutConstraint?
    private var knobView1ConstraintY: NSLayoutConstraint?
    private var knobView2ConstraintX: NSLayoutConstraint?
    private var knobView2ConstraintY: NSLayoutConstraint?

    private func ensureControlState() {
        guard let delegate = delegate else { return }

        switch delegate.editMode {
        case .solidColor:
            return
        case .gradientColor1, .gradientColor2:
            break
        }

        let axisShapeView = UIView()
        self.axisShapeView = axisShapeView
        addSubview(axisShapeView)
        axisShapeView.autoPinEdgesToSuperviewEdges()
        let axisShapeLayer = CAShapeLayer()
        self.axisShapeLayer = axisShapeLayer
        axisShapeView.layer.addSublayer(axisShapeLayer)

        let knobView1 = KnobView(isSelected: delegate.editMode == .gradientColor1,
                                 chatColorValue: ChatColorValue(id: "knob1",
                                                                appearance: .solidColor(color: delegate.gradientColor1)))
        let knobView2 = KnobView(isSelected: delegate.editMode == .gradientColor2,
                                 chatColorValue: ChatColorValue(id: "knob2",
                                                                appearance: .solidColor(color: delegate.gradientColor2)))
        self.knobView1 = knobView1
        self.knobView2 = knobView2

        addSubview(knobView1)
        addSubview(knobView2)

        knobView1ConstraintX = NSLayoutConstraint(item: knobView1,
                                                  attribute: .centerX,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .centerX,
                                                  multiplier: 1,
                                                  constant: 0)
        knobView1ConstraintY = NSLayoutConstraint(item: knobView1,
                                                  attribute: .centerY,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .centerY,
                                                  multiplier: 1,
                                                  constant: 0)
        knobView2ConstraintX = NSLayoutConstraint(item: knobView2,
                                                  attribute: .centerX,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .centerX,
                                                  multiplier: 1,
                                                  constant: 0)
        knobView2ConstraintY = NSLayoutConstraint(item: knobView2,
                                                  attribute: .centerY,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .centerY,
                                                  multiplier: 1,
                                                  constant: 0)
        knobView1ConstraintX?.autoInstall()
        knobView1ConstraintY?.autoInstall()
        knobView2ConstraintX?.autoInstall()
        knobView2ConstraintY?.autoInstall()

        updateKnobLayout()

        addGestureRecognizer(CustomColorGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        self.isUserInteractionEnabled = true
    }

    private enum GestureMode {
        case none
        case knob1
        case knob2
    }

    private var gestureMode: GestureMode = .none

    @objc
    private func handleGesture(_ sender: CustomColorGestureRecognizer) {
        switch sender.state {
        case .began, .changed, .ended:
            guard let delegate = self.delegate,
                  let knobView1 = self.knobView1,
                  let knobView2 = self.knobView2 else {
                gestureMode = .none
                return
            }
            let touchLocation = sender.location(in: self)

            if sender.state == .began {
                // Only "grab" a knob if the gesture starts near a knob.
                let knobDistance1 = knobView1.frame.center.distance(touchLocation)
                let knobDistance2 = knobView2.frame.center.distance(touchLocation)
                let minFirstTouchDistance = KnobView.knobSize * 2
                if knobDistance1 < minFirstTouchDistance,
                   knobDistance2 < minFirstTouchDistance {
                    if knobDistance1 < knobDistance2 {
                        gestureMode = .knob1
                    } else {
                        gestureMode = .knob2
                    }
                } else if knobDistance1 < minFirstTouchDistance {
                    gestureMode = .knob1
                } else if knobDistance2 < minFirstTouchDistance {
                    gestureMode = .knob2
                } else {
                    gestureMode = .none
                    return
                }
            }

            delegate.switchToEditMode(gestureMode == .knob1
                                        ? .gradientColor1
                                        : .gradientColor2)
            knobView1.isSelected = gestureMode == .knob1
            knobView2.isSelected = gestureMode == .knob2

            let viewCenter = self.bounds.center
            var touchVector = touchLocation - viewCenter
            // Note the signs.
            touchVector = CGPoint(x: +touchVector.x, y: -touchVector.y)

            switch gestureMode {
            case .knob1:
                break
            case .knob2:
                // To simplify the math, pretend we're manipulating the first knob
                // by inverting the vector.
                touchVector = touchVector * -1
            case .none:
                return
            }

            let angleRadians = atan2(touchVector.x, touchVector.y)
            delegate.angleRadians = angleRadians
            updateKnobLayout()
            updateMockConversation()
        default:
            gestureMode = .none
            break
        }
    }

    private func updateKnobLayout() {
        guard let delegate = self.delegate,
              let knobView1ConstraintX = self.knobView1ConstraintX,
              let knobView1ConstraintY = self.knobView1ConstraintY,
              let knobView2ConstraintX = self.knobView2ConstraintX,
              let knobView2ConstraintY = self.knobView2ConstraintY,
              let axisShapeLayer = self.axisShapeLayer else {
            return
        }

        let knobInset: CGFloat = 20
        let knobRect = self.bounds.inset(by: UIEdgeInsets(margin: knobInset))
        guard knobRect.size.width > 0,
              knobRect.size.height > 0 else {
            return
        }

        let angleRadians = delegate.angleRadians
        // Note the signs.
        let unitVector = CGPoint(x: +sin(angleRadians), y: -cos(angleRadians))
        let oversizeVector = unitVector * knobRect.size.largerAxis
        let scaleFactorX = (knobRect.size.width / 2) / abs(oversizeVector.x)
        let scaleFactorY = (knobRect.size.height / 2) / abs(oversizeVector.y)
        let scaleFactor: CGFloat
        if abs(oversizeVector.x) > 0,
           abs(oversizeVector.y) > 0 {
            scaleFactor = min(scaleFactorX, scaleFactorY)
        } else if abs(oversizeVector.x) > 0 {
            scaleFactor = scaleFactorX
        } else if abs(oversizeVector.y) > 0 {
            scaleFactor = scaleFactorY
        } else {
            owsFailDebug("Invalid vector state.")
            scaleFactor = 1
        }
        let vector1 = oversizeVector * +scaleFactor
        // Knob 2 is always opposite knob 1.
        let vector2 = vector1 * -1

        knobView1ConstraintX.constant = vector1.x
        knobView1ConstraintY.constant = vector1.y
        knobView2ConstraintX.constant = vector2.x
        knobView2ConstraintY.constant = vector2.y

        axisShapeLayer.frame = self.bounds
        axisShapeLayer.fillColor = UIColor.ows_white.cgColor
        axisShapeLayer.strokeColor = UIColor(white: 0, alpha: 0.1).cgColor
        let axisPath = UIBezierPath()
        let knobCenter1 = self.bounds.center + vector1
        let knobCenter2 = self.bounds.center + vector2
        let axisVector = knobCenter2 - knobCenter1
        if axisVector.length > 0 {
            // We want to draw the "axis" of the gradient.
            // This is a bar between the two "knobs" which
            // represent the 2 gradient control points.
            //
            // P2                            P3
            //
            // K1 ...........................K2
            //
            // P1                            P4
            //
            // We do this by deriving an "offset vector".
            // We rotate the axis vector 90 degress.
            var offAxisVector = CGPoint(x: axisVector.y, y: -axisVector.x)
            let axisThickness: CGFloat = 8
            // Then scale it to half the thickness of the axis.
            offAxisVector = offAxisVector * (axisThickness * 0.5 / offAxisVector.length)

            // By adding the "offset vector" to the two knob locations,
            // we derive the corners of the axis.
            let p1 = knobCenter1 + offAxisVector
            let p2 = knobCenter1 - offAxisVector
            let p3 = knobCenter2 - offAxisVector
            let p4 = knobCenter2 + offAxisVector

            axisPath.move(to: p1)
            axisPath.addLine(to: p2)
            axisPath.addLine(to: p3)
            axisPath.addLine(to: p4)
            axisPath.addLine(to: p1)
        }
        axisShapeLayer.path = axisPath.cgPath
    }

    private static func buildMockConversationMode() -> MockConversationView.Mode {
        let outgoingText = NSLocalizedString(
            "CHAT_COLOR_OUTGOING_MESSAGE",
            comment: "The outgoing bubble text when setting a chat color."
        )
        let incomingText = NSLocalizedString(
            "CHAT_COLOR_INCOMING_MESSAGE",
            comment: "The incoming bubble text when setting a chat color."
        )
        return .dateIncomingOutgoing(
            incomingText: incomingText,
            outgoingText: outgoingText
        )
    }
}

// MARK: -

class CustomColorGestureRecognizer: UIGestureRecognizer {
    private var isActive = false

    @objc
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        handle(event: event)
    }

    @objc
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        handle(event: event)
    }

    @objc
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        handle(event: event)
    }

    @objc
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        handle(event: event)
    }

    private func handle(event: UIEvent) {
        guard let allTouches = event.allTouches,
              allTouches.count == 1,
              let firstTouch = allTouches.first else {
            self.state = .failed
            self.isActive = false
            return
        }
        switch firstTouch.phase {
        case .began:
            guard let view = self.view,
                  view.bounds.contains(firstTouch.location(in: view)) else {
                self.state = .failed
                self.isActive = false
                return
            }
            if !self.isActive {
                self.state = .began
                self.isActive = true
                return
            }
        case .moved, .stationary:
            if self.isActive {
                self.state = .changed
                self.isActive = true
                return
            }
        case .ended:
            if self.isActive {
                self.state = .ended
                self.isActive = false
                return
            }
        default:
            break
        }
        self.state = .failed
        self.isActive = false
    }
}
