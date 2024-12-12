class UserProgressModel {
  // เก็บว่าผู้ใช้ปลดล็อคถึงระดับไหน (เช่น 'B2' แปลว่าทำ B1 ครบตามเงื่อนไขแล้ว)
  final String highestUnlockedLevel;

  // เก็บจำนวน topic ที่ผ่าน (≥60%) ในแต่ละ level
  // เช่น {'B1': 5, 'B2': 3} แปลว่าใน B1 ผ่าน 5 topic แล้ว ใน B2 ผ่าน 3 topic
  final Map<String, int> passedTopicsCount;

  // เก็บสถานะการปลดล็อคของแต่ละ topic โดยตรง
  // เช่น {'B1': {'topic1': true, 'topic2': false}, 'B2': {...}}
  // จะใช้หรือไม่ใช้ก็ได้ แล้วแต่การออกแบบระบบ
  final Map<String, Map<String, bool>> topicUnlockStatus;

  UserProgressModel({
    required this.highestUnlockedLevel,
    required this.passedTopicsCount,
    required this.topicUnlockStatus,
  });

  factory UserProgressModel.fromMap(Map<String, dynamic> data) {
    final passedCountData = data['passedTopicsCount'] as Map<String, dynamic>? ?? {};
    final Map<String, int> passedCountParsed = passedCountData.map((k, v) => MapEntry(k, (v as num).toInt()));

    final unlockData = data['topicUnlockStatus'] as Map<String, dynamic>? ?? {};
    final Map<String, Map<String, bool>> topicUnlockParsed = unlockData.map((level, topics) {
      final t = (topics as Map<String, dynamic>).map((tk, tv) => MapEntry(tk, tv as bool));
      return MapEntry(level, t);
    });

    return UserProgressModel(
      highestUnlockedLevel: data['highestUnlockedLevel'] as String? ?? 'B1',
      passedTopicsCount: passedCountParsed,
      topicUnlockStatus: topicUnlockParsed,
    );
  }

  Map<String, dynamic> toMap() {
    final passedCountMap = passedTopicsCount.map((k, v) => MapEntry(k, v));
    final topicUnlockMap = topicUnlockStatus.map((level, topics) {
      final t = topics.map((tk, tv) => MapEntry(tk, tv));
      return MapEntry(level, t);
    });

    return {
      'highestUnlockedLevel': highestUnlockedLevel,
      'passedTopicsCount': passedCountMap,
      'topicUnlockStatus': topicUnlockMap,
    };
  }
}
