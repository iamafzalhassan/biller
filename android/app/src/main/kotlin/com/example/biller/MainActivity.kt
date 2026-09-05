package com.example.biller

import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "biller/receipts"
        const val SUB_DIR = "Biller/Receipts"
        val RELATIVE_DIR = "${Environment.DIRECTORY_DOWNLOADS}/$SUB_DIR"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveReceipt" -> {
                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")
                    if (fileName == null || bytes == null) {
                        result.error("bad_arguments", "fileName and bytes are required", null)
                    } else {
                        try {
                            result.success(saveReceipt(fileName, bytes))
                        } catch (error: Exception) {
                            result.error("save_failed", error.message, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveReceipt(fileName: String, bytes: ByteArray): String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) saveViaMediaStore(fileName, bytes) else saveViaFilePath(fileName, bytes)

    private fun saveViaMediaStore(fileName: String, bytes: ByteArray): String {
        deleteExisting(fileName)
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
            put(MediaStore.Downloads.RELATIVE_PATH, RELATIVE_DIR)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val resolver = applicationContext.contentResolver
        val uri: Uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values) ?: throw IllegalStateException("MediaStore refused the receipt")
        resolver.openOutputStream(uri)?.use { it.write(bytes) } ?: throw IllegalStateException("Could not open $uri")
        values.clear()
        values.put(MediaStore.Downloads.IS_PENDING, 0)
        resolver.update(uri, values, null, null)
        return "$RELATIVE_DIR/$fileName"
    }

    private fun deleteExisting(fileName: String) {
        val selection = "${MediaStore.Downloads.DISPLAY_NAME} = ? AND ${MediaStore.Downloads.RELATIVE_PATH} LIKE ?"
        val arguments = arrayOf(fileName, "$RELATIVE_DIR%")
        applicationContext.contentResolver.delete(MediaStore.Downloads.EXTERNAL_CONTENT_URI, selection, arguments)
    }

    private fun saveViaFilePath(fileName: String, bytes: ByteArray): String {
        val downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        val folder = File(downloads, SUB_DIR)
        if (!folder.exists() && !folder.mkdirs()) throw IllegalStateException("Could not create ${folder.absolutePath}")
        val file = File(folder, fileName)
        file.writeBytes(bytes)
        return file.absolutePath
    }
}