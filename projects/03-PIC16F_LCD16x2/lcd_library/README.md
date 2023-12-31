# Compiling and Linking a Library with the `main` C File in MPLAB X using XC8

#### 1. Organize Your Files

Ensure that all your source (`.c`) and header (`.h`) files are properly organized in your project. This includes:

- Your LCD library files (e.g., `pic16flcd.c` and `pic16flcd.h`).
- Your main file (e.g., `main.c`) that contains the `main()` function.

#### 2. Include the Header Files

In your `main.c` file, include the header file for your LCD library:

```c
#include "pic16flcd.h"
```

This allows `main.c` to recognize the functions and types defined in your LCD library.

#### 3. Add Files to the MPLAB X Project

In the MPLAB X IDE:

- Right-click on your project name in the "Projects" window.
- Choose "Add Existing Item" and select your `.c` and `.h` files.

This adds your files to the project and ensures they are compiled and linked correctly.

#### 4. Compile the Project

Use the build tool in MPLAB X to compile your project:

- Click on the "Build Main Project" button (hammer icon) in the toolbar, or go to "Run" → "Build Main Project" from the top menu.

MPLAB X will compile all `.c` files in the project and link them together. If your LCD library and `main.c` are correctly written and configured, the compilation should complete without errors.

#### 5. Load and Run on the Microcontroller

After successful compilation, you can load the program onto your PIC microcontroller:

- Connect your programmer/debugger (like PICkit, ICD, MPLAB Snap) to your computer and microcontroller.
- Use MPLAB X to upload the compiled program to the microcontroller.

#### Additional Tips

- Ensure all project settings (like the correct microcontroller selection and clock settings) are correct.
- If you encounter compilation errors, carefully review the error messages to understand what needs to be fixed.
- If you are using external or custom libraries like the LCD library, make sure dependencies (like header files) are accessible and correctly referenced in your code.
