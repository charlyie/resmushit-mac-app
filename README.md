![alt text](https://raw.githubusercontent.com/charlyie/resmushit-mac-app/refs/heads/main/reSmush.it%20for%20Mac/Assets.xcassets/AppIcon.appiconset/256-mac.png)


# Image Optimizer Application

This application allows users to optimize images using drag-and-drop functionality, with support for popular formats such as JPEG, PNG, and GIF. The app includes features like quality adjustment, file size validation, and the ability to replace original files.

---

## Features

- **Drag-and-Drop Functionality**: Simply drag and drop your images to start the optimization process.
- **File Format Support**: Supports JPEG, PNG, and GIF files.
- **File Validation**:
  - Validates file format.
  - Ensures files are less than 5 MB.
- **Customization Options**:
  - Adjust image quality using a slider (0-100).
  - Option to replace original files or save optimized versions separately.
- **Interactive Feedback**:
  - Displays progress bars for global and individual file processing.
  - Shows error messages for unsupported or oversized files.
  - Highlights invalid files with a red icon in the file list.
- **Persistent Settings**: Remembers quality and file replacement preferences across sessions.
- **User Interface**:
  - Modern design with gradient background.
  - Integrated logo display for branding.

---

## Installation

1. Clone or download this repository.
2. Open the project in Xcode.
3. Ensure you have SwiftUI set up on your system.
4. Build and run the application using Xcode.

---

## How to Use

1. Launch the application.
2. Adjust the quality slider and toggle file replacement preferences if necessary.
3. Drag and drop your image files onto the application window.
4. The app will validate and process the files automatically.
5. Check the status of each file in the details section:
   - A green label indicates success.
   - A red icon indicates an error (e.g., invalid file format or size).
6. Optimized files are saved in the same directory as the original files, with a `-optimised` suffix, unless you choose to replace the originals.

---

## Requirements

- macOS with SwiftUI support.
- Xcode for building the project.

---

## Notes

- Files larger than 5 MB or unsupported formats will not be processed.
- Optimized files retain the same format as the original.
- Quality adjustment affects compression but not resolution.

---

## Contributing

1. Fork this repository.
2. Create a feature branch: `git checkout -b feature-name`.
3. Commit your changes: `git commit -m 'Add feature-name'`.
4. Push to the branch: `git push origin feature-name`.
5. Open a pull request.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Contact

For issues, suggestions, or contributions, please open an issue or contact the repository maintainer.

