String? validateStudyPlanTopic(String value) {
  final topic = value.trim();

  if (topic.isEmpty) {
    return 'Please enter a topic or assignment name.';
  }

  if (topic.length < 3) {
    return 'Topic must be at least 3 characters.';
  }

  if (topic.length > 60) {
    return 'Topic must be 60 characters or less.';
  }

  return null;
}
