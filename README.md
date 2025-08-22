# Java Processing Installer and Project Generator

A minimal setup to install Processing under `/opt/processing` on a Grader Than Workspace and scaffold Java projects from a template.

## What It Does
- Installs Processing to `/opt/processing/processing-$VERSION`.
- Copies `template/` and `p5j-new` to `/opt/processing`.
- Saves the core JAR path at `/opt/processing/processing-core-jar-path`.
- Creates symlinks: `/usr/local/bin/processing` and `/usr/local/bin/p5j-new`.

## Requirements
- Linux environment, run as root.
- Packages: `curl`, `unzip`.

## Install
```bash
# As root
bash init.sh
```
This downloads the Processing Linux portable release, installs it under `/opt/processing/processing-$VERSION`, and sets up the template and symlinks.

## Usage
- Launch IDE: `processing`
- Create a project: `p5j-new MySketch`
  - Generates `MySketch/` from `template/` (copies recursively, including dotfiles).
  - Adds `lib/core.jar` from the installed Processing.

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
