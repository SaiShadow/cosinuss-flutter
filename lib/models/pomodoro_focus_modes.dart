/// An enumeration representing the available focus modes in the Pomodoro Timer.
///
/// Each mode affects the behavior of the timer differently, depending on the user's preference.
enum FocusMode {
  /// Extreme Focus mode:
  /// Designed for users aiming to maximize productivity with minimal interruptions.
  /// Focus sessions are prioritized, and stress levels are less likely to alter the session duration.
  extremeFocus,

  /// Low Stress mode:
  /// Tailored for users seeking a balanced approach between productivity and well-being.
  /// Focus sessions may be shortened or extended based on real-time stress levels to maintain a low-stress state.
  lowStress,
}
