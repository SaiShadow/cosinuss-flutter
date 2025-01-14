# Flow State App

Flow State is a Flutter-based productivity app that integrates with the Cosinuss Earable sensor to optimize work sessions and manage stress based on the user's unique study habits by dynamically adjusting the length of the work and break session by the user's focus and stress. The app combines real-time biometric tracking with the Pomodoro technique to create a personalized and adaptive productivity experience.

- Connect your Cosinuss Earable, start the timer, and put it to the side.
- The timer turns black so as not to distract your work.
- After the timer is done, a timer sound is played and the colour changes to bright blue/red depending on the time for a break or work.
- Any time users can see how their session data, consisting of focus, stress, heart rate and temperature fluctuated during their sessions.

---

## Additional Information

For detailed instructions, implementation notes, and technical insights, please refer to the [info PDF](./2417956-Flutter_App.pdf).

---

## Features

### 1. **Pomodoro Timer with Adaptive Durations**
The app provides a Pomodoro timer that adjusts work and break durations dynamically based on biometric feedback:
- **Work Sessions**:
  - Default duration: 25 minutes.
  - Extended if focus levels are consistently high.
  - Shortened if the user is highly stressed.
- **Break Sessions**:
  - Default duration: 5 minutes.
  - Lengthened if stress remains elevated during breaks.

**User Alerts:**
- **Colors**: 
  - **Black** background when the timer is running to not disturb the user.
  - Work sessions are displayed in a vibrant **red** background to emphasize focus.
  - Break sessions are displayed in a calming **blue** background to encourage relaxation.
- **Sounds**: 
  - At the end of each session, a sound is played to notify the user to switch between work and break modes.

---

### 2. **Real-Time Biometric Tracking**
The app continuously collects and processes data from the Cosinuss Earable sensor, including:
- **Heart Rate**: Tracks average and fluctuating heart rates.
- **Body Temperature**: Monitors body temperature stability during sessions.
- **Movement Data**: Uses accelerometer data to detect physical activity or stillness.

**Key Calculations**:
- **Focus Score**:
  - Derived from heart rate stability, minimal movement, and body temperature consistency.
  - Higher scores indicate optimal focus.
- **Stress Score**:
  - Calculated based on deviations in heart rate, increased movement, and body temperature irregularities.
  - Alerts the user to take longer breaks when stress levels are high.

---

### 3. **Interactive Graphs**
The app visualizes session data using interactive graphs:
- **Focus Trends**: Displays how focus scores change during work sessions.
- **Stress Trends**: Highlights stress levels over time to encourage proactive stress management.
- **Heart Rate Graph**: Monitors real-time and historical heart rate data during sessions.
- **Body Temperature Graph**: Tracks body temperature fluctuations for insights into overall health.

**Graph Features**:
- Time-based x-axis to show session progress.
- Dynamic y-axis that scales based on real-time values.
- Interactive tooltips for exploring specific data points.

---

### 4. **Modes for Personalization**
Users can choose between two modes:
- **Extreme Focus Mode**:
  - Prioritizes productivity.
  - Increases work session duration if the user is still focused at the end of the work session.
- **Low Stress Mode**:
  - Focuses on well-being.
  - Reduce work session time if the user is highly stressed.
  - Extends breaks when stress levels are elevated.

---

## Visual & Auditory Feedback

1. **Colors**: Alerts users about the session change when the phone is put in the peripheral view while working on tasks.
   - **Red for Work**: Motivates users to concentrate. 
   - **Blue for Breaks**: Promotes relaxation.
   - **Dark Mode**: Activated during active sessions for a distraction-free environment.

2. **Sounds**:
   - **Session Start Sound**: Alerts the user to begin their session.
   - **Session End Sound**: Indicates when it’s time to switch modes (e.g., from work to break).
   - Sounds are subtle yet noticeable to ensure minimal distraction.

---

## Before You Start

### Prerequisites
1. **Install Flutter**:
   - Follow the [official Flutter setup guide](https://flutter.dev/docs/get-started/install).
2. **Install Dependencies**:
   - Ensure the `flutter_blue` package is included for Bluetooth functionality.
3. **Device Compatibility**:
   - Tested on an iPhone 14. Works best when using the **"Run Without Debugging"** option in VSCode.

---

## Project Structure

The app is structured for modularity and ease of navigation:

- **`lib/`**
  - **`models/`**: Contains data models and logic for calculations.
    - `sensor_data.dart`: Manages real-time sensor data.
    - `baseline_metrics.dart`: Handles user-specific baseline calculations.
    - `focus_calculator.dart` & `stress_calculator.dart`: Algorithms for biometric analysis.
  - **`pages/`**: UI pages for the app.
    - `home_page.dart`: Bluetooth connection and sensor status.
    - `pomodoro_timer_page.dart`: Pomodoro timer with focus and stress monitoring.
    - `graph_page.dart`: Displays interactive graphs for session data.
  - **`utils/`**:
    - `bluetooth_service.dart`: Handles Bluetooth connectivity with the Cosinuss Earable sensor.
  - **`widgets/`**:
    - `sensor_display_widget.dart`: Reusable component for displaying sensor data.
