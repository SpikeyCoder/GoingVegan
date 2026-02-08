# Accessibility Testing Guide
## Going Vegan - Login Screen

This guide provides step-by-step instructions for testing the accessibility features of the Login Screen.

---

## 🎯 Quick Start

### Enable Accessibility Shortcuts
1. Settings → Accessibility → Accessibility Shortcut
2. Select: VoiceOver, Zoom, Reduce Motion
3. Triple-click side button to toggle features

---

## 📱 Testing with VoiceOver

### Enable VoiceOver
- **Method 1:** Settings → Accessibility → VoiceOver → On
- **Method 2:** Triple-click side button (if configured)
- **Method 3:** Ask Siri: "Turn on VoiceOver"

### VoiceOver Gestures
- **Swipe Right:** Next element
- **Swipe Left:** Previous element
- **Double Tap:** Activate element
- **Two-finger Scrub:** Go back
- **Three-finger Swipe Up/Down:** Scroll page

### Testing Checklist

#### ✅ Logo and Title
1. Swipe to logo
   - Should announce: "Going Vegan app logo"
2. Swipe to title
   - Should announce: "Going Vegan, heading"
3. Swipe to tagline
   - Should announce: "Tagline: Discover delicious vegan recipes, restaurants, and more"

#### ✅ Social Sign-In Buttons
1. Swipe to Apple button
   - Should announce: "Sign in with Apple, button"
   - Should announce hint: "Quickly sign in using your Apple ID"
2. Double tap to activate (test functionality)
3. Swipe to Google button
   - Should announce: "Sign in with Google, button"
   - Should announce hint: "Quickly sign in using your Google account"

#### ✅ Divider Text
1. Swipe to divider
   - Should announce: "or continue with email"
   - Decorative lines should be skipped

#### ✅ Email Field
1. Swipe to email field
   - Should announce: "Email address, text field"
   - When empty: "Empty"
2. Double tap to focus
3. Enter email address
   - Should announce: "Email address, [entered email]"

#### ✅ Password Field
1. Swipe to password field
   - Should announce: "Password, secure text field"
   - When empty: "Empty"
   - When filled: "Entered"
2. Double tap to focus
3. Enter password

#### ✅ Error Messages
1. Try signing in with wrong credentials
   - Should announce: "Error: Username and/or password is incorrect"
2. Wait 3 seconds
   - Error should auto-dismiss

#### ✅ Sign In Button
1. With empty fields:
   - Should announce: "Sign in with email, button, dimmed"
2. With filled fields:
   - Should announce: "Sign in with email, button"
   - Hint: "Double tap to sign in to your account"
3. During loading:
   - Should announce: "Signing in"

#### ✅ Create Account Button
1. Swipe to signup button
   - Should announce: "Create new account, button"
   - Hint: "Double tap to create a new Going Vegan account"

### Create Account Modal Testing

#### ✅ Modal Header
1. Should announce: "Create Account, heading"
2. Close button:
   - Should announce: "Close, button"
   - Hint: "Double tap to close account creation and return to sign in"

#### ✅ Password Requirements
1. Enter password with less than 6 characters
   - Should announce: "At least 6 characters: not met"
2. Enter 6+ characters
   - Should announce: "At least 6 characters: met"

#### ✅ Create Account Button
1. With invalid fields:
   - Should announce: "Create account, button, dimmed"
2. With valid fields:
   - Should announce: "Create account, button"

---

## 📏 Testing Dynamic Type

### Enable Larger Text
1. Settings → Accessibility → Display & Text Size → Larger Text
2. Drag slider to test various sizes
3. Test up to maximum accessibility size (Accessibility 5)

### Testing Checklist

#### ✅ Text Scaling
- [ ] Title scales appropriately
- [ ] Button text remains readable
- [ ] Text fields expand properly
- [ ] Error messages scale without clipping
- [ ] Modal content remains scrollable

#### ✅ Layout Adaptation
- [ ] Buttons maintain minimum height
- [ ] Spacing adjusts appropriately
- [ ] No text truncation (...)
- [ ] All content remains accessible
- [ ] Scroll views work properly

#### ✅ Maximum Size (xxxLarge)
- [ ] Layout doesn't break
- [ ] Text is still readable
- [ ] Buttons are still tappable
- [ ] No content overlapping

---

## 🌓 Testing Dark Mode

### Enable Dark Mode
- **Method 1:** Control Center → Long press brightness → Dark Mode
- **Method 2:** Settings → Display & Brightness → Dark

### Testing Checklist

#### ✅ Colors
- [ ] Text remains readable
- [ ] Buttons have appropriate contrast
- [ ] Background gradient adjusts properly
- [ ] Error messages are visible
- [ ] Success messages are visible

#### ✅ Elements
- [ ] Logo border visible
- [ ] Text field borders visible
- [ ] Button styles appropriate
- [ ] Modal background correct
- [ ] Shadows/overlays work

---

## 🎨 Testing Color Contrast

### Using Xcode Accessibility Inspector
1. Open project in Xcode
2. Run on simulator or device
3. Xcode → Open Developer Tool → Accessibility Inspector
4. Select target device
5. Click "Inspection" pointer
6. Click elements to see contrast ratios

### Manual Contrast Check

#### ✅ Text on Backgrounds
- **Primary text on white:** Should be ≥ 4.5:1
- **Primary text on light green:** Should be ≥ 4.5:1
- **Button text (white on blue):** Should be ≥ 4.5:1 (typically 7:1+)
- **Error text (red):** Should be ≥ 4.5:1
- **Success text (green):** Should be ≥ 4.5:1

#### ✅ UI Elements
- **Button borders:** Should be ≥ 3:1
- **Text field borders:** Should be ≥ 3:1
- **Focus indicators:** Should be ≥ 3:1

---

## ⌨️ Testing Keyboard Navigation

### Connect External Keyboard
1. Bluetooth keyboard or iPad keyboard

### Testing Checklist

#### ✅ Tab Navigation
- [ ] Tab moves focus to email field
- [ ] Tab moves to password field
- [ ] Tab moves to sign in button
- [ ] Tab moves to sign up button
- [ ] Shift+Tab reverses order

#### ✅ Return Key
- [ ] Return in email field → moves to password
- [ ] Return in password field → submits form

#### ✅ Escape Key
- [ ] Escape dismisses keyboard
- [ ] Escape closes modal

#### ✅ Arrow Keys
- [ ] Work within text fields
- [ ] Don't interfere with VoiceOver navigation

---

## 🎭 Testing Reduced Motion

### Enable Reduce Motion
1. Settings → Accessibility → Motion → Reduce Motion → On

### Testing Checklist
- [ ] Animations still functional but gentler
- [ ] Modal appears/disappears smoothly
- [ ] Error messages appear without jarring motion
- [ ] Button press feedback still works
- [ ] No spinning or parallax effects

---

## 🎯 Testing Voice Control

### Enable Voice Control
1. Settings → Accessibility → Voice Control → On

### Testing Checklist

#### ✅ Basic Commands
- Say "Show numbers" → Elements should be numbered
- Say "Tap [number]" → Element activates
- Say "Scroll down" → Page scrolls

#### ✅ Named Commands
- "Tap sign in with Apple"
- "Tap sign in with Google"
- "Tap create new account"
- "Tap email address"
- "Tap password"
- "Tap sign in"

---

## 🔍 Testing with Xcode Accessibility Inspector

### Launch Inspector
1. Xcode → Open Developer Tool → Accessibility Inspector
2. Choose target device/simulator
3. Navigate to Login screen

### Audit Checklist

#### ✅ Automated Audit
1. Click "Run Audit" button
2. Review any warnings/errors
3. Expected: 0 critical issues

#### ✅ Element Inspection
1. Click inspection pointer
2. Tap each element
3. Verify:
   - Label is present and clear
   - Value is appropriate
   - Traits are correct
   - Hint is helpful (not redundant)
   - Frame meets size requirements (44x44 minimum)

#### ✅ Contrast Analysis
1. Select element
2. Check "Contrast" section
3. Verify ratio meets standards

---

## 📊 Testing Checklist Summary

### Critical Tests (Must Pass)
- [ ] VoiceOver navigation complete
- [ ] All text fields have labels
- [ ] All buttons are labeled and accessible
- [ ] Error messages are announced
- [ ] Keyboard navigation works
- [ ] Dynamic Type up to xxxLarge works
- [ ] Dark Mode displays correctly
- [ ] Touch targets meet 44x44pt minimum
- [ ] Text contrast meets 4.5:1
- [ ] UI element contrast meets 3:1

### Recommended Tests
- [ ] Voice Control commands work
- [ ] Reduce Motion is respected
- [ ] Button Shapes enhancement visible
- [ ] Increase Contrast enhancement works
- [ ] Multiple orientations work
- [ ] Different device sizes work

### Optional Tests
- [ ] Color blindness simulations
- [ ] Extreme zoom (Accessibility Zoom)
- [ ] Dictation for text input
- [ ] Switch Control navigation
- [ ] AssistiveTouch compatibility

---

## 🐛 Common Issues to Watch For

### VoiceOver Issues
- ❌ Unlabeled buttons (announced as just "Button")
- ❌ Redundant hints that repeat the label
- ❌ Decorative images not hidden
- ❌ Icon-only buttons without text alternatives
- ❌ Generic labels like "Button 1"

### Dynamic Type Issues
- ❌ Text truncation with ellipsis (...)
- ❌ Fixed height containers causing clipping
- ❌ Horizontal scrolling required
- ❌ Overlapping elements
- ❌ Unreadable small text

### Contrast Issues
- ❌ Light gray text on white background
- ❌ Low contrast disabled states
- ❌ Gradient backgrounds reducing contrast
- ❌ Transparent overlays reducing legibility

### Keyboard Issues
- ❌ Focus not visible
- ❌ Keyboard traps (can't escape)
- ❌ Illogical tab order
- ❌ Missing keyboard shortcuts

---

## 📈 Reporting Issues

### Issue Template
```
**Issue:** [Brief description]
**Severity:** [Critical/High/Medium/Low]
**Accessibility Feature:** [VoiceOver/Dynamic Type/etc]
**Steps to Reproduce:**
1. 
2. 
3. 

**Expected Behavior:**
**Actual Behavior:**
**WCAG Criterion:** [e.g., 1.4.3 Contrast]
**Screenshots/Recording:**
```

---

## ✅ Sign-off Checklist

Before releasing, ensure:
- [ ] All critical tests pass
- [ ] No critical accessibility issues
- [ ] Tested with at least 3 assistive technologies
- [ ] Tested on physical device (not just simulator)
- [ ] Tested with real users if possible
- [ ] Documentation is up to date
- [ ] Screenshots taken for reference

---

## 🎓 Learning Resources

### Apple Resources
- [Accessibility Inspector User Guide](https://developer.apple.com/library/archive/documentation/Accessibility/Conceptual/AccessibilityMacOSX/OSXAXTestingApps.html)
- [VoiceOver Getting Started Guide](https://support.apple.com/guide/voiceover/welcome/mac)
- [Testing VoiceOver in Apps (WWDC)](https://developer.apple.com/videos/)

### WCAG Resources
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)

### Testing Tools
- [Color Oracle](https://colororacle.org/) - Color blindness simulator
- [Sim Daltonism](https://michelf.ca/projects/sim-daltonism/) - Color blindness simulator for iOS
- [Accessibility Scanner (Android)](https://play.google.com/store/apps/details?id=com.google.android.apps.accessibility.auditor) - Cross-platform reference

---

**Last Updated:** February 7, 2026
**Version:** 1.0
**Platform:** iOS 15.0+
