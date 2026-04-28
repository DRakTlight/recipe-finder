/// Returns the image URL to display in the UI.
///
/// เดิมใช้ Cloud Function proxy เพื่อหลีก CORS แต่ img.spoonacular.com
/// อนุญาต cross‑origin ได้โดยตรง จึงใช้ URL ตรงๆ ได้เลย
String imageUrlForUi(String original) {
  return original.trim();
}

