# Overview

## Architecture

The project follows a modular architecture:

- **core/**
    - Loggin
    - Command execution abstraction
    - Distro detection

- **/modules**
    - Independent hardening components

Each module is designed to be:
- Isolated
- Reusable
- Controlled via flags

---

## Execution Flow

1. Load core modules
2. Initialize logger
3. Load configuration file
4. Apply profile
5. Parse CLI arguments (highest priority)
6. Detect distribution
7. Execute enabled modules

---

## Configuration System

Configuration is loaded from:

```bash
configs/default.conf
```

Priority order:

1. Default values
2. Config file
3. Profile
4. CLI arguments

---

## Profiles

### Server
- Enables stricter hardening
- Keep firewall and service restrictions

### Desktop
- Less aggressive
- Avoids disabling common user services

---

## Dry-Run Mode

When enabled:

```bash
./hardening.sh --dry-run
```

- Commands are logged but NOT executed
- Usefull for auditing and testing

---

## Error handling

- Critical failures stop execution
- Non-critical issues are logged as warning
- Each module validates its own operations

## Design Principles

- Idempotency (safe re-execution)
- Minimal assumptions
- Explicit error handling
- Readable and maintainable Bash

---

## Supported Systems

- Arch Linux and derivatives
- Debian / Ubuntu
- RHEL / Fedora / CentOS

---

## Future Improvements

- Custom config file support via CLI
- More granular module control
- Loggin levels (quiet / verbose)
- Additional hardening rules