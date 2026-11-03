#!/bin/bash
# Verbum — a New Testament passage widget for the bottom-right corner of the macOS desktop.
# Shows a new King James Version passage every four hours (00:00, 04:00, 08:00, 12:00, 16:00, 20:00).
# Usage:  bash install.sh
set -euo pipefail

APP_NAME="Verbum"
BUNDLE_ID="biz.lukemurray.verbum"
APP_DIR="$HOME/Applications/$APP_NAME.app"
AGENT="$HOME/Library/LaunchAgents/$BUNDLE_ID.plist"

if [[ "${1:-}" == "--uninstall" ]]; then
  launchctl bootout "gui/$(id -u)/$BUNDLE_ID" >/dev/null 2>&1 || true
  pkill -x "$APP_NAME" >/dev/null 2>&1 || true
  rm -rf "$APP_DIR" "$AGENT"
  echo "✓ Verbum removed."
  exit 0
fi

BUILD="$(mktemp -d)"

echo "→ Checking for the Swift compiler (Xcode Command Line Tools)…"
if ! xcrun --find swiftc >/dev/null 2>&1; then
  echo "  Not found. A macOS install dialog will open — click Install, wait for it to finish,"
  echo "  then run this script again:  bash install.sh"
  xcode-select --install || true
  exit 1
fi

echo "→ Writing source…"
cat > "$BUILD/main.swift" <<'SWIFT'
import Cocoa

// MARK: - Passages (King James Version, public domain)

struct Passage { let text: String; let ref: String }

let passages: [Passage] = [
  Passage(text: "Ye are the light of the world. A city that is set on an hill cannot be hid.", ref: "Matthew 5:14"),
  Passage(text: "Let your light so shine before men, that they may see your good works, and glorify your Father which is in heaven.", ref: "Matthew 5:16"),
  Passage(text: "But seek ye first the kingdom of God, and his righteousness; and all these things shall be added unto you.", ref: "Matthew 6:33"),
  Passage(text: "Take therefore no thought for the morrow: for the morrow shall take thought for the things of itself. Sufficient unto the day is the evil thereof.", ref: "Matthew 6:34"),
  Passage(text: "Ask, and it shall be given you; seek, and ye shall find; knock, and it shall be opened unto you.", ref: "Matthew 7:7"),
  Passage(text: "Come unto me, all ye that labour and are heavy laden, and I will give you rest. Take my yoke upon you, and learn of me; for I am meek and lowly in heart: and ye shall find rest unto your souls. For my yoke is easy, and my burden is light.", ref: "Matthew 11:28–30"),
  Passage(text: "Blessed are the pure in heart: for they shall see God.", ref: "Matthew 5:8"),
  Passage(text: "Blessed are the peacemakers: for they shall be called the children of God.", ref: "Matthew 5:9"),
  Passage(text: "Blessed are they that mourn: for they shall be comforted.", ref: "Matthew 5:4"),
  Passage(text: "With men this is impossible; but with God all things are possible.", ref: "Matthew 19:26"),
  Passage(text: "Lo, I am with you alway, even unto the end of the world.", ref: "Matthew 28:20"),
  Passage(text: "Therefore all things whatsoever ye would that men should do to you, do ye even so to them: for this is the law and the prophets.", ref: "Matthew 7:12"),
  Passage(text: "Thou shalt love the Lord thy God with all thy heart, and with all thy soul, and with all thy mind. This is the first and great commandment. And the second is like unto it, Thou shalt love thy neighbour as thyself.", ref: "Matthew 22:37–39"),
  Passage(text: "For where your treasure is, there will your heart be also.", ref: "Matthew 6:21"),
  Passage(text: "Are not two sparrows sold for a farthing? and one of them shall not fall on the ground without your Father. But the very hairs of your head are all numbered. Fear ye not therefore, ye are of more value than many sparrows.", ref: "Matthew 10:29–31"),
  Passage(text: "If thou canst believe, all things are possible to him that believeth.", ref: "Mark 9:23"),
  Passage(text: "Lord, I believe; help thou mine unbelief.", ref: "Mark 9:24"),
  Passage(text: "For what shall it profit a man, if he shall gain the whole world, and lose his own soul?", ref: "Mark 8:36"),
  Passage(text: "And he arose, and rebuked the wind, and said unto the sea, Peace, be still. And the wind ceased, and there was a great calm.", ref: "Mark 4:39"),
  Passage(text: "For with God nothing shall be impossible.", ref: "Luke 1:37"),
  Passage(text: "And as ye would that men should do to you, do ye also to them likewise.", ref: "Luke 6:31"),
  Passage(text: "Judge not, and ye shall not be judged: condemn not, and ye shall not be condemned: forgive, and ye shall be forgiven.", ref: "Luke 6:37"),
  Passage(text: "Joy shall be in heaven over one sinner that repenteth, more than over ninety and nine just persons, which need no repentance.", ref: "Luke 15:7"),
  Passage(text: "Behold, the kingdom of God is within you.", ref: "Luke 17:21"),
  Passage(text: "And which of you with taking thought can add to his stature one cubit?", ref: "Luke 12:25"),
  Passage(text: "And the light shineth in darkness; and the darkness comprehended it not.", ref: "John 1:5"),
  Passage(text: "In the beginning was the Word, and the Word was with God, and the Word was God.", ref: "John 1:1"),
  Passage(text: "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.", ref: "John 3:16"),
  Passage(text: "I am the light of the world: he that followeth me shall not walk in darkness, but shall have the light of life.", ref: "John 8:12"),
  Passage(text: "And ye shall know the truth, and the truth shall make you free.", ref: "John 8:32"),
  Passage(text: "I am come that they might have life, and that they might have it more abundantly.", ref: "John 10:10"),
  Passage(text: "I am the resurrection, and the life: he that believeth in me, though he were dead, yet shall he live.", ref: "John 11:25"),
  Passage(text: "A new commandment I give unto you, That ye love one another; as I have loved you, that ye also love one another.", ref: "John 13:34"),
  Passage(text: "Let not your heart be troubled: ye believe in God, believe also in me.", ref: "John 14:1"),
  Passage(text: "I am the way, the truth, and the life: no man cometh unto the Father, but by me.", ref: "John 14:6"),
  Passage(text: "Peace I leave with you, my peace I give unto you: not as the world giveth, give I unto you. Let not your heart be troubled, neither let it be afraid.", ref: "John 14:27"),
  Passage(text: "I am the vine, ye are the branches: He that abideth in me, and I in him, the same bringeth forth much fruit: for without me ye can do nothing.", ref: "John 15:5"),
  Passage(text: "Greater love hath no man than this, that a man lay down his life for his friends.", ref: "John 15:13"),
  Passage(text: "These things I have spoken unto you, that in me ye might have peace. In the world ye shall have tribulation: but be of good cheer; I have overcome the world.", ref: "John 16:33"),
  Passage(text: "Blessed are they that have not seen, and yet have believed.", ref: "John 20:29"),
  Passage(text: "For in him we live, and move, and have our being.", ref: "Acts 17:28"),
  Passage(text: "It is more blessed to give than to receive.", ref: "Acts 20:35"),
  Passage(text: "We glory in tribulations also: knowing that tribulation worketh patience; and patience, experience; and experience, hope.", ref: "Romans 5:3–4"),
  Passage(text: "For I reckon that the sufferings of this present time are not worthy to be compared with the glory which shall be revealed in us.", ref: "Romans 8:18"),
  Passage(text: "And we know that all things work together for good to them that love God, to them who are the called according to his purpose.", ref: "Romans 8:28"),
  Passage(text: "What shall we then say to these things? If God be for us, who can be against us?", ref: "Romans 8:31"),
  Passage(text: "For I am persuaded, that neither death, nor life, nor angels, nor principalities, nor powers, nor things present, nor things to come, nor height, nor depth, nor any other creature, shall be able to separate us from the love of God, which is in Christ Jesus our Lord.", ref: "Romans 8:38–39"),
  Passage(text: "And be not conformed to this world: but be ye transformed by the renewing of your mind, that ye may prove what is that good, and acceptable, and perfect, will of God.", ref: "Romans 12:2"),
  Passage(text: "Rejoicing in hope; patient in tribulation; continuing instant in prayer.", ref: "Romans 12:12"),
  Passage(text: "Be not overcome of evil, but overcome evil with good.", ref: "Romans 12:21"),
  Passage(text: "Now the God of hope fill you with all joy and peace in believing, that ye may abound in hope, through the power of the Holy Ghost.", ref: "Romans 15:13"),
  Passage(text: "Charity suffereth long, and is kind; charity envieth not; charity vaunteth not itself, is not puffed up, doth not behave itself unseemly, seeketh not her own, is not easily provoked, thinketh no evil; rejoiceth not in iniquity, but rejoiceth in the truth; beareth all things, believeth all things, hopeth all things, endureth all things.", ref: "1 Corinthians 13:4–7"),
  Passage(text: "For now we see through a glass, darkly; but then face to face: now I know in part; but then shall I know even as also I am known.", ref: "1 Corinthians 13:12"),
  Passage(text: "And now abideth faith, hope, charity, these three; but the greatest of these is charity.", ref: "1 Corinthians 13:13"),
  Passage(text: "There hath no temptation taken you but such as is common to man: but God is faithful, who will not suffer you to be tempted above that ye are able; but will with the temptation also make a way to escape, that ye may be able to bear it.", ref: "1 Corinthians 10:13"),
  Passage(text: "Watch ye, stand fast in the faith, quit you like men, be strong.", ref: "1 Corinthians 16:13"),
  Passage(text: "Know ye not that they which run in a race run all, but one receiveth the prize? So run, that ye may obtain.", ref: "1 Corinthians 9:24"),
  Passage(text: "We are troubled on every side, yet not distressed; we are perplexed, but not in despair; persecuted, but not forsaken; cast down, but not destroyed.", ref: "2 Corinthians 4:8–9"),
  Passage(text: "For which cause we faint not; but though our outward man perish, yet the inward man is renewed day by day.", ref: "2 Corinthians 4:16"),
  Passage(text: "We look not at the things which are seen, but at the things which are not seen: for the things which are seen are temporal; but the things which are not seen are eternal.", ref: "2 Corinthians 4:18"),
  Passage(text: "For we walk by faith, not by sight.", ref: "2 Corinthians 5:7"),
  Passage(text: "Therefore if any man be in Christ, he is a new creature: old things are passed away; behold, all things are become new.", ref: "2 Corinthians 5:17"),
  Passage(text: "My grace is sufficient for thee: for my strength is made perfect in weakness.", ref: "2 Corinthians 12:9"),
  Passage(text: "But the fruit of the Spirit is love, joy, peace, longsuffering, gentleness, goodness, faith, meekness, temperance: against such there is no law.", ref: "Galatians 5:22–23"),
  Passage(text: "Bear ye one another's burdens, and so fulfil the law of Christ.", ref: "Galatians 6:2"),
  Passage(text: "And let us not be weary in well doing: for in due season we shall reap, if we faint not.", ref: "Galatians 6:9"),
  Passage(text: "For by grace are ye saved through faith; and that not of yourselves: it is the gift of God.", ref: "Ephesians 2:8"),
  Passage(text: "And be ye kind one to another, tenderhearted, forgiving one another, even as God for Christ's sake hath forgiven you.", ref: "Ephesians 4:32"),
  Passage(text: "Finally, my brethren, be strong in the Lord, and in the power of his might.", ref: "Ephesians 6:10"),
  Passage(text: "Be ye angry, and sin not: let not the sun go down upon your wrath.", ref: "Ephesians 4:26"),
  Passage(text: "Being confident of this very thing, that he which hath begun a good work in you will perform it until the day of Jesus Christ.", ref: "Philippians 1:6"),
  Passage(text: "This one thing I do, forgetting those things which are behind, and reaching forth unto those things which are before, I press toward the mark for the prize of the high calling of God in Christ Jesus.", ref: "Philippians 3:13–14"),
  Passage(text: "Be careful for nothing; but in every thing by prayer and supplication with thanksgiving let your requests be made known unto God. And the peace of God, which passeth all understanding, shall keep your hearts and minds through Christ Jesus.", ref: "Philippians 4:6–7"),
  Passage(text: "Whatsoever things are true, whatsoever things are honest, whatsoever things are just, whatsoever things are pure, whatsoever things are lovely, whatsoever things are of good report; if there be any virtue, and if there be any praise, think on these things.", ref: "Philippians 4:8"),
  Passage(text: "For I have learned, in whatsoever state I am, therewith to be content.", ref: "Philippians 4:11"),
  Passage(text: "I can do all things through Christ which strengtheneth me.", ref: "Philippians 4:13"),
  Passage(text: "Set your affection on things above, not on things on the earth.", ref: "Colossians 3:2"),
  Passage(text: "And whatsoever ye do, do it heartily, as to the Lord, and not unto men.", ref: "Colossians 3:23"),
  Passage(text: "And above all these things put on charity, which is the bond of perfectness.", ref: "Colossians 3:14"),
  Passage(text: "Rejoice evermore. Pray without ceasing. In every thing give thanks: for this is the will of God in Christ Jesus concerning you.", ref: "1 Thessalonians 5:16–18"),
  Passage(text: "Prove all things; hold fast that which is good.", ref: "1 Thessalonians 5:21"),
  Passage(text: "For God hath not given us the spirit of fear; but of power, and of love, and of a sound mind.", ref: "2 Timothy 1:7"),
  Passage(text: "I have fought a good fight, I have finished my course, I have kept the faith.", ref: "2 Timothy 4:7"),
  Passage(text: "Fight the good fight of faith, lay hold on eternal life, whereunto thou art also called.", ref: "1 Timothy 6:12"),
  Passage(text: "For the word of God is quick, and powerful, and sharper than any twoedged sword, piercing even to the dividing asunder of soul and spirit, and of the joints and marrow, and is a discerner of the thoughts and intents of the heart.", ref: "Hebrews 4:12"),
  Passage(text: "Now faith is the substance of things hoped for, the evidence of things not seen.", ref: "Hebrews 11:1"),
  Passage(text: "Let us lay aside every weight, and the sin which doth so easily beset us, and let us run with patience the race that is set before us.", ref: "Hebrews 12:1"),
  Passage(text: "Be not forgetful to entertain strangers: for thereby some have entertained angels unawares.", ref: "Hebrews 13:2"),
  Passage(text: "For he hath said, I will never leave thee, nor forsake thee.", ref: "Hebrews 13:5"),
  Passage(text: "Jesus Christ the same yesterday, and to day, and for ever.", ref: "Hebrews 13:8"),
  Passage(text: "My brethren, count it all joy when ye fall into divers temptations; knowing this, that the trying of your faith worketh patience.", ref: "James 1:2–3"),
  Passage(text: "If any of you lack wisdom, let him ask of God, that giveth to all men liberally, and upbraideth not; and it shall be given him.", ref: "James 1:5"),
  Passage(text: "Wherefore, my beloved brethren, let every man be swift to hear, slow to speak, slow to wrath.", ref: "James 1:19"),
  Passage(text: "But be ye doers of the word, and not hearers only, deceiving your own selves.", ref: "James 1:22"),
  Passage(text: "Draw nigh to God, and he will draw nigh to you.", ref: "James 4:8"),
  Passage(text: "Casting all your care upon him; for he careth for you.", ref: "1 Peter 5:7"),
  Passage(text: "And above all things have fervent charity among yourselves: for charity shall cover the multitude of sins.", ref: "1 Peter 4:8"),
  Passage(text: "Be sober, be vigilant; because your adversary the devil, as a roaring lion, walketh about, seeking whom he may devour.", ref: "1 Peter 5:8"),
  Passage(text: "God is light, and in him is no darkness at all.", ref: "1 John 1:5"),
  Passage(text: "If we confess our sins, he is faithful and just to forgive us our sins, and to cleanse us from all unrighteousness.", ref: "1 John 1:9"),
  Passage(text: "Beloved, let us love one another: for love is of God; and every one that loveth is born of God, and knoweth God.", ref: "1 John 4:7"),
  Passage(text: "There is no fear in love; but perfect love casteth out fear: because fear hath torment. He that feareth is not made perfect in love.", ref: "1 John 4:18"),
  Passage(text: "We love him, because he first loved us.", ref: "1 John 4:19"),
  Passage(text: "My little children, let us not love in word, neither in tongue; but in deed and in truth.", ref: "1 John 3:18"),
  Passage(text: "Behold, I stand at the door, and knock: if any man hear my voice, and open the door, I will come in to him, and will sup with him, and he with me.", ref: "Revelation 3:20"),
  Passage(text: "And God shall wipe away all tears from their eyes; and there shall be no more death, neither sorrow, nor crying, neither shall there be any more pain: for the former things are passed away.", ref: "Revelation 21:4"),
  Passage(text: "And he that sat upon the throne said, Behold, I make all things new.", ref: "Revelation 21:5"),
  Passage(text: "I am Alpha and Omega, the beginning and the end, the first and the last.", ref: "Revelation 22:13"),
  Passage(text: "But I say unto you, Love your enemies, bless them that curse you, do good to them that hate you, and pray for them which despitefully use you, and persecute you.", ref: "Matthew 5:44"),
  Passage(text: "For where two or three are gathered together in my name, there am I in the midst of them.", ref: "Matthew 18:20"),
  Passage(text: "Give, and it shall be given unto you; good measure, pressed down, and shaken together, and running over, shall men give into your bosom.", ref: "Luke 6:38"),
  Passage(text: "The night is far spent, the day is at hand: let us therefore cast off the works of darkness, and let us put on the armour of light.", ref: "Romans 13:12"),
  Passage(text: "For ye were sometimes darkness, but now are ye light in the Lord: walk as children of light.", ref: "Ephesians 5:8"),
  Passage(text: "O death, where is thy sting? O grave, where is thy victory?", ref: "1 Corinthians 15:55"),
  Passage(text: "Verily, verily, I say unto you, Except a corn of wheat fall into the ground and die, it abideth alone: but if it die, it bringeth forth much fruit.", ref: "John 12:24"),
  Passage(text: "Enter ye in at the strait gate: for wide is the gate, and broad is the way, that leadeth to destruction. Because strait is the gate, and narrow is the way, which leadeth unto life, and few there be that find it.", ref: "Matthew 7:13–14"),
  Passage(text: "No man, having put his hand to the plough, and looking back, is fit for the kingdom of God.", ref: "Luke 9:62"),
  Passage(text: "For whosoever will save his life shall lose it: and whosoever will lose his life for my sake shall find it.", ref: "Matthew 16:25"),
  Passage(text: "For the good that I would I do not: but the evil which I would not, that do I.", ref: "Romans 7:19"),
]

// MARK: - Schedule: a new passage every 4 hours, local time; full cycle before any repeat

let hoursPerPassage = 4

/// Fixed, seeded shuffle so the order feels unordered but is stable between launches.
let order: [Int] = {
  var idx = Array(0..<passages.count)
  var seed: UInt64 = 0x5EED_1611_C0DE
  for i in stride(from: idx.count - 1, to: 0, by: -1) {
    seed = seed &* 6364136223846793005 &+ 1442695040888963407
    let j = Int((seed >> 33) % UInt64(i + 1))
    idx.swapAt(i, j)
  }
  return idx
}()

func currentSlot(_ now: Date = Date()) -> Int {
  let cal = Calendar.current
  let epoch = cal.date(from: DateComponents(year: 2024, month: 1, day: 1))!
  let days = cal.dateComponents([.day], from: cal.startOfDay(for: epoch), to: cal.startOfDay(for: now)).day ?? 0
  let hour = cal.component(.hour, from: now)
  return days * (24 / hoursPerPassage) + hour / hoursPerPassage
}

// MARK: - Palette & type

let ivory   = NSColor(srgbRed: 0.93, green: 0.90, blue: 0.84, alpha: 1.0)
let muted   = NSColor(srgbRed: 0.93, green: 0.90, blue: 0.84, alpha: 0.45)
let gilt    = NSColor(srgbRed: 0.76, green: 0.67, blue: 0.50, alpha: 0.95)
let hairline = NSColor(srgbRed: 0.76, green: 0.67, blue: 0.50, alpha: 0.35)

func serif(_ size: CGFloat, italic: Bool = false) -> NSFont {
  let names = italic ? ["Baskerville-Italic", "Didot-Italic", "Georgia-Italic"]
                     : ["Baskerville", "Didot", "Georgia"]
  for n in names { if let f = NSFont(name: n, size: size) { return f } }
  return NSFont.systemFont(ofSize: size)
}

func tracked(_ s: String, font: NSFont, color: NSColor, kern: CGFloat) -> NSAttributedString {
  let p = NSMutableParagraphStyle(); p.alignment = .center
  return NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: color, .kern: kern, .paragraphStyle: p])
}

// MARK: - Widget

let defaultWidth: CGFloat = 340
let minWidth: CGFloat = 220
let pad: CGFloat = 26
let edgeMargin: CGFloat = 8
let defaultGap: CGFloat = 16
let snapDistance: CGFloat = 70

final class Panel: NSWindow {
  var editing = false
  override var canBecomeKey: Bool { editing }
  override var canBecomeMain: Bool { false }
}

/// Transparent layer over the whole widget: handles dragging, the right-click menu and arrow-key nudging.
final class HandleView: NSView {
  weak var owner: AppDelegate?
  private var grab = NSPoint.zero
  override func hitTest(_ point: NSPoint) -> NSView? { frame.contains(point) ? self : nil }
  override var acceptsFirstResponder: Bool { true }
  override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
  override func mouseDown(with e: NSEvent) {
    guard let w = window else { return }
    let p = NSEvent.mouseLocation
    grab = NSPoint(x: p.x - w.frame.minX, y: p.y - w.frame.minY)
  }
  override func mouseDragged(with e: NSEvent) {
    guard let w = window else { return }
    let p = NSEvent.mouseLocation
    w.setFrameOrigin(NSPoint(x: round(p.x - grab.x), y: round(p.y - grab.y)))
  }
  override func mouseUp(with e: NSEvent) { owner?.dragEnded() }
  override func keyDown(with e: NSEvent) {
    guard let o = owner else { return }
    let step: CGFloat = e.modifierFlags.contains(.shift) ? 10 : 1
    let widthMode = e.modifierFlags.contains(.command)
    switch e.keyCode {
    case 123: widthMode ? o.resize(by: -step) : o.nudge(dx: -step, dy: 0)   // ←
    case 124: widthMode ? o.resize(by: step)  : o.nudge(dx: step, dy: 0)    // →
    case 125: o.nudge(dx: 0, dy: -step)                                     // ↓
    case 126: o.nudge(dx: 0, dy: step)                                      // ↑
    case 36, 76, 53: o.setEditing(false)                                    // Return / Esc
    default: super.keyDown(with: e)
    }
  }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  var window: Panel!
  var glass: NSVisualEffectView!
  var stack: NSStackView!
  var widthConstraint: NSLayoutConstraint!
  let handle = HandleView()
  let header = NSTextField(labelWithString: "")
  let body = NSTextField(wrappingLabelWithString: "")
  let refLabel = NSTextField(labelWithString: "")
  let editItem = NSMenuItem(title: "Fine-Tune Position…", action: #selector(toggleEditing), keyEquivalent: "")
  var shownSlot = -1
  var timer: Timer?

  // Saved placement: left edge, top edge (the widget grows downwards), width.
  let store = UserDefaults.standard
  var left: CGFloat?  { (store.object(forKey: "left") as? Double).map { CGFloat($0) } }
  var top: CGFloat?   { (store.object(forKey: "top") as? Double).map { CGFloat($0) } }
  var width: CGFloat  { max(minWidth, (store.object(forKey: "width") as? Double).map { CGFloat($0) } ?? defaultWidth) }

  func applicationDidFinishLaunching(_ note: Notification) {
    window = Panel(contentRect: NSRect(x: 0, y: 0, width: width, height: 200),
                   styleMask: [.borderless], backing: .buffered, defer: false)
    window.isOpaque = false
    window.backgroundColor = .clear
    window.hasShadow = true
    window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
    window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenNone]
    window.isMovable = false

    glass = NSVisualEffectView()
    glass.material = .hudWindow
    glass.blendingMode = .behindWindow
    glass.state = .active
    glass.appearance = NSAppearance(named: .darkAqua)
    glass.wantsLayer = true
    glass.layer?.cornerRadius = 22
    glass.layer?.cornerCurve = .continuous
    glass.layer?.masksToBounds = true
    glass.layer?.borderWidth = 0.5
    glass.layer?.borderColor = NSColor(white: 1, alpha: 0.14).cgColor
    window.contentView = glass

    showHeader()

    let rule = NSView()
    rule.wantsLayer = true
    rule.layer?.backgroundColor = hairline.cgColor
    rule.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([rule.widthAnchor.constraint(equalToConstant: 44),
                                 rule.heightAnchor.constraint(equalToConstant: 0.5)])

    body.isSelectable = false

    stack = NSStackView(views: [header, rule, body, refLabel])
    stack.orientation = .vertical
    stack.alignment = .centerX
    stack.spacing = 14
    stack.setCustomSpacing(18, after: rule)
    stack.setCustomSpacing(16, after: body)
    stack.edgeInsets = NSEdgeInsets(top: 20, left: pad, bottom: 20, right: pad)
    stack.translatesAutoresizingMaskIntoConstraints = false
    glass.addSubview(stack)
    widthConstraint = stack.widthAnchor.constraint(equalToConstant: width)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: glass.leadingAnchor),
      stack.topAnchor.constraint(equalTo: glass.topAnchor),
      widthConstraint,
    ])

    handle.owner = self
    handle.frame = glass.bounds
    handle.autoresizingMask = [.width, .height]
    glass.addSubview(handle)

    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Copy Passage", action: #selector(copyPassage), keyEquivalent: ""))
    menu.addItem(.separator())
    menu.addItem(NSMenuItem(title: "Snap Under Widgets Above", action: #selector(snapNow), keyEquivalent: ""))
    menu.addItem(editItem)
    menu.addItem(NSMenuItem(title: "Reset Position", action: #selector(resetPosition), keyEquivalent: ""))
    menu.addItem(.separator())
    menu.addItem(NSMenuItem(title: "Quit Verbum", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
    for item in menu.items { item.target = item.action == #selector(NSApplication.terminate(_:)) ? nil : self }
    handle.menu = menu

    refresh(animated: false)
    window.orderFrontRegardless()

    timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in self?.refresh(animated: true) }
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(wake), name: NSWorkspace.didWakeNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(layoutWindow), name: NSApplication.didChangeScreenParametersNotification, object: nil)
  }

  var current: Passage { passages[order[((currentSlot() % passages.count) + passages.count) % passages.count]] }

  func showHeader() {
    let text = window?.editing == true ? "ARROWS MOVE  ·  ⌘ ARROWS WIDTH  ·  RETURN DONE" : "NOVUM  TESTAMENTUM"
    header.attributedStringValue = tracked(text, font: serif(9), color: window?.editing == true ? gilt : muted, kern: window?.editing == true ? 1.2 : 2.6)
  }

  @objc func wake() { refresh(animated: true) }

  @objc func copyPassage() {
    let p = current
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString("\(p.text) — \(p.ref) (KJV)", forType: .string)
  }

  func refresh(animated: Bool) {
    let slot = currentSlot()
    guard slot != shownSlot else { return }
    shownSlot = slot
    let apply = { [self] in
      let p = current
      let para = NSMutableParagraphStyle()
      para.alignment = .center
      para.lineSpacing = 4
      body.attributedStringValue = NSAttributedString(string: p.text, attributes: [
        .font: serif(14.5, italic: true), .foregroundColor: ivory, .paragraphStyle: para])
      refLabel.attributedStringValue = tracked(p.ref.uppercased(), font: serif(10), color: gilt, kern: 2.2)
      layoutWindow()
    }
    if animated {
      NSAnimationContext.runAnimationGroup({ ctx in
        ctx.duration = 0.6; window.animator().alphaValue = 0
      }, completionHandler: { [self] in
        apply()
        NSAnimationContext.runAnimationGroup { ctx in ctx.duration = 0.9; window.animator().alphaValue = 1 }
      })
    } else { apply() }
  }

  /// Size to the passage and place it: saved spot (top edge fixed), else the bottom-right corner.
  @objc func layoutWindow() {
    let w = width
    widthConstraint.constant = w
    body.preferredMaxLayoutWidth = w - pad * 2
    stack.layoutSubtreeIfNeeded()
    let h = ceil(stack.fittingSize.height)
    guard let screen = NSScreen.screens.first else { return }
    let vf = screen.visibleFrame
    var x = vf.maxX - w - edgeMargin
    var y = screen.frame.minY + edgeMargin
    if let l = left, let t = top {
      x = l; y = t - h
    }
    window.setFrame(NSRect(x: x, y: y, width: w, height: h), display: true)
  }

  func save(left l: CGFloat, top t: CGFloat, width w: CGFloat? = nil) {
    store.set(Double(l), forKey: "left")
    store.set(Double(t), forKey: "top")
    if let w = w { store.set(Double(max(minWidth, w)), forKey: "width") }
  }

  // MARK: Placement

  /// Frames of macOS desktop widgets (owned by Notification Centre), in screen coordinates.
  func widgetFrames() -> [CGRect] {
    guard let info = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]],
          let primary = NSScreen.screens.first else { return [] }
    let me = Int(ProcessInfo.processInfo.processIdentifier)
    var out: [CGRect] = []
    for w in info {
      guard (w[kCGWindowOwnerPID as String] as? Int) != me,
            let owner = w[kCGWindowOwnerName as String] as? String,
            owner.localizedCaseInsensitiveContains("notification") || owner.localizedCaseInsensitiveContains("widget"),
            let b = w[kCGWindowBounds as String] as? [String: CGFloat],
            let bx = b["X"], let by = b["Y"], let bw = b["Width"], let bh = b["Height"],
            bw >= 80, bh >= 80, bw <= 900, bh <= 900 else { continue }
      out.append(CGRect(x: bx, y: primary.frame.maxY - by - bh, width: bw, height: bh))
    }
    return out
  }

  /// Line up under the row of widgets directly above: same left and right edges, same gap as between them.
  @discardableResult
  func snapUnderWidgets(force: Bool) -> Bool {
    let me = window.frame
    let above = widgetFrames().filter { $0.minY >= me.maxY - snapDistance && $0.maxX > me.minX - snapDistance && $0.minX < me.maxX + snapDistance }
    guard let nearest = above.min(by: { $0.minY - me.maxY < $1.minY - me.maxY }) else { return false }
    let row = above.filter { abs($0.minY - nearest.minY) < 6 }.sorted { $0.minX < $1.minX }
    var gap = defaultGap
    if row.count >= 2 { gap = max(4, row[1].minX - row[0].maxX) }
    let targetTop = nearest.minY - gap
    guard force || abs(me.maxY - targetTop) < snapDistance else { return false }
    let l = row.first!.minX, r = row.last!.maxX
    save(left: l, top: targetTop, width: r - l)
    layoutWindow()
    return true
  }

  func dragEnded() {
    let f = window.frame
    save(left: f.minX, top: f.maxY)
    if !window.editing { snapUnderWidgets(force: false) }
  }

  @objc func snapNow() {
    if !snapUnderWidgets(force: true) {
      let a = NSAlert()
      a.messageText = "No widgets found above"
      a.informativeText = "Drag Verbum just below the widgets first, then try again. You can also use Fine-Tune Position to line it up with the arrow keys."
      NSApp.activate(ignoringOtherApps: true)
      a.runModal()
    }
  }

  func nudge(dx: CGFloat, dy: CGFloat) {
    let f = window.frame
    save(left: f.minX + dx, top: f.maxY + dy)
    layoutWindow()
  }

  func resize(by d: CGFloat) {
    let f = window.frame
    save(left: f.minX, top: f.maxY, width: f.width + d)
    layoutWindow()
  }

  @objc func toggleEditing() { setEditing(!window.editing) }

  func setEditing(_ on: Bool) {
    window.editing = on
    editItem.state = on ? .on : .off
    glass.layer?.borderWidth = on ? 1 : 0.5
    glass.layer?.borderColor = on ? gilt.cgColor : NSColor(white: 1, alpha: 0.14).cgColor
    showHeader()
    if on {
      NSApp.activate(ignoringOtherApps: true)
      window.makeKeyAndOrderFront(nil)
      window.makeFirstResponder(handle)
    } else {
      NSApp.deactivate()
    }
  }

  @objc func resetPosition() {
    for k in ["left", "top", "width"] { store.removeObject(forKey: k) }
    layoutWindow()
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
SWIFT

echo "→ Compiling…"
mkdir -p "$BUILD/$APP_NAME.app/Contents/MacOS"
xcrun swiftc -O "$BUILD/main.swift" -o "$BUILD/$APP_NAME.app/Contents/MacOS/$APP_NAME" -framework Cocoa

cat > "$BUILD/$APP_NAME.app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>$APP_NAME</string>
  <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
  <key>CFBundleExecutable</key><string>$APP_NAME</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$BUILD/$APP_NAME.app" >/dev/null 2>&1 || true

echo "→ Installing to ${APP_DIR}…"
launchctl bootout "gui/$(id -u)/$BUNDLE_ID" >/dev/null 2>&1 || true
pkill -x "$APP_NAME" >/dev/null 2>&1 || true
mkdir -p "$HOME/Applications"
rm -rf "$APP_DIR"
cp -R "$BUILD/$APP_NAME.app" "$APP_DIR"

echo "→ Setting it to start at login…"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$BUNDLE_ID</string>
  <key>ProgramArguments</key><array><string>$APP_DIR/Contents/MacOS/$APP_NAME</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>
  <key>ProcessType</key><string>Interactive</string>
</dict></plist>
PLIST
launchctl bootstrap "gui/$(id -u)" "$AGENT"

rm -rf "$BUILD"
echo "✓ Done. Verbum is now in the bottom-right corner of your desktop."
echo "  Drag it under your widgets and let go: it snaps into line. Right-click for more options."
