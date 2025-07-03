#!/bin/bash

# English (US) Language Pack

# General messages
MSG_WELCOME="Welcome to Audio Transcription Tool!"
MSG_APP_TITLE="YouTube/Instagram Audio Download + Transcription All-in-One Service"
MSG_SEPARATOR="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
MSG_FIRST_SETUP="First-time setup requires setting download directory"
MSG_SETUP_COMPLETE="Setup complete!"
MSG_PROCESSING_COMPLETE="All-in-one processing complete!"

# Configuration related
MSG_CONFIG_LOAD="Load existing configuration"
MSG_CONFIG_NOT_FOUND="Configuration file not found, entering initial setup..."
MSG_CONFIG_SAVED="Configuration saved to"
MSG_USE_DEFAULT_PATH="Using default path"
MSG_RECOMMEND_DEFAULT_PATH="Recommended default path"
MSG_INPUT_DIRECTORY="Please enter the full path for audio file download directory"
MSG_PRESS_ENTER_DEFAULT="(Press Enter to use default path:"
MSG_DIRECTORY_PATH="Path"
MSG_DIRECTORY_NOT_EXIST="Directory does not exist"
MSG_CREATE_DIRECTORY="Create this directory? (Y/n)"
MSG_DIRECTORY_CREATED="Directory created successfully"
MSG_DIRECTORY_CREATE_FAILED="Directory creation failed"
MSG_RETYPE_PATH="Please re-enter path"
MSG_RETYPE_CORRECT_PATH="Please re-enter correct path"

# Directory messages
MSG_AUDIO_DIR="Audio files directory"
MSG_TRANSCRIPT_DIR="Transcript directory"
MSG_WHISPER_MODEL_DIR="Whisper model directory"
MSG_AUDIO_RECREATE="Audio directory does not exist, recreating..."

# Path validation
MSG_ABSOLUTE_PATH_REQUIRED="Please provide absolute path (starting with /)"
MSG_PARENT_DIR_NOT_EXIST="Parent directory does not exist"
MSG_NO_WRITE_PERMISSION="Directory exists but no write permission"
MSG_CANNOT_CREATE_DIR="Cannot create new directory in parent directory"

# Dependency check
MSG_MISSING_TOOLS="Missing required tools"
MSG_INSTALL_METHODS="Installation methods:"
MSG_GEMINI_DETECTED="Gemini CLI detected, will auto-generate summary after transcription"
MSG_GEMINI_NOT_DETECTED="Gemini CLI not detected, skipping summary feature"

# File check
MSG_FILE_EXISTS="File existence check passed"
MSG_FILE_NOT_EXIST="File does not exist"
MSG_FILE_PATH_CONFIRM="Please confirm file path is correct, or provide valid URL"
MSG_FILE_INFO="File"
MSG_FILE_EXTENSION="Extension"
MSG_UNKNOWN_FORMAT="Unknown file format"
MSG_UNSUPPORTED_FORMAT="Unsupported file format"
MSG_SUPPORTED_FORMATS="Supported formats"

# Processing flow
MSG_PROCESS_FLOW="Processing flow"
MSG_PROCESS_VIDEO="Video → Audio extraction → Whisper transcription → AI analysis"
MSG_PROCESS_AUDIO="Audio → Whisper transcription → AI analysis"
MSG_PROCESS_TRANSCRIPT="Transcript → AI analysis"
MSG_DETECTED_VIDEO="Detected video file"
MSG_DETECTED_AUDIO="Detected audio file"
MSG_DETECTED_TRANSCRIPT="Detected transcript file"
MSG_DETECTED_LOCAL_VIDEO="Local video file"
MSG_DETECTED_LOCAL_AUDIO="Local audio file"
MSG_DETECTED_LOCAL_TRANSCRIPT="Local transcript file"

# Download related
MSG_DOWNLOAD_STEP="Step 1/2: Downloading audio..."
MSG_DOWNLOAD_COMPLETE="Audio download complete!"
MSG_DOWNLOAD_FAILED="Audio download failed"
MSG_DOWNLOAD_TEMP_FILE="Temporary file"
MSG_DOWNLOAD_TEMP_LOCATION="Temporary location"
MSG_DOWNLOAD_ORIGINAL_TITLE="Original title"
MSG_DOWNLOAD_GETTING_INFO="Getting video information..."
MSG_DOWNLOAD_INFO_FAILED="Cannot get video information, using timestamp as title"
MSG_DOWNLOAD_TIMESTAMP_NOT_FOUND="Timestamp file not found, looking for actual downloaded file..."
MSG_DOWNLOAD_ACTUAL_FILE="Actual downloaded file"
MSG_DOWNLOAD_RENAMED="Renamed to"
MSG_DOWNLOAD_FILE_NOT_FOUND="Downloaded file not found"

# Platform detection
MSG_PLATFORM_INSTAGRAM="Instagram"
MSG_PLATFORM_YOUTUBE="YouTube"
MSG_PLATFORM_TIKTOK="TikTok"
MSG_PLATFORM_OTHER="Other platform"
MSG_DETECTED_PLATFORM="Detected"
MSG_PLATFORM_URL="URL"

# Audio extraction
MSG_EXTRACT_AUDIO="Extracting audio from video file..."
MSG_EXTRACT_VIDEO_FILE="Video file"
MSG_EXTRACT_OUTPUT_AUDIO="Output audio"
MSG_EXTRACT_NEED_FFMPEG="Need ffmpeg to extract video audio"
MSG_EXTRACT_COMPLETE="Audio extraction complete!"
MSG_EXTRACT_FAILED="Audio extraction failed"
MSG_EXTRACT_READY="Audio extraction successful, ready for transcription"

# Transcription related
MSG_TRANSCRIBE_STEP="Step 2/2: Starting transcription..."
MSG_TRANSCRIBE_AUDIO="Starting audio to text transcription..."
MSG_TRANSCRIBE_COMPLETE="Transcription complete!"
MSG_TRANSCRIBE_FAILED="Transcription failed, keeping temporary audio file for retry"
MSG_TRANSCRIBE_SKIP="Skipping transcription step"
MSG_TRANSCRIBE_FILE_NOT_EXIST="Audio file does not exist"
MSG_TRANSCRIBE_TEMP_FILE="Temporary file"
MSG_TRANSCRIBE_TARGET_NAME="Target name"
MSG_TRANSCRIBE_CLEANUP="Cleaning temporary audio files..."
MSG_TRANSCRIBE_CLEANUP_COMPLETE="Temporary audio file deleted"
MSG_TRANSCRIBE_CLEANUP_FAILED="Cannot delete audio file"
MSG_TRANSCRIBE_SAVE_SPACE="Saving storage space, keeping only transcript"
MSG_TRANSCRIBE_RENAME="Audio file renamed to"
MSG_TRANSCRIBE_KEEP_AUDIO="Keep audio file after transcription"
MSG_TRANSCRIBE_SUCCESS_RENAME="File renamed to"

# Whisper model
MSG_WHISPER_MODEL_NOT_EXIST="Whisper model '$WHISPER_MODEL_NAME' does not exist."
MSG_WHISPER_FIRST_DOWNLOAD="First run will auto-download, please wait..."
MSG_WHISPER_LOCAL_MODEL="Detected local Whisper model"
MSG_WHISPER_LOADING="will load directly."

# AI analysis
MSG_AI_ANALYSIS_START="Starting AI analysis..."
MSG_AI_ANALYSIS_TXT="Using TXT format transcript for AI analysis"
MSG_AI_ANALYSIS_VTT="Extracting text from VTT format for AI analysis"
MSG_AI_ANALYSIS_SRT="Extracting text from SRT format for AI analysis"
MSG_AI_ANALYSIS_NO_FILE="Cannot find usable transcript file, skipping AI analysis"
MSG_AI_ANALYSIS_FORMATS="Supported formats: .txt, .vtt, .srt"

# Transcript processing
MSG_TRANSCRIPT_PROCESSING="Processing transcript file..."
MSG_TRANSCRIPT_COPIED="Transcript copied to"
MSG_TRANSCRIPT_IN_TARGET="Transcript already in target directory"
MSG_TRANSCRIPT_COMPLETE="Transcript file processing complete!"
MSG_TRANSCRIPT_FAILED="Transcript file processing failed"
MSG_TRANSCRIPT_EXTRACT_COMPLETE="Text content extraction complete"
MSG_TRANSCRIPT_EXTRACT_FAILED="Text content extraction failed"
MSG_TRANSCRIPT_SUBTITLE_NOT_EXIST="Subtitle file does not exist"
MSG_TRANSCRIPT_UNSUPPORTED_FORMAT="Unsupported subtitle format"

# Gemini summary
MSG_GEMINI_SUMMARY_START="Starting Gemini summary generation..."
MSG_GEMINI_ANALYSIS_FILE="Analysis file"
MSG_GEMINI_SUMMARY_COMPLETE="Summary generation complete!"
MSG_GEMINI_SUMMARY_FAILED="Gemini summary generation failed"
MSG_GEMINI_SUMMARY_FILE="Summary file"
MSG_GEMINI_SUMMARY_LOCATION="Save location"
MSG_GEMINI_CLI_NOT_FOUND="Cannot find available Gemini CLI"
MSG_GEMINI_TRANSCRIPT_NOT_EXIST="Transcript file does not exist"

# Status indicators
MSG_STATUS_SUCCESS="✅"
MSG_STATUS_ERROR="❌"
MSG_STATUS_WARNING="⚠️"
MSG_STATUS_INFO="ℹ️"
MSG_STATUS_PROCESSING="🔄"

# Cleanup and storage
MSG_CLEANUP_INFO="Cleanup info file"
MSG_SAVE_SPACE="Auto-cleaned audio files, saving storage space"
MSG_MANUAL_TRANSCRIBE="You can manually transcribe later:"
MSG_OPEN_TRANSCRIPT_FOLDER="Open transcript folder? (y/N)"
MSG_OPEN_AUDIO_FOLDER="Open audio folder? (y/N)"
MSG_LOCATION_TRANSCRIPT="Transcript"
MSG_LOCATION_AUDIO="Audio files"

# Error reasons and suggestions
MSG_ERROR_POSSIBLE_REASONS="Possible reasons:"
MSG_ERROR_SUGGESTIONS="Suggestions:"
MSG_ERROR_URL_FORMAT="URL format error"
MSG_ERROR_NETWORK="Network connection issue"
MSG_ERROR_PRIVATE_CONTENT="Video is private content"
MSG_ERROR_DELETED_CONTENT="Video has been deleted"
MSG_SUGGEST_CHECK_URL="Confirm URL is complete and correct"
MSG_SUGGEST_CHECK_ACCESS="Confirm content is publicly accessible"
MSG_SUGGEST_CHECK_NETWORK="Check network connection"

# Usage instructions
MSG_USAGE_TITLE="Usage:"
MSG_USAGE_SOURCES="Supported sources:"
MSG_USAGE_SOURCES_YOUTUBE="YouTube (youtube.com, youtu.be)"
MSG_USAGE_SOURCES_INSTAGRAM="Instagram (instagram.com) - Public content only"
MSG_USAGE_SOURCES_TIKTOK="TikTok"
MSG_USAGE_SOURCES_FACEBOOK="Facebook"
MSG_USAGE_SOURCES_OTHER="Other yt-dlp supported platforms"
MSG_USAGE_FILE_TYPES="Supported file types:"
MSG_USAGE_VIDEO_FILES="Video files: MP4, AVI, MKV, MOV, WMV, FLV, WEBM, M4V etc"
MSG_USAGE_AUDIO_FILES="Audio files: MP3, WAV, FLAC, AAC, OGG, M4A, WMA etc"
MSG_USAGE_TRANSCRIPT_FILES="Transcript files: TXT, VTT, SRT"
MSG_USAGE_PROCESS_FLOW="Processing flow:"
MSG_USAGE_PARAMETERS="Parameter descriptions:"
MSG_USAGE_AI_OPTIONS="AI analysis options:"
MSG_USAGE_EXAMPLES="Examples:"
MSG_USAGE_ONLINE_VIDEO="Online video"
MSG_USAGE_LOCAL_VIDEO="Local video files"
MSG_USAGE_LOCAL_AUDIO="Local audio files"
MSG_USAGE_LOCAL_TRANSCRIPT="Local transcript files"
MSG_USAGE_OUTPUT_LOCATION="Output location:"

# Parameter descriptions
MSG_PARAM_MODEL="Specify Whisper model (tiny, base, small, medium, large), default: small"
MSG_PARAM_NO_TRANSCRIBE="Download audio only, no transcription"
MSG_PARAM_KEEP_AUDIO="Keep audio file after transcription"
MSG_PARAM_OPEN_FOLDER="Ask to open folder after completion"
MSG_PARAM_NO_SUMMARY="Skip Gemini AI summary generation"

# Prompts
MSG_PROMPT_PATH="📁 Path: "
MSG_PROMPT_CREATE_DIR="Create this directory? (Y/n): "
MSG_PROMPT_OPEN_TRANSCRIPT="Open transcript folder? (y/N): "
MSG_PROMPT_OPEN_AUDIO="Open audio folder? (y/N): "

# Separators and connectors
MSG_SEPARATOR_OR="or"
MSG_SEPARATOR_AND="and"
MSG_SEPARATOR_COLON=":"
MSG_SEPARATOR_COMMA=", "
MSG_SEPARATOR_PERIOD="."
MSG_SEPARATOR_DASH="—"