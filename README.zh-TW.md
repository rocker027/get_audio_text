# ⚠️ Important Disclaimer

**Before using this tool, please read and understand the following terms carefully.**

This project (`get_audio_text`) is a technical tool designed for personal learning, research, and educational purposes. Its core function is to automate the processing of audio and video files, including downloading, transcription, and content analysis.

1.  **Legality and Copyright**: This tool is not designed for copyright infringement. Users are solely responsible for all their actions. You should only use this tool for:
    *   Content for which you own the full copyright (e.g., your own videos or recordings).
    *   Content that is in the Public Domain.
    *   Content for which you have obtained explicit permission from the copyright holder.
    *   Content that falls under "Fair Use" or "Fair Dealing" as permitted by your local laws, for purposes such as personal backup, academic research, news reporting, or commentary.

2.  **Compliance with Platform Policies**: Downloading content from online platforms (such as YouTube, Instagram, TikTok, etc.) may violate their Terms of Service. You are responsible for reading and complying with the policies of any platform before downloading its content.

3.  **No Warranty**: This project is provided "as is", without any express or implied warranty. The developer does not guarantee the stability, reliability, or suitability of the tool for any specific purpose.

4.  **Limitation of Liability**: The project developer is not liable for any direct or indirect damages (including, but not limited to, data loss, loss of business profits, or any legal disputes) arising from the use or inability to use this tool.

**By continuing to use this tool, you agree to and accept all the terms above and commit to using this tool legally and in compliance with all regulations. If you do not agree with these terms, please stop using and delete all files related to this project immediately.**

---

# Get Audio Text 🎵→📝

![CleanShot 2025-07-02 at 21 57 13@2x](https://github.com/user-attachments/assets/465b17ca-186a-41e2-b77c-a7f39309cd93)

A powerful audio transcription tool with both a command-line and a web interface. It can download audio from platforms like YouTube and Instagram, automatically transcribe it into text, and provide AI-powered summaries.

## ✨ Features

### 🖥️ Web Interface
- 🌐 **User-Friendly UI**: Intuitive drag-and-drop uploads and real-time status display.
- 📊 **Live Progress Tracking**: Visualize the processing pipeline with detailed logs.
- 📋 **Markdown Preview**: Beautifully formatted summaries with a one-click copy feature.
- 📁 **Multiple Input Methods**: Supports URL input, file uploads, and drag-and-drop.

### 🛠️ Command-Line Tool
- 🚀 **All-in-One Automation**: From URL to transcript with a single command.
- 🌐 **Multi-Platform Support**: YouTube, Instagram, TikTok, Facebook, and more.
- 🎯 **Smart Filename Handling**: Automatically uses the original title for filenames, avoiding special character issues.
- 🗂️ **Automatic Cleanup**: Deletes audio files after transcription to save space.

### 🤖 AI-Enhanced Features
- 📄 **Multiple Output Formats**: Supports TXT, SRT, and VTT formats.
- 🧠 **AI Smart Summary**: Integrates with Gemini CLI to automatically generate content summaries.
- 🎛️ **Flexible Options**: Choose to keep audio, skip transcription, customize the Whisper model, and more.

## 🛠️ System Requirements

### Required Tools

```bash
# Install yt-dlp (video download tool)
brew install yt-dlp

# Install ffmpeg (audio conversion tool)
brew install ffmpeg

# Install Whisper (speech recognition tool)
pip3 install openai-whisper
```

### System Requirements

- macOS / Linux
- Python 3.9+
- Internet Connection

### Optional Tools

```bash
# Install Gemini CLI (for AI summary feature)
# Follow the installation guide from Google AI Studio
```

## 📦 Installation & Setup

### 1. Download the Project

```bash
# Clone the project
git clone https://github.com/rocker027/get-audio-text.git
cd get-audio-text

# Or download the ZIP and extract it
```

### 2. Configure the Script

The script will guide you through the setup on its first run:

```bash
# Grant execution permissions
chmod +x get_audio_text.sh

# The first run will enter setup mode
./get_audio_text.sh
```

The script will ask you to set a directory for downloading audio files. The default path is recommended:
- Default Path: `~/Downloads/AudioCapture`
- Transcripts will be saved in: `~/Downloads/AudioCapture/Transcripts`
- Whisper models will be cached in: `~/Downloads/AudioCapture/WhisperModel`

### 3. Launch the Web Interface (Optional)

```bash
# Navigate to the web interface directory
cd web_interface

# Start the local web server
python3 -m http.server 8000 --cgi

# Open http://localhost:8000 in your browser
```

## 🚀 Usage

### 🖥️ Using the Web Interface

The web interface is recommended for a more intuitive experience:

1.  **Start the Web Server**
    ```bash
    cd web_interface
    python3 -m http.server 8000 --cgi
    ```

2.  **Visit in Browser**: `http://localhost:8000`

3.  **How to Use**
    - **URL Input**: Paste a URL from YouTube, Instagram, etc.
    - **File Upload**: Click "Browse Files" or drag and drop a file.
    - **Live Monitoring**: Watch the processing progress and detailed logs.
    - **Result Preview**: View the summary in Markdown format and copy with one click.

### 🛠️ Using the Command-Line

#### Basic Usage

```bash
# Download audio + auto transcribe (default behavior)
./get_audio_text.sh "https://www.youtube.com/watch?v=VIDEO_ID"

# Instagram Reels
./get_audio_text.sh "https://www.instagram.com/reel/POST_ID/"
```

#### Using Local Files

```bash
# Transcribe a local video file
./get_audio_text.sh "/path/to/local_video.mp4"

# Transcribe an audio file
./get_audio_text.sh "/path/to/audio.mp3"

# Analyze a transcript file (directly generates AI summary)
./get_audio_text.sh "/path/to/transcript.txt"
```

#### Advanced Options

```bash
# Only download audio, no transcription
./get_audio_text.sh "URL" --no-transcribe

# Keep the audio file after transcription
./get_audio_text.sh "URL" --keep-audio

# Skip AI summary
./get_audio_text.sh "URL" --no-summary

# Specify Whisper model (default is small)
./get_audio_text.sh "URL" --model base
./get_audio_text.sh "URL" --model medium

# Combine options
./get_audio_text.sh "URL" --model small --keep-audio --no-summary
```

## 📁 Project Structure

```
get-audio-text/
├── 📄 get_audio_text.sh          # Main transcription script
├── 📄 README.md                 # Project documentation (English)
├── 📄 README.zh-TW.md           # Project documentation (Traditional Chinese)
├── 📄 .gitignore                 # Git ignore settings
└── 📂 web_interface/             # Web Interface
    ├── 📄 index.html             # Main page
    ├── 📄 test.html              # CGI test page
    ├── 📄 README.md              # Web interface documentation
    ├── 📂 static/                # Static assets
    │   ├── 📄 style.css          # Stylesheet
    │   └── 📄 script.js          # Frontend logic
    ├── 📂 cgi-bin/               # CGI scripts
    │   ├── 📄 process.py         # Main processing script
    │   ├── 📄 test.py            # Test script
    │   └── 📄 ...                # Other test utilities
    └── 📂 uploads/               # Temporary file uploads
```

### Output File Structure

```
~/Downloads/AudioCapture/         # Default output directory
├── 📂 Transcripts/               # Transcripts and summaries
│   ├── Video Title.txt          # Plain text transcript
│   ├── Video Title.srt          # Subtitle format (with timestamps)
│   ├── Video Title.vtt          # WebVTT format
│   └── Video Title_summary.txt  # AI-generated summary
├── 📂 WhisperModel/             # Whisper model cache
│   └── [model_name].pt          # Downloaded model file
└── Video Title.mp3              # Audio file (optional, can be kept)
```

## 💡 Usage Examples

### 🖥️ Web Interface Examples

1.  **Process a YouTube Video**
    - Paste into the URL input: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
    - Select Whisper model: `small`
    - Click "🚀 Start Processing"
    - Watch the live progress: Downloading → Transcribing → AI Summary
    - View and copy the summary in Markdown format.

2.  **Process a Local File**
    - Drag and drop an MP4 file into the upload area.
    - The system automatically detects the file type and processes it accordingly.
    - View the real-time status and final result.

### 🛠️ Command-Line Examples

#### Transcribe a YouTube Video

```bash
./get_audio_text.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ" --model small
```

**Output Files:**
- `Rick Astley - Never Gonna Give You Up.txt` (Plain text transcript)
- `Rick Astley - Never Gonna Give You Up.srt` (Subtitle file)
- `Rick Astley - Never Gonna Give You Up.vtt` (WebVTT file)
- `Rick Astley - Never Gonna Give You Up_summary.txt` (AI summary)

#### Transcribe an Instagram Reel

```bash
./get_audio_text.sh "https://www.instagram.com/reel/ABC123/" --keep-audio
```

**Output:**
- Full transcript files (3 formats)
- AI smart summary
- The original audio file (because of --keep-audio)

#### Process Local Files

```bash
# Process a local video
./get_audio_text.sh "/path/to/video.mp4"

# Process an audio file
./get_audio_text.sh "/path/to/audio.mp3"

# Analyze an existing transcript
./get_audio_text.sh "/path/to/transcript.vtt"
```

## ⚙️ Parameter Reference

### Command-Line Arguments

| Argument | Description | Example |
|---|---|---|
| `--model [model_name]` | Specify Whisper model (tiny, base, small, medium, large). Default: `small` | `./get_audio_text.sh "URL" --model base` |
| `--no-transcribe` | Only download audio, skip transcription | `./get_audio_text.sh "URL" --no-transcribe` |
| `--keep-audio` | Keep the audio file after transcription | `./get_audio_text.sh "URL" --keep-audio` |
| `--no-summary` | Skip generating AI summary | `./get_audio_text.sh "URL" --no-summary` |

### Whisper Model Comparison

| Model | Size | Speed | Accuracy | Recommended Use |
|---|---|---|---|---|
| `tiny` | ~39 MB | Fastest | Low | Quick tests |
| `base` | ~74 MB | Fast | Fair | Everyday use |
| `small` | ~244 MB | Medium | Good | **Recommended Default** |
| `medium` | ~769 MB | Slow | Very Good | High-quality needs |
| `large` | ~1550 MB | Slowest | Best | Professional use |

### Web Interface Options

- **Whisper Model**: Select from a dropdown menu.
- **Keep audio file**: Whether to keep the audio after transcription.
- **Download only, skip transcription**: Only downloads, does not transcribe.
- **Skip AI summary**: Does not generate a Gemini summary.

## 🌍 Supported Formats & Platforms

### 📱 Supported Platforms

| Platform | Support | Notes |
|---|---|---|
| ✅ YouTube | Fully Supported | Public videos, Shorts |
| ✅ Instagram | Public Content | Public posts, Reels, Stories |
| ✅ TikTok | Fully Supported | Public videos |
| ✅ Facebook | Partially Supported | Public videos |
| ✅ Twitter/X | Partially Supported | Public videos |
| ✅ Others | Limited Support | Depends on yt-dlp support |

### 📁 Supported File Formats

#### Video Formats
- **Fully Supported**: MP4, AVI, MKV, MOV, WMV, FLV, WEBM, M4V, 3GP, OGV

#### Audio Formats
- **Fully Supported**: MP3, WAV, FLAC, AAC, OGG, M4A, WMA, OPUS

#### Transcript Formats
- **Direct Analysis**: TXT, VTT, SRT (Supports direct AI summary without transcription)

### 🔄 Processing Workflow

1.  **Online Video** → Download Audio → Whisper Transcription → AI Summary
2.  **Local Video** → Extract Audio → Whisper Transcription → AI Summary
3.  **Local Audio** → Whisper Transcription → AI Summary
4.  **Transcript File** → Direct AI Summary

## 🔧 Advanced Configuration

### Changing Output Paths

The script guides you through setup on the first run, but you can also manually edit the config file:

```bash
# Config file location
~/.get_audio_text_config

# Content format
AUDIO_DIR="/your/custom/path/AudioCapture"
TRANSCRIPT_DIR="/your/custom/path/AudioCapture/Transcripts"
WHISPER_MODEL_DIR="/your/custom/path/AudioCapture/WhisperModel"
```

### Web Interface Configuration

The web interface automatically uses the settings from the command-line script. No extra configuration is needed.

### Gemini AI Configuration

To use the AI summary feature, you need to set up the Gemini CLI first:

```bash
# Install Gemini CLI (refer to Google AI Studio documentation)
# Set your API key
export GOOGLE_API_KEY="your-api-key"
```

## 🐛 FAQ & Troubleshooting

### Installation Issues

**Q: Missing tool errors?**
```bash
# Check tool installations
yt-dlp --version
ffmpeg -version
whisper --help

# Reinstall
brew install yt-dlp ffmpeg
pip3 install openai-whisper
```

**Q: Web interface won't start?**
```bash
# Ensure you are in the correct directory
cd web_interface

# Make sure to use the --cgi parameter
python3 -m http.server 8000 --cgi

# Check http://localhost:8000 in your browser
```

### Usage Issues

**Q: Can't find the downloaded files?**
- Check the config file: `~/.get_audio_text_config`
- Ensure the directory exists and has write permissions.
- Default location: `~/Downloads/AudioCapture/Transcripts/`

**Q: Instagram/TikTok download fails?**
- Make sure the content is public.
- Check if the URL format is correct.
- Ensure your internet connection is working.
- Try updating yt-dlp: `brew upgrade yt-dlp`

**Q: Web interface stuck at "Preparing"?**
- Use `http://localhost:8000/test.html` to diagnose the CGI environment.
- Check Python path and permissions.
- Ensure `get_audio_text.sh` has execute permissions.

### Performance Issues

**Q: Whisper transcription is slow?**
- Use a smaller model (`tiny` or `base`).
- The first use of a model requires downloading it, which takes time.
- Ensure you have enough memory and CPU resources.

**Q: AI summary is not generated?**
- Check if Gemini CLI is installed.
- Verify that the API key is set correctly.
- You can skip the summary with `--no-summary`.

## 🔧 Development & Contribution

### Project Tech Stack

- **Command-Line Script**: Bash Shell Script
- **Web Frontend**: HTML5, CSS3, JavaScript (vanilla)
- **Web Backend**: Python CGI
- **Audio Processing**: yt-dlp, ffmpeg, OpenAI Whisper
- **AI Integration**: Gemini CLI

### Development Environment Setup

```bash
# Clone the project
git clone https://github.com/rocker027/get-audio-text.git
cd get-audio-text

# Set script permissions
chmod +x get_audio_text.sh

# Test command-line functionality
./get_audio_text.sh

# Test web interface
cd web_interface
python3 -m http.server 8000 --cgi
```

### Contribution Guidelines

Issues and Pull Requests are welcome!

1.  **Report Issues**: Use GitHub Issues.
2.  **Suggest Features**: Describe your needs and use case in detail.
3.  **Code Contributions**: Please follow the existing code style.

## 🙏 Acknowledgements & Third-Party Licenses

This project relies on several excellent open-source tools. We extend our heartfelt thanks to their developers. Users of this tool should also comply with the license terms of these third-party tools.

-   **yt-dlp**
    -   **Purpose**: Downloading videos and audio from online platforms.
    -   **License**: The Unlicense (Public Domain)
    -   **Project Link**: [https://github.com/yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp)

-   **FFmpeg**
    -   **Purpose**: Audio extraction and format conversion.
    -   **License**: GNU Lesser General Public License (LGPL) version 2.1 or later / GNU General Public License (GPL) version 2 or later.
    -   **Project Link**: [https://ffmpeg.org/](https://ffmpeg.org/)

-   **OpenAI Whisper**
    -   **Purpose**: Speech-to-text transcription.
    -   **License**: MIT License
    -   **Project Link**: [https://github.com/openai/whisper](https://github.com/openai/whisper)

-   **Google Gemini**
    -   **Purpose**: AI content summarization.
    -   **License**: Apache License 2.0
    -   **Project Link**: [https://ai.google.dev/](https://ai.google.dev/)

---

## 📄 License & Terms of Use

### License

This project is licensed under the **MIT License**. You are free to use, modify, and distribute it.

### Important Notice

- ⚖️ **Legal Compliance**: Please adhere to the terms of use of all platforms.
- 🎓 **Usage Limitation**: For personal study, research, and legitimate purposes only.
- 📄 **Respect Copyright**: Please respect copyright and do not download unauthorized content.
- 🚫 **Disclaimer of Liability**: Users assume all risks associated with the use of this tool.

## 📞 Support & Feedback

### Getting Help

1.  📖 Check the [FAQ](#-faq--troubleshooting) section.
2.  🐛 Submit a [GitHub Issue](https://github.com/rocker027/get-audio-text/issues).
3.  📚 Refer to the [yt-dlp documentation](https://github.com/yt-dlp/yt-dlp) for platform support.
4.  🧪 Use `http://localhost:8000/test.html` to diagnose issues.

### Feature Highlights

- 🖥️ **Dual Mode**: Command-Line + Web Interface
- 🎯 **Intelligent**: Automatic file type detection
- 🤖 **AI-Enhanced**: Gemini smart summaries
- 📊 **Visualized**: Real-time progress and status display
- 🔧 **User-Friendly**: One-click installation and automatic setup

---

**⭐ If this tool is helpful to you, please give it a Star to show your support!**

**🚀 Making audio transcription simpler and smarter!**