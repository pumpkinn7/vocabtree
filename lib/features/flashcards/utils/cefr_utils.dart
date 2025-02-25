/// ยูทิลิตี้สำหรับจัดการ CEFR level
class CefrUtils {
  /// แปลงค่า CEFR เป็น "N/A" ถ้าเป็น ">" หรือค่าว่าง
  static String normalizeCefrLevel(String? cefrLevel) {
    if (cefrLevel == null || cefrLevel == ">" || cefrLevel.isEmpty) {
      return "N/A";
    }
    return cefrLevel;
  }

  /// แสดงสีตามระดับ CEFR
  static int getCefrColor(String cefrLevel) {
    String normalizedLevel = normalizeCefrLevel(cefrLevel);

    switch (normalizedLevel) {
      case 'A1':
        return 0xFF8BC34A; // Light Green
      case 'A2':
        return 0xFF4CAF50; // Green
      case 'B1':
        return 0xFF64B5F6; // Light Blue
      case 'B2':
        return 0xFF2196F3; // Blue
      case 'C1':
        return 0xFF9C27B0; // Purple
      case 'C2':
        return 0xFF7B1FA2; // Deep Purple
      case 'N/A':
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
}
