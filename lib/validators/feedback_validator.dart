String? validateFeedbackMessage(String value) {
  final message = value.trim();

  if (message.length < 10) {
    return 'Please write at least 10 characters so we can understand your feedback.';
  }

  if (message.length > 2000) {
    return 'Please keep feedback under 2000 characters.';
  }

  return null;
}
