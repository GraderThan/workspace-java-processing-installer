# Java Processing Installer for Grader Than

A tool for automatically installing Processing in Grader Than workspaces and enabling students to create Java Processing projects easily.

## What It Does
- Installs Processing to `/opt/processing/processing-$VERSION`.
- Copies `template/` and `p5j-new` to `/opt/processing`.
- Saves the core JAR path at `/opt/processing/processing-core-jar-path`.
- Creates symlinks: `/usr/local/bin/processing` and `/usr/local/bin/p5j-new`.

## Requirements
- Grader Than Workspace with Linux (Debian Variant)

## Install

Below is a [dependency](https://docs.graderthan.com/workspace/config/?h=dep#dependencies) script you can add to your students' workspace. It will automatically install Processing for them and set up a command they can use to make processing projects:

```
#!/bin/bash
cd /tmp
git clone https://github.com/GraderThan/workspace-java-processing-installer.git
cd workspace-java-processing-installer
bash init.sh &
```

## Usage

1) When a student opens their workspace, have them [open the terminal](https://docs.graderthan.com/shared/openTerminal/)
2) In the terminal run the command

    ```
    p5j-new <project-name>
    ```
    (where `<project-name>` is a placeholder for your student's project name, so
    insert it there with no spaces).

    This will create a new Java project ready for running Java processing in a
    folder named after the project.

3) Finally, change the IDE folder to the new project folder by clicking the menu button in the upper right corner and selecting File > Open Folder.

## Changing Processing Version

To use a different version of Processing, you can set the `URL` environment variable before running the installer. Find the desired version at https://github.com/processing/processing4/releases and copy the Linux x64 portable ZIP download URL.

Example:
```bash
export URL="https://github.com/processing/processing4/releases/download/processing-1306-4.4.6/processing-4.4.6-linux-x64-portable.zip"
bash init.sh &
```

If no URL is provided, the installer defaults to Processing 4.4.6.

## Files and Paths
- Install base: `/opt/processing`
  - Processing: `/opt/processing/processing-$VERSION`
  - Template: `/opt/processing/template`
  - Generator: `/opt/processing/p5j-new`
  - Core JAR path file: `/opt/processing/processing-core-jar-path`
- Symlinks:
  - IDE: `/usr/local/bin/processing`
  - Generator: `/usr/local/bin/p5j-new`

## Verify
```bash
processing                 # IDE should launch
p5j-new Test               # Creates ./Test from the template
```
If `Test` already exists (file or dir), the generator exits with an error.

## Notes
- The release URL in `init.sh` pins a specific Processing version. Update it if you need a different version or architecture.
- The installer creates a desktop entry on systems that use `.desktop` files.

## Uninstall (manual)
```bash
rm -f /usr/local/bin/processing /usr/local/bin/p5j-new
rm -rf /opt/processing/processing-* /opt/processing/template /opt/processing/p5j-new /opt/processing/processing-core-jar-path
```

## License
See `LICENSE` for the Grader Than Technology LLC Academic Content License terms.
