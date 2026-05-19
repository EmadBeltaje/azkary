abstract interface class AudioStorageSource {
  Future<bool> has(String key);
  Future<String?> get(String key);
  Future<void> put(String key, String storedPath);
  Future<void> remove(String key);
  Future<Map<String, String>> readAll();
  Future<void> clearAll();
}
